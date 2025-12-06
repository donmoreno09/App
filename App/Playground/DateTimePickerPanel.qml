import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Date & Time Picker Test")

    // Micro-component: Reusable Input Field
    component PickerInputField: Rectangle {
        id: inputRoot

        // Public API
        property string label: ""
        property string placeholder: ""
        property string displayText: ""
        property string iconSource: "qrc:/App/assets/icons/calendar.svg"
        property bool focused: false
        property bool required: false

        // Signals
        signal clicked()

        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.preferredHeight: Theme.spacing.s10
        color: Theme.colors.primary900

        // Bottom border (underline effect)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: inputRoot.focused ? Theme.borders.b2 : Theme.borders.b1
            color: "white"

            Behavior on height {
                NumberAnimation {
                    duration: Theme.motion.panelTransitionMs
                    easing.type: Theme.motion.panelTransitionEasing
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.s3
            anchors.rightMargin: Theme.spacing.s3
            anchors.topMargin: Theme.spacing.s3
            spacing: Theme.spacing.s2

            // Display text
            Text {
                Layout.fillWidth: true
                text: inputRoot.displayText || inputRoot.placeholder
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize175
                font.weight: Theme.typography.weightRegular
                color: inputRoot.displayText ? Theme.colors.text : Theme.colors.textMuted
                verticalAlignment: Text.AlignVCenter
            }

            // Icon
            Image {
                Layout.preferredWidth: Theme.icons.sizeMd
                Layout.preferredHeight: Theme.icons.sizeMd
                source: inputRoot.iconSource
            }
        }

        // Click handler
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: inputRoot.clicked()
        }
    }

    // Micro-component: Section Header
    component SectionHeader: Text {
        property string title: ""
        text: title
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize175
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.accent500
        Layout.fillWidth: true
    }

    // Micro-component: Field Label
    component FieldLabel: Text {
        property string title: ""
        property bool required: false
        text: title + (required ? " *" : "")
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        Layout.fillWidth: true
    }

    // Micro-component: Result Display
    component ResultText: Text {
        property string result: ""
        text: result
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        color: Theme.colors.textMuted
        Layout.fillWidth: true
    }

    // Micro-component: Picker Popup
    component PickerPopup: Popup {
        property alias pickerContent: contentLoader.sourceComponent
        property string currentView: "calendar"

        x: 0
        y: parent.height
        width: parent.width
        height: {
            switch(currentView){
            case "calendar": return 540
            case "year": return 296
            case "month": return 296
            default: return 540
            }
        }

        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.colors.transparent
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
        }

        function toggle() {
            if (opened) {
                close()
            } else {
                open()
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            anchors.fill: parent
            anchors.margins: Theme.spacing.s6
            spacing: Theme.spacing.s6

            // Header
            Text {
                text: `${TranslationManager.revision}` && qsTr("Date & Time Picker Components")
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 5. DateTime Selection (Combined)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: `${TranslationManager.revision}` && qsTr("DateTime Selection (Combined)")
                }

                FieldLabel {
                    title: `${TranslationManager.revision}` && qsTr("Select Date & Time")
                    required: true
                }

                PickerInputField {
                    id: dateTimeInput
                    placeholder: "DD/MM/YYYY HH:MM"
                    iconSource: "qrc:/App/assets/icons/calendar.svg"
                    focused: dateTimePopup.opened

                    property date selectedDateTime: new Date(NaN)
                    displayText: !isNaN(selectedDateTime.getTime()) ?
                               Qt.formatDateTime(selectedDateTime, "dd/MM/yyyy hh:mm") : ""

                    onClicked: dateTimePopup.toggle()

                    PickerPopup {
                        id: dateTimePopup
                        height: 500 // DateTimePicker height
                        pickerContent: Component {
                            UI.DateTimePicker {
                                mode: "single"
                                is24Hour: true

                                // NEW: Use the optimized signals
                                onSelectionChanged: {
                                    // Live update as user selects date/time
                                    if (hasValidSelection) {
                                        dateTimeInput.selectedDateTime = currentDateTime
                                        dateTimeResult.result = `${TranslationManager.revision}` && qsTr("Live Preview: ") +
                                                              Qt.formatDateTime(currentDateTime, "dd/MM/yyyy hh:mm")
                                    } else {
                                        dateTimeResult.result = `${TranslationManager.revision}` && qsTr("Select date and time...")
                                    }
                                }

                                // Final confirmation when Apply is clicked
                                onDateTimeApplied: function(dateTime) {
                                    dateTimeInput.selectedDateTime = dateTime
                                    dateTimeResult.result = `${TranslationManager.revision}` && qsTr("Applied: ") +
                                                          Qt.formatDateTime(dateTime, "dd/MM/yyyy hh:mm")
                                    dateTimePopup.close()
                                }

                                // When user clears selection
                                onSelectionCleared: {
                                    dateTimeInput.selectedDateTime = new Date(NaN)
                                    dateTimeResult.result = `${TranslationManager.revision}` && qsTr("Selection cleared")
                                }
                            }
                        }
                        onClosed: dateTimeInput.focused = false
                    }
                }

                ResultText {
                    id: dateTimeResult
                    result: `${TranslationManager.revision}` && qsTr("No datetime selected")
                }
            }

                // Replace the DateTime Range Selection section in your test page:

                // 6. DateTime Range Selection (Combined)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    SectionHeader {
                        title: `${TranslationManager.revision}` && qsTr("DateTime Range Selection (Combined)")
                    }

                    FieldLabel {
                        title: `${TranslationManager.revision}` && qsTr("Select Date & Time Range")
                        required: true
                    }

                    PickerInputField {
                        id: dateTimeRangeInput
                        placeholder: "DD/MM/YYYY HH:MM - DD/MM/YYYY HH:MM"
                        iconSource: "qrc:/App/assets/icons/calendar.svg"
                        focused: dateTimeRangePopup.opened

                        property date startDateTime: new Date(NaN)
                        property date endDateTime: new Date(NaN)

                        displayText: {
                            const hasStart = !isNaN(startDateTime.getTime())
                            const hasEnd = !isNaN(endDateTime.getTime())

                            if (!hasStart && !hasEnd) return ""
                            if (hasStart && hasEnd) {
                                return Qt.formatDateTime(startDateTime, "dd/MM/yyyy hh:mm") + " - " +
                                       Qt.formatDateTime(endDateTime, "dd/MM/yyyy hh:mm")
                            }
                            if (hasStart) return Qt.formatDateTime(startDateTime, "dd/MM/yyyy hh:mm") + " - ..."
                            return ""
                        }

                        onClicked: dateTimeRangePopup.toggle()

                        PickerPopup {
                            id: dateTimeRangePopup
                            height: 500 // DateTimePicker height
                            pickerContent: Component {
                                UI.DateTimePicker {
                                    id: rangeDateTime
                                    mode: "range"
                                    is24Hour: true

                                    // Live update as user selects dates/time
                                    onSelectionChanged: {

                                        if (hasValidSelection) {
                                            // Use the DateTimePicker's built-in currentDateTime for start
                                            const startDT = _combineDateTime(startDate, selectedHour, selectedMinute, selectedAMPM)
                                            const endDT = _combineDateTime(endDate, endHour, endMinute, endAMPM)

                                            if (!isNaN(startDT.getTime()) && !isNaN(endDT.getTime())) {
                                                dateTimeRangeInput.startDateTime = startDT
                                                dateTimeRangeInput.endDateTime = endDT

                                                dateTimeRangeResult.result = `${TranslationManager.revision}` && qsTr("Live Preview: ") +
                                                                           Qt.formatDateTime(startDT, "dd/MM/yyyy hh:mm") + " - " +
                                                                           Qt.formatDateTime(endDT, "dd/MM/yyyy hh:mm")
                                            }
                                        } else {
                                            // Show partial selection feedback
                                            if (!isNaN(startDate.getTime()) && isNaN(endDate.getTime())) {
                                                dateTimeRangeResult.result = `${TranslationManager.revision}` && qsTr("Start date selected, choose end date...")
                                            } else {
                                                dateTimeRangeResult.result = `${TranslationManager.revision}` && qsTr("Select date range and time...")
                                            }
                                        }
                                    }

                                    // Final confirmation when Apply is clicked
                                    onRangeApplied: function(startDateTime, endDateTime) {
                                        dateTimeRangeInput.startDateTime = startDateTime
                                        dateTimeRangeInput.endDateTime = endDateTime
                                        dateTimeRangeResult.result = `${TranslationManager.revision}` && qsTr("Applied Range: ") +
                                                                   Qt.formatDateTime(startDateTime, "dd/MM/yyyy hh:mm") + " - " +
                                                                   Qt.formatDateTime(endDateTime, "dd/MM/yyyy hh:mm")
                                        dateTimeRangePopup.close()
                                    }

                                    // When user clears selection
                                    onSelectionCleared: {
                                        dateTimeRangeInput.startDateTime = new Date(NaN)
                                        dateTimeRangeInput.endDateTime = new Date(NaN)
                                        dateTimeRangeResult.result = `${TranslationManager.revision}` && qsTr("Range selection cleared")
                                    }
                                }
                            }
                            onClosed: dateTimeRangeInput.focused = false
                        }
                    }

                    ResultText {
                        id: dateTimeRangeResult
                        result: `${TranslationManager.revision}` && qsTr("No datetime range selected")
                    }
                }

            // Spacer
            Item { Layout.preferredHeight: Theme.spacing.s6 }
        }
    }
}
