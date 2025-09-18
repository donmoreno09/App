import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

/*!
    \qmltype CalendarPicker
    \brief Clean calendar component with multiple selection modes

    Supports: "single", "range", "year", "month" selection types
*/

Rectangle {
    id: root

    // Public API
    property string calendarType: "single" // "single", "range", "year", "month"

    // Date properties
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)  // For range mode
    property date endDate: new Date(NaN)    // For range mode
    property int selectedYear: new Date().getFullYear()   // For year mode
    property int selectedMonth: new Date().getMonth()     // For month mode

    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []

    // Signals
    signal dateSelected(date date)
    signal rangeSelected(date startDate, date endDate)
    signal yearSelected(int year)
    signal monthSelected(int month, int year)

    // Styling
    width: 320
    height: _getCalendarHeight()
    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    radius: Theme.radius.md

    // Private state
    property int _currentMonth: {
        if (calendarType === "month") return selectedMonth
        if (!_isEmpty(selectedDate)) return selectedDate.getMonth()
        return new Date().getMonth()
    }
    property int _currentYear: {
        if (calendarType === "year" || calendarType === "month") return selectedYear
        if (!_isEmpty(selectedDate)) return selectedDate.getFullYear()
        return new Date().getFullYear()
    }
    property date _rangeStartTemp: new Date(NaN) // Temp selection for range mode

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        // Header with navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s10

            // Previous button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s8
                Layout.preferredHeight: Theme.spacing.s8
                variant: "ghost"
                display: AbstractButton.IconOnly
                backgroundRect.color: Theme.colors.transparent
                backgroundRect.border.width: Theme.borders.b0

                contentItem: Text {
                    anchors.centerIn: parent
                    text: "❮"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.text
                }

                onClicked: root._navigatePrevious()
            }

            // Title
            Text {
                Layout.fillWidth: true
                text: root._getHeaderText()
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightMedium
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }

            // Next button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s8
                Layout.preferredHeight: Theme.spacing.s8
                variant: "ghost"
                display: AbstractButton.IconOnly
                backgroundRect.color: Theme.colors.transparent
                backgroundRect.border.width: Theme.borders.b0

                contentItem: Text {
                    anchors.centerIn: parent
                    text: "❯"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.text
                }

                onClicked: root._navigateNext()
            }
        }

        // Content area - different views based on calendar type
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Single date and range picker (standard calendar)
            ColumnLayout {
                visible: root.calendarType === "single" || root.calendarType === "range"
                anchors.fill: parent
                spacing: Theme.spacing.s3

                // Day headers
                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.spacing.s6

                    delegate: Text {
                        text: shortName.substring(0, 3)
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize125
                        font.weight: Theme.typography.weightRegular
                        color: Theme.colors.textMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        required property string shortName
                    }
                }

                // Calendar grid
                MonthGrid {
                    id: monthGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    month: root._currentMonth
                    year: root._currentYear

                    delegate: Item {
                        required property var model

                        UI.DateTimePickerDay {
                            anchors.fill: parent

                            date: model.date
                            isCurrentMonth: model.month === root._currentMonth
                            isToday: model.date.toDateString() === new Date().toDateString()
                            isSelected: root._isDaySelected(model.date)
                            isDisabled: root._isDateDisabled(model.date)

                            // Range selection visual state
                            Rectangle {
                                visible: root.calendarType === "range" && root._isInRange(model.date)
                                anchors.fill: parent
                                color: Theme.colors.accent100
                                opacity: 0.3
                            }

                            onClicked: function(date) {
                                if (!isDisabled && isCurrentMonth) {
                                    root._handleDateClick(date)
                                }
                            }
                        }
                    }
                }
            }

            // Year picker
            GridView {
                visible: root.calendarType === "year"
                anchors.fill: parent

                model: root._getYearRange()
                cellWidth: width / 4
                cellHeight: height / 5

                delegate: Rectangle {
                    width: GridView.view.cellWidth - Theme.spacing.s1
                    height: GridView.view.cellHeight - Theme.spacing.s1

                    color: root._isYearSelected(modelData) ? Theme.colors.accent500 :
                           mouseArea.containsMouse ? Theme.colors.secondary500 : Theme.colors.transparent
                    radius: Theme.radius.sm

                    Text {
                        anchors.centerIn: parent
                        text: modelData.toString()
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        color: root._isYearSelected(modelData) ? Theme.colors.white500 : Theme.colors.text
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.selectedYear = modelData
                            root._currentYear = modelData
                            root.yearSelected(modelData)
                        }
                    }
                }
            }

            // Month picker
            GridView {
                visible: root.calendarType === "month"
                anchors.fill: parent

                model: 12
                cellWidth: width / 3
                cellHeight: height / 4

                delegate: Rectangle {
                    width: GridView.view.cellWidth - Theme.spacing.s1
                    height: GridView.view.cellHeight - Theme.spacing.s1

                    color: root._isMonthSelected(index) ? Theme.colors.accent500 :
                           mouseArea2.containsMouse ? Theme.colors.secondary500 : Theme.colors.transparent
                    radius: Theme.radius.sm

                    Text {
                        anchors.centerIn: parent
                        text: Qt.locale().monthName(index, Locale.ShortFormat)
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        color: root._isMonthSelected(index) ? Theme.colors.white500 : Theme.colors.text
                    }

                    MouseArea {
                        id: mouseArea2
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.selectedMonth = index
                            root._currentMonth = index
                            root.monthSelected(index, root._currentYear)
                        }
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4
            spacing: Theme.spacing.s3
            Layout.alignment: Qt.AlignHCenter

            // Clear button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s16 * 2
                size: "md"
                variant: "ghost"
                enabled: root._canClear()
                onClicked: root._clearSelection()


                background: Rectangle {
                    color: Theme.colors.transparent
                    radius: parent.radius
                    border.width: 0
                    border.color: "transparent"
                }

                contentItem: Text {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: { TranslationManager.revision; return qsTr("Clear") }
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightRegular
                    color: "white"
                }
            }

            // Apply button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s16 * 2
                size: "md"
                radius: Theme.radius.md
                enabled: root._canApply()
                variant: "primary"


                background: Rectangle {
                    color: Theme.colors.accent500
                    radius: parent.radius
                }

                contentItem: Text {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: { TranslationManager.revision; return qsTr("Apply") }
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightRegular
                    color: "white"
                }

                onClicked: root._applySelection()
            }
        }
    }

    // Private functions
    function _getCalendarHeight() {
        switch (calendarType) {
            case "year": return 320
            case "month": return 280
            default: return 380
        }
    }

    function _getHeaderText() {
        switch (calendarType) {
            case "year": return "Select Year"
            case "month": return root._currentYear.toString()
            default: return Qt.locale().monthName(root._currentMonth) + " " + root._currentYear
        }
    }

    function _navigatePrevious() {
        switch (calendarType) {
            case "year":
                root._currentYear -= 20
                break
            case "month":
                root._currentYear--
                break
            default:
                if (root._currentMonth === 0) {
                    root._currentMonth = 11
                    root._currentYear--
                } else {
                    root._currentMonth--
                }
        }
    }

    function _navigateNext() {
        switch (calendarType) {
            case "year":
                root._currentYear += 20
                break
            case "month":
                root._currentYear++
                break
            default:
                if (root._currentMonth === 11) {
                    root._currentMonth = 0
                    root._currentYear++
                } else {
                    root._currentMonth++
                }
        }
    }

    function _getYearRange() {
        const startYear = Math.floor(root._currentYear / 20) * 20
        const years = []
        for (let i = 0; i < 20; i++) {
            years.push(startYear + i)
        }
        return years
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }

    function _isDateDisabled(date) {
        if (!root.disabledDates || root.disabledDates.length === 0) return false
        if (date < root.minimumDate || date > root.maximumDate) return false
        const dateString = date.toDateString()
        return root.disabledDates.some(d => d.toDateString() === dateString)
    }

    function _isDaySelected(date) {
        if (root.calendarType === "single") {
            return !root._isEmpty(root.selectedDate) &&
                   date.toDateString() === root.selectedDate.toDateString()
        } else if (root.calendarType === "range") {
            if (!root._isEmpty(root.startDate) && date.toDateString() === root.startDate.toDateString()) return true
            if (!root._isEmpty(root.endDate) && date.toDateString() === root.endDate.toDateString()) return true
            if (!root._isEmpty(root._rangeStartTemp) && date.toDateString() === root._rangeStartTemp.toDateString()) return true
        }
        return false
    }

    function _isInRange(date) {
        if (root.calendarType !== "range") return false
        if (root._isEmpty(root.startDate) || root._isEmpty(root.endDate)) return false
        return date >= root.startDate && date <= root.endDate
    }

    function _isYearSelected(year) {
        return year === root.selectedYear
    }

    function _isMonthSelected(month) {
        return month === root.selectedMonth
    }

    function _canClear() {
        switch (calendarType) {
            case "single": return !_isEmpty(selectedDate)
            case "range": return !_isEmpty(startDate) || !_isEmpty(endDate)
            case "year": return selectedYear !== new Date().getFullYear()
            case "month": return selectedMonth !== new Date().getMonth()
            default: return false
        }
    }

    function _canApply() {
        switch (calendarType) {
            case "single": return !_isEmpty(selectedDate)
            case "range": return !_isEmpty(startDate) && !_isEmpty(endDate)
            case "year": return true // Year selection is always valid
            case "month": return true // Month selection is always valid
            default: return false
        }
    }

    function _clearSelection() {
        switch (calendarType) {
            case "single":
                selectedDate = new Date(NaN)
                break
            case "range":
                startDate = new Date(NaN)
                endDate = new Date(NaN)
                _rangeStartTemp = new Date(NaN)
                break
            case "year":
                selectedYear = new Date().getFullYear()
                _currentYear = selectedYear
                break
            case "month":
                selectedMonth = new Date().getMonth()
                _currentMonth = selectedMonth
                break
        }
    }

    function _applySelection() {
        switch (calendarType) {
            case "single":
                if (!_isEmpty(selectedDate)) {
                    dateSelected(selectedDate)
                }
                break
            case "range":
                if (!_isEmpty(startDate) && !_isEmpty(endDate)) {
                    rangeSelected(startDate, endDate)
                }
                break
            case "year":
                yearSelected(selectedYear)
                break
            case "month":
                monthSelected(selectedMonth, _currentYear)
                break
        }
    }

    function _handleDateClick(date) {
        if (root.calendarType === "single") {
            root.selectedDate = date
            // Don't auto-emit signal, wait for Apply button
        } else if (root.calendarType === "range") {
            if (root._isEmpty(root._rangeStartTemp)) {
                // First selection
                root._rangeStartTemp = date
                root.startDate = date
                root.endDate = new Date(NaN)
            } else {
                // Second selection
                if (date >= root._rangeStartTemp) {
                    root.startDate = root._rangeStartTemp
                    root.endDate = date
                } else {
                    root.startDate = date
                    root.endDate = root._rangeStartTemp
                }
                root._rangeStartTemp = new Date(NaN)
                // Don't auto-emit signal, wait for Apply button
            }
        }
    }
}
