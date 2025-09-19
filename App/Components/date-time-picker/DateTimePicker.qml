import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePicker
    \brief Optimized combined date and time picker with robust time picker integration

    Features:
    - Single/range date selection with immediate validation
    - 24H/12H time support with proper defaults
    - Clean signal architecture with both intermediate and final events
    - Robust time picker integration that handles missing signals
    - Independent time pickers for range mode
*/

Rectangle {
    id: root

    // Public API
    property string mode: "single" // "single" or "range"
    property bool is24Hour: true

    // Date properties - these update immediately when user selects
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)
    property date endDate: new Date(NaN)

    // Time properties - always valid, initialized to current time
    property int selectedHour: _currentHour
    property int selectedMinute: _currentMinute
    property bool selectedAMPM: _currentAMPM

    // End time properties with guaranteed different initial values
    property int endHour: _nextHour
    property int endMinute: _currentMinute
    property bool endAMPM: _nextAMPM

    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []

    // Signals - clean separation of concerns
    signal selectionChanged() // Fires on any selection change (immediate feedback)
    signal dateTimeApplied(date dateTime) // Final confirmation for single mode
    signal rangeApplied(date startDateTime, date endDateTime) // Final confirmation for range mode
    signal selectionCleared() // When user clears selection

    // Read-only computed properties for external binding
    readonly property bool hasValidSelection: mode === "single" ? !_isEmpty(selectedDate) : (!_isEmpty(startDate) && !_isEmpty(endDate))
    readonly property bool canClear: mode === "single" ? !_isEmpty(selectedDate) : (!_isEmpty(startDate) || !_isEmpty(endDate))
    readonly property date currentDateTime: hasValidSelection ? _combineDateTime(selectedDate, selectedHour, selectedMinute, selectedAMPM) : new Date(NaN)

    // Private properties for current time initialization
    readonly property int _currentHour: {
        const now = new Date()
        return is24Hour ? now.getHours() : _to12Hour(now.getHours())
    }
    readonly property int _currentMinute: new Date().getMinutes()
    readonly property bool _currentAMPM: new Date().getHours() < 12

    // Private properties for end time (always 1 hour ahead)
    readonly property int _nextHour: {
        const now = new Date()
        const nextHour24 = now.getHours() + 1
        const wrappedHour24 = nextHour24 > 23 ? 0 : nextHour24
        return is24Hour ? wrappedHour24 : _to12Hour(wrappedHour24)
    }
    readonly property bool _nextAMPM: {
        const now = new Date()
        const nextHour24 = now.getHours() + 1
        const wrappedHour24 = nextHour24 > 23 ? 0 : nextHour24
        return wrappedHour24 < 12
    }

    // Styling
    width: 312
    height: 540
    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    radius: Theme.radius.md

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        // Date picker
        UI.DatePicker {
            id: datePicker
            Layout.fillWidth: true
            Layout.preferredHeight:  276
            mode: root.mode

            selectedDate: root.selectedDate
            startDate: root.startDate
            endDate: root.endDate
            minimumDate: root.minimumDate
            maximumDate: root.maximumDate
            disabledDates: root.disabledDates

            onDateSelected: (date) => {
                root.selectedDate = date
                root.selectionChanged()
            }

            onRangeSelected: (start, end) => {
                root.startDate = start
                root.endDate = end
                root.selectionChanged()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: Theme.borders.b1
            color: Theme.colors.grey400
        }

        // Time picker for single mode
        UI.TimePicker {
            id: timePicker
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            visible: root.mode === "single"

            is24Hour: root.is24Hour

            Component.onCompleted: {
                selectedHour = root.selectedHour
                selectedMinute = root.selectedMinute
                selectedAMPM = root.selectedAMPM
            }

            onTimeSelected: (hour, minute, isAM) => {
                root.selectedHour = hour
                root.selectedMinute = minute
                root.selectedAMPM = isAM
                root.selectionChanged()
            }

            // Monitor property changes directly
            onSelectedHourChanged: {
                root.selectedHour = selectedHour
                root.selectionChanged()
            }
            onSelectedMinuteChanged: {
                root.selectedMinute = selectedMinute
                root.selectionChanged()
            }
            onSelectedAMPMChanged: {
                root.selectedAMPM = selectedAMPM
                root.selectionChanged()
            }
        }

        // Two independent TimePickers for range mode with polling fallback
        RowLayout {
            visible: root.mode === "range"
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            spacing: Theme.spacing.s3

            // Start Time Picker Container
            ColumnLayout {
                Layout.fillWidth: true

                Text {
                    text: qsTr("Start Time")
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize125
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.textMuted
                    Layout.alignment: Qt.AlignHCenter
                }

                UI.TimePicker {
                    id: startTimePicker
                    Layout.fillWidth: true
                    is24Hour: root.is24Hour

                    Component.onCompleted: {
                        selectedHour = root.selectedHour
                        selectedMinute = root.selectedMinute
                        selectedAMPM = root.selectedAMPM
                    }

                    onTimeSelected: (hour, minute, isAM) => {
                        root.selectedHour = hour
                        root.selectedMinute = minute
                        root.selectedAMPM = isAM
                        root.selectionChanged()
                    }

                    // Monitor property changes directly
                    onSelectedHourChanged: {
                        root.selectedHour = selectedHour
                        root.selectionChanged()
                    }
                    onSelectedMinuteChanged: {
                        root.selectedMinute = selectedMinute
                        root.selectionChanged()
                    }
                    onSelectedAMPMChanged: {
                        root.selectedAMPM = selectedAMPM
                        root.selectionChanged()
                    }
                }
            }

            // Visual separator
            Rectangle {
                Layout.preferredWidth: 2
                Layout.preferredHeight: Theme.spacing.s12
                color: Theme.colors.secondary500
                radius: 1
            }

            // End Time Picker Container with polling fallback
            ColumnLayout {
                Layout.fillWidth: true

                Text {
                    text: qsTr("End Time")
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize125
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.textMuted
                    Layout.alignment: Qt.AlignHCenter
                }

                UI.TimePicker {
                    id: endTimePicker
                    Layout.fillWidth: true
                    is24Hour: root.is24Hour

                    Component.onCompleted: {
                        selectedHour = root.endHour
                        selectedMinute = root.endMinute
                        selectedAMPM = root.endAMPM
                    }

                    onTimeSelected: (hour, minute, isAM) => {
                        root.endHour = hour
                        root.endMinute = minute
                        root.endAMPM = isAM
                        root.selectionChanged()
                    }

                    // Monitor property changes directly
                    onSelectedHourChanged: {
                        root.endHour = selectedHour
                        root.selectionChanged()
                    }
                    onSelectedMinuteChanged: {
                        root.endMinute = selectedMinute
                        root.selectionChanged()
                    }
                    onSelectedAMPMChanged: {
                        root.endAMPM = selectedAMPM
                        root.selectionChanged()
                    }
                }
            }
        }

        // Action buttons
        UI.DatePickerActions {
            Layout.fillWidth: true
            mode: root.mode
            canClear: root.canClear
            canApply: root.hasValidSelection

            onClearClicked: root.clearSelection()
            onApplyClicked: root.applySelection()
        }
    }

    // Public API methods
    function clearSelection() {
        selectedDate = new Date(NaN)
        startDate = new Date(NaN)
        endDate = new Date(NaN)

        // Reset start time to current time
        selectedHour = _currentHour
        selectedMinute = _currentMinute
        selectedAMPM = _currentAMPM

        // Reset end time to next hour (different from start)
        endHour = _nextHour
        endMinute = _currentMinute
        endAMPM = _nextAMPM

        selectionCleared()
        selectionChanged()
    }

    function applySelection() {
        if (!hasValidSelection) return

        if (mode === "single") {
            const dateTime = _combineDateTime(selectedDate, selectedHour, selectedMinute, selectedAMPM)
            dateTimeApplied(dateTime)
        } else if (mode === "range") {
            const startDateTime = _combineDateTime(startDate, selectedHour, selectedMinute, selectedAMPM)
            const endDateTime = _combineDateTime(endDate, endHour, endMinute, endAMPM)
            rangeApplied(startDateTime, endDateTime)
        }
    }

    function setDateTime(dateTime) {
        if (_isEmpty(dateTime)) return

        selectedDate = new Date(dateTime)
        selectedHour = is24Hour ? dateTime.getHours() : _to12Hour(dateTime.getHours())
        selectedMinute = dateTime.getMinutes()
        selectedAMPM = dateTime.getHours() < 12
        selectionChanged()
    }

    function setDateRange(start, end) {
        if (_isEmpty(start) || _isEmpty(end)) return

        startDate = new Date(start)
        endDate = new Date(end)
        selectionChanged()
    }

    // Private helpers - clean and focused
    function _combineDateTime(date, hour, minute, isAM) {
        if (_isEmpty(date)) return new Date(NaN)

        const result = new Date(date)
        let finalHour = hour

        if (!is24Hour) {
            finalHour = _to24Hour(hour, isAM)
        }

        result.setHours(finalHour, minute, 0, 0)
        return result
    }

    function _to12Hour(hour24) {
        if (hour24 === 0) return 12
        if (hour24 > 12) return hour24 - 12
        return hour24
    }

    function _to24Hour(hour12, isAM) {
        if (isAM && hour12 === 12) return 0
        if (!isAM && hour12 !== 12) return hour12 + 12
        return hour12
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }
}
