import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DatePicker
    \brief Clean, optimized DatePicker with micro-component architecture
*/

Rectangle {
    id: root

    // Public API
    property string mode: "single" // "single", "range"

    // Date properties
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)
    property date endDate: new Date(NaN)

    property bool standalone: true  // Set to false when used inside containers

    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []

    // Internal state - navigation flow
    property string _currentView: "calendar" // "year", "month", "calendar"
    property int _currentMonth: _getInitialMonth()
    property int _currentYear: _getInitialYear()
    property date _rangeStartTemp: new Date(NaN)

    readonly property alias currentView: root._currentView

    // Signals
    signal dateSelected(date date)
    signal rangeSelected(date startDate, date endDate)

    Layout.minimumWidth: 312
    Layout.preferredWidth: 312
    Layout.minimumHeight: 404
    Layout.preferredHeight: 404

    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    radius: Theme.radius.md

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s2

        // Header with navigation
        UI.DatePickerHeader {
            Layout.fillWidth: true

            currentView: root._currentView
            currentMonth: root._currentMonth
            currentYear: root._currentYear

            onPreviousClicked: root._navigatePrevious()
            onNextClicked: root._navigateNext()
            onHeaderClicked: root._handleHeaderClick()
        }

        // Content area - different views
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root._getViewIndex()

            // Year picker
            UI.DatePickerYearView {
                currentYear: root._currentYear
                minimumYear: root.minimumDate.getFullYear()
                maximumYear: root.maximumDate.getFullYear()

                onYearSelected: function(year) {
                    root._currentYear = year
                    root._currentView = "month"
                }
            }

            // Month picker
            UI.DatePickerMonthView {
                currentMonth: root._currentMonth
                currentYear: root._currentYear

                onMonthSelected: function(month) {
                    root._currentMonth = month
                    root._currentView = "calendar"
                }
            }

            // Calendar view
            UI.DatePickerCalendarView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                mode: root.mode
                currentMonth: root._currentMonth
                currentYear: root._currentYear

                selectedDate: root.selectedDate
                startDate: root.startDate
                endDate: root.endDate
                rangeStartTemp: root._rangeStartTemp

                minimumDate: root.minimumDate
                maximumDate: root.maximumDate
                disabledDates: root.disabledDates

                onDateClicked: function(date) { root._handleDateClick(date) }
            }
        }

        // Action buttons - this is needed when using the time picker as a lone-component,
        // But when Date Picker and Time Picker are used in a single container
        // This should be commented out
        UI.DatePickerActions {
            visible: standalone
            Layout.fillWidth: true

            mode: root.mode
            canClear: root._canClear()
            canApply: root._canApply()

            onClearClicked: root._clearSelection()
            onApplyClicked: root._applySelection()
        }
    }

    // Private functions - keep minimal, delegate complex logic to child components
    function _getInitialMonth() {
        if (!_isEmpty(selectedDate)) return selectedDate.getMonth()
        return new Date().getMonth()
    }

    function _getInitialYear() {
        if (!_isEmpty(selectedDate)) return selectedDate.getFullYear()
        return new Date().getFullYear()
    }

    function _getViewIndex() {
        switch (_currentView) {
            case "year": return 0
            case "month": return 1
            case "calendar": return 2
            default: return 2
        }
    }

    function _navigatePrevious() {
        switch (_currentView) {
            case "year":
                _currentYear -= 20
                break
            case "month":
                _currentYear--
                break
            case "calendar":
                if (_currentMonth === 0) {
                    _currentMonth = 11
                    _currentYear--
                } else {
                    _currentMonth--
                }
                break
        }
    }

    function _navigateNext() {
        switch (_currentView) {
            case "year":
                _currentYear += 12
                break
            case "month":
                _currentYear++
                break
            case "calendar":
                if (_currentMonth === 11) {
                    _currentMonth = 0
                    _currentYear++
                } else {
                    _currentMonth++
                }
                break
        }
    }

    function _handleHeaderClick() {
        switch (_currentView) {
            case "calendar":
                _currentView = "year"
                break
            case "month":
                _currentView = "year"
                break
            // Year view doesn't have higher level
        }
    }

    function _handleDateClick(date) {
        if (mode === "single") {
                selectedDate = date
                dateSelected(selectedDate)
        } else if (mode === "range") {
            if (_isEmpty(_rangeStartTemp)) {
                _rangeStartTemp = date
                startDate = date
                endDate = new Date(NaN)
            } else {
                if (date >= _rangeStartTemp) {
                    startDate = _rangeStartTemp
                    endDate = date
                } else {
                    startDate = date
                    endDate = _rangeStartTemp
                }
                _rangeStartTemp = new Date(NaN)
                rangeSelected(startDate, endDate)
            }
        }
    }

    function _canClear() {
        if (mode === "single") return !_isEmpty(selectedDate)
        if (mode === "range") return !_isEmpty(startDate) || !_isEmpty(endDate)
        return false
    }

    function _canApply() {
        if (mode === "single") return !_isEmpty(selectedDate)
        if (mode === "range") return !_isEmpty(startDate) && !_isEmpty(endDate)
        return false
    }

    function _clearSelection() {
        selectedDate = new Date(NaN)
        startDate = new Date(NaN)
        endDate = new Date(NaN)
        _rangeStartTemp = new Date(NaN)
    }

    function _applySelection() {
        if (mode === "single" && !_isEmpty(selectedDate)) {
            dateSelected(selectedDate)
        } else if (mode === "range" && !_isEmpty(startDate) && !_isEmpty(endDate)) {
            rangeSelected(startDate, endDate)
        }
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }
}
