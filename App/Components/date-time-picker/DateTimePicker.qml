import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePicker
    \brief Optimized DateTimePicker with strict 540px height adherence

    FIXED: Range mode layout optimized to fit within 540px total height
    - Removed label spacing overhead
    - Compressed time picker containers
    - Maintains 120px time picker area as per Figma
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

    width: 312
    height: 540
    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    radius: Theme.radius.md

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s1

        UI.DatePicker {
            id: datePicker
            Layout.fillWidth: true
            Layout.preferredHeight: 276
            standalone: false
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Theme.colors.transparent

            // Single mode time picker
            UI.TimePicker {
                id: timePicker
                standalone: false
                anchors.fill: parent
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

            RowLayout {
                anchors.fill: parent
                visible: root.mode === "range"
                spacing: Theme.spacing.s2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.colors.transparent

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 2

                        Text {
                            text: qsTr("Start")
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize100
                            font.weight: Theme.typography.weightMedium
                            color: Theme.colors.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // Time picker fits in remaining space
                        UI.TimePicker {
                            id: startTimePicker
                            standalone: false
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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
                }

                // Minimal visual separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: Theme.spacing.s10
                    color: Theme.colors.secondary500
                    radius: 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.colors.transparent

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 2

                        Text {
                            text: qsTr("End")
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize100
                            font.weight: Theme.typography.weightMedium
                            color: Theme.colors.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }

                        UI.TimePicker {
                            id: endTimePicker
                            standalone: false
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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

    // Public API methods - unchanged
    function clearSelection() {
        selectedDate = new Date(NaN)
        startDate = new Date(NaN)
        endDate = new Date(NaN)

        selectedHour = _currentHour
        selectedMinute = _currentMinute
        selectedAMPM = _currentAMPM

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

    // Private helpers - unchanged
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
