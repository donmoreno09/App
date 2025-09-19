import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype TimePicker
    \brief Optimized TimePicker with exact dimensions and proper arrow controls
*/

Rectangle {
    id: root

    // Public API
    property bool is24Hour: true
    property int selectedHour: 12
    property int selectedMinute: 0
    property bool selectedAMPM: true // true = AM, false = PM

    // Signals
    signal timeSelected(int hour, int minute, bool isAM)

    // Exact dimensions from design
    width: 280
    height: 110
    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    radius: Theme.radius.md

    // Time column component
    component TimeColumn: ColumnLayout {
        property string label: ""
        property string displayValue: ""
        property int displayFontSize: Theme.typography.fontSize200
        signal upClicked()
        signal downClicked()

        Layout.preferredWidth: 40
        Layout.preferredHeight: 110
        spacing: 0

        // Up arrow
        UI.Button {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            variant: "ghost"
            display: AbstractButton.IconOnly

            icon.source: "qrc:/App/assets/icons/chevron-up.svg"
            icon.width: 14
            icon.height: 8
            icon.color: Theme.colors.text

            onClicked: upClicked()
        }

        // Display value
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            color: Qt.darker(Theme.colors.grey500, 1.5)
            radius: Theme.radius.sm

            Text {
                anchors.centerIn: parent
                text: displayValue
                font.family: Theme.typography.familySans
                font.pixelSize: displayFontSize
                font.weight: Theme.typography.weightMedium
                color: Theme.colors.text
            }
        }

        // Down arrow
        UI.Button {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            variant: "ghost"
            display: AbstractButton.IconOnly

            icon.source: "qrc:/App/assets/icons/chevron-down.svg"
            icon.width: 14
            icon.height: 8
            icon.color: Theme.colors.text

            onClicked: downClicked()
        }
    }

    // Separator component
    component TimeSeparator: Text {
        Layout.preferredWidth: 8
        Layout.alignment: Qt.AlignVCenter
        text: ":"
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize250
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        // Time selection area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            Layout.preferredHeight: 168
            color: Theme.colors.transparent

            RowLayout {
                anchors.centerIn: parent
                spacing: root.is24Hour ? Theme.spacing.s4 : Theme.spacing.s2

                // Hour column
                TimeColumn {
                    label: qsTr("Hour")
                    displayValue: root.selectedHour.toString().padStart(2, '0')
                    onUpClicked: root._incrementHour()
                    onDownClicked: root._decrementHour()
                }

                // First separator
                TimeSeparator {}

                // Minute column
                TimeColumn {
                    label: qsTr("Min")
                    displayValue: root.selectedMinute.toString().padStart(2, '0')
                    onUpClicked: root._incrementMinute()
                    onDownClicked: root._decrementMinute()
                }

                // Second separator (12H mode only)
                TimeSeparator {
                    visible: !root.is24Hour
                }

                // AM/PM column (12H mode only)
                TimeColumn {
                    visible: !root.is24Hour
                    label: qsTr("AM/PM")
                    displayValue: root.selectedAMPM ? "AM" : "PM"
                    displayFontSize: Theme.typography.fontSize150
                    onUpClicked: root._toggleAMPM()
                    onDownClicked: root._toggleAMPM()
                }
            }
        }

        // Action buttons - this is needed when using the time picker as a lone-component,
        // But when Date Picker and Time Picker are used in a single container
        // This should be commented out

        // UI.DatePickerActions {
        //     Layout.fillWidth: true
        //     mode: "single"
        //     canClear: true
        //     canApply: true
        //     onClearClicked: root._clearSelection()
        //     onApplyClicked: root._applySelection()
        // }
    }

    Component.onCompleted: {
        setCurrentTime()
    }

    // Helper functions - grouped by functionality
    function _incrementHour() {
        selectedHour = is24Hour ? (selectedHour + 1) % 24 :
                     selectedHour >= 12 ? 1 : selectedHour + 1
    }

    function _decrementHour() {
        selectedHour = is24Hour ? (selectedHour <= 0 ? 23 : selectedHour - 1) :
                     (selectedHour <= 1 ? 12 : selectedHour - 1)
    }

    function _incrementMinute() {
        selectedMinute = (selectedMinute + 1) % 60
    }

    function _decrementMinute() {
        selectedMinute = selectedMinute <= 0 ? 59 : selectedMinute - 1
    }

    function _toggleAMPM() {
        selectedAMPM = !selectedAMPM
    }

    function _clearSelection() {
        selectedHour = is24Hour ? 0 : 12
        selectedMinute = 0
        selectedAMPM = true
    }

    function _applySelection() {
        timeSelected(selectedHour, selectedMinute, selectedAMPM)
    }

    function setCurrentTime() {
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

    function getFormattedTime() {
        const hourStr = selectedHour.toString().padStart(2, '0')
        const minuteStr = selectedMinute.toString().padStart(2, '0')

        return is24Hour ? `${hourStr}:${minuteStr}` :
               `${hourStr}:${minuteStr} ${selectedAMPM ? "AM" : "PM"}`
    }
}
