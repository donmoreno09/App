import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePicker
    \brief Combined date and time picker in a single view (no tabs)

    Features:
    - Date selection (single or range)
    - Time selection with 24H/12H support
    - Unified Apply / Clear actions
    - Compact, consistent layout
*/

Rectangle {
    id: root

    // Public API
    property string mode: "single" // "single" or "range"
    property bool is24Hour: true

    // Date properties
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)
    property date endDate: new Date(NaN)

    // Time properties
    property int selectedHour: 12
    property int selectedMinute: 0
    property bool selectedAMPM: true // true = AM, false = PM

    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []

    // Signals
    signal dateTimeSelected(date dateTime)
    signal dateTimeRangeSelected(date startDateTime, date endDateTime)

    // Styling
    width: 312
    height: 450
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
            Layout.fillHeight: true
            mode: root.mode

            selectedDate: root.selectedDate
            startDate: root.startDate
            endDate: root.endDate

            minimumDate: root.minimumDate
            maximumDate: root.maximumDate
            disabledDates: root.disabledDates

            onDateSelected: (date) => root.selectedDate = date
            onRangeSelected: (startDate, endDate) => {
                root.startDate = startDate
                root.endDate = endDate
            }

            // Hide internal actions, handled at this level
            Component.onCompleted: {
                for (let i = 0; i < children.length; i++) {
                    const child = children[i]
                    if (child.toString().indexOf("DatePickerActions") !== -1) {
                        child.visible = false
                    }
                }
            }
        }

        // Time picker
        UI.TimePicker {
            id: timePicker
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s16

            is24Hour: root.is24Hour
            selectedHour: root.selectedHour
            selectedMinute: root.selectedMinute
            selectedAMPM: root.selectedAMPM

            onTimeSelected: (hour, minute, isAM) => {
                root.selectedHour = hour
                root.selectedMinute = minute
                root.selectedAMPM = isAM
            }

            // Hide internal actions
            Component.onCompleted: {
                for (let i = 0; i < children.length; i++) {
                    const child = children[i]
                    if (child.toString().indexOf("DatePickerActions") !== -1) {
                        child.visible = false
                    }
                }
            }
        }

        // Unified actions
        UI.DatePickerActions {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s2

            mode: root.mode
            canClear: root._canClear()
            canApply: root._canApply()

            onClearClicked: root._clearSelection()
            onApplyClicked: root._applySelection()
        }
    }

    // --- Private helpers ---
    function _canClear() {
        if (mode === "single") {
            return !_isEmpty(selectedDate) || selectedHour !== -1 || selectedMinute !== -1
        }
        if (mode === "range") {
            return !_isEmpty(startDate) || !_isEmpty(endDate) || selectedHour !== -1 || selectedMinute !== -1
        }
        return false
    }

    function _canApply() {
        if (mode === "single") {
            return !_isEmpty(selectedDate) && selectedHour !== -1 && selectedMinute !== -1
        }
        if (mode === "range") {
            return !_isEmpty(startDate) && !_isEmpty(endDate) && selectedHour !== -1 && selectedMinute !== -1
        }
        return false
    }

    function _clearSelection() {
        selectedDate = new Date(NaN)
        startDate = new Date(NaN)
        endDate = new Date(NaN)
        selectedHour = is24Hour ? 0 : 12
        selectedMinute = 0
        selectedAMPM = true
    }

    function _applySelection() {
        if (mode === "single" && !_isEmpty(selectedDate) && selectedHour !== -1 && selectedMinute !== -1) {
            const dateTime = _combineDateTime(selectedDate, selectedHour, selectedMinute, selectedAMPM)
            dateTimeSelected(dateTime)
        } else if (mode === "range" && !_isEmpty(startDate) && !_isEmpty(endDate) && selectedHour !== -1 && selectedMinute !== -1) {
            const startDateTime = _combineDateTime(startDate, selectedHour, selectedMinute, selectedAMPM)
            const endDateTime = _combineDateTime(endDate, selectedHour, selectedMinute, selectedAMPM)
            dateTimeRangeSelected(startDateTime, endDateTime)
        }
    }

    function _combineDateTime(date, hour, minute, isAM) {
        const result = new Date(date)
        let finalHour = hour

        if (!is24Hour) {
            if (isAM && hour === 12) {
                finalHour = 0
            } else if (!isAM && hour !== 12) {
                finalHour = hour + 12
            }
        }

        result.setHours(finalHour, minute, 0, 0)
        return result
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }

    // Initialize with current time
    Component.onCompleted: {
        const now = new Date()
        selectedMinute = now.getMinutes()

        if (is24Hour) {
            selectedHour = now.getHours()
        } else {
            const hour24 = now.getHours()
            selectedAMPM = hour24 < 12
            selectedHour = hour24 === 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        }
    }
}
