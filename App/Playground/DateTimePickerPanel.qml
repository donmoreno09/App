import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("DatePicker Test"))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s6

        // Header
        Text {
            text: (TranslationManager.revision, qsTr("Calendar Picker Test"))
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize200
            font.weight: Theme.typography.weightSemibold
            color: Theme.colors.text
        }

        UI.HorizontalDivider { Layout.fillWidth: true }

        // Input field with calendar popup
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s1

            // Label
            Text {
                text: (TranslationManager.revision, qsTr("Select Date")) + " *"
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                font.weight: Theme.typography.weightMedium
                color: Theme.colors.text
            }

            // Input field
            Rectangle {
                id: inputField
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.s10

                color: Theme.colors.primary900
                property bool focused: calendarPopup.opened
                property date selectedDate: new Date(NaN)
                property string placeholderText: "DD/MM/YYYY"
                property string dateFormat: "dd/MM/yyyy"

                // Bottom border (underline effect)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: inputField.focused ? Theme.borders.b2 : Theme.borders.b1
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
                    anchors.margins: Theme.spacing.s3
                    spacing: Theme.spacing.s2

                    // Display text
                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (!inputField.selectedDate || isNaN(inputField.selectedDate.getTime())) {
                                return inputField.placeholderText
                            }
                            return Qt.formatDate(inputField.selectedDate, inputField.dateFormat)
                        }

                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize175
                        font.weight: Theme.typography.weightRegular
                        color: {
                            if (!inputField.selectedDate || isNaN(inputField.selectedDate.getTime())) {
                                return Theme.colors.textMuted
                            }
                            return Theme.colors.text
                        }
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Calendar icon
                    Rectangle {
                        Layout.preferredWidth: Theme.icons.sizeMd
                        Layout.preferredHeight: Theme.icons.sizeMd
                        color: Theme.colors.transparent

                        Image {
                            anchors.centerIn: parent
                            source: "qrc:/App/assets/icons/calendar.svg"
                            width: Theme.icons.sizeMd
                            height: Theme.icons.sizeMd
                            sourceSize.width: Theme.icons.sizeMd
                            sourceSize.height: Theme.icons.sizeMd
                        }
                    }
                }

                // Click handler
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        inputField.focused = true
                        calendarPopup.toggle()
                    }

                    onPressed: inputField.focused = true
                }

                // Calendar popup
                Popup {
                    id: calendarPopup
                    x: 0
                    y: parent.height
                    width: parent.width
                    height: 380

                    modal: false
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    background: Rectangle {
                        color: Theme.colors.transparent
                    }

                    // Calendar picker
                    UI.DatePicker {
                        anchors.fill: parent
                        calendarType: "single"
                        selectedDate: inputField.selectedDate

                        onDateSelected: function(date) {
                            inputField.selectedDate = date
                            resultText.text = (TranslationManager.revision, qsTr("Selected: ")) + Qt.formatDate(date, "dd/MM/yyyy")
                            calendarPopup.close()
                        }
                    }

                    function toggle() {
                        if (opened) {
                            close()
                        } else {
                            open()
                        }
                    }

                    onClosed: {
                        inputField.focused = false
                    }
                }
            }
        }

        // Calendar type selector
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s4

            Text {
                text: (TranslationManager.revision, qsTr("Calendar Type:"))
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.text
            }

            UI.Button {
                text: "Single"
                size: "sm"
                variant: testCalendar.calendarType === "single" ? "primary" : "secondary"
                onClicked: testCalendar.calendarType = "single"
            }

            UI.Button {
                text: "Range"
                size: "sm"
                variant: testCalendar.calendarType === "range" ? "primary" : "secondary"
                onClicked: testCalendar.calendarType = "range"
            }

            UI.Button {
                text: "Year"
                size: "sm"
                variant: testCalendar.calendarType === "year" ? "primary" : "secondary"
                onClicked: testCalendar.calendarType = "year"
            }

            UI.Button {
                text: "Month"
                size: "sm"
                variant: testCalendar.calendarType === "month" ? "primary" : "secondary"
                onClicked: testCalendar.calendarType = "month"
            }
        }

        // Direct calendar test (no input field)
        Text {
            text: (TranslationManager.revision, qsTr("Direct Calendar Test"))
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize175
            font.weight: Theme.typography.weightMedium
            color: Theme.colors.text
        }

        // Test calendar
        UI.DatePicker {
            id: testCalendar
            Layout.alignment: Qt.AlignHCenter
            calendarType: "single"

            onDateSelected: function(date) {
                resultText.text = (TranslationManager.revision, qsTr("Calendar Selected: ")) + Qt.formatDate(date, "dd/MM/yyyy")
                console.log("Date selected:", Qt.formatDate(date, "dd/MM/yyyy"))
            }

            onRangeSelected: function(startDate, endDate) {
                resultText.text = (TranslationManager.revision, qsTr("Range Selected: ")) +
                                 Qt.formatDate(startDate, "dd/MM/yyyy") + " - " + Qt.formatDate(endDate, "dd/MM/yyyy")
                console.log("Range selected:", Qt.formatDate(startDate, "dd/MM/yyyy"), "to", Qt.formatDate(endDate, "dd/MM/yyyy"))
            }

            onYearSelected: function(year) {
                resultText.text = (TranslationManager.revision, qsTr("Year Selected: ")) + year
                console.log("Year selected:", year)
            }

            onMonthSelected: function(month, year) {
                resultText.text = (TranslationManager.revision, qsTr("Month Selected: ")) +
                                 Qt.locale().monthName(month) + " " + year
                console.log("Month selected:", Qt.locale().monthName(month), year)
            }
        }

        // Result display
        Text {
            id: resultText
            text: (TranslationManager.revision, qsTr("No selection made"))
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.textMuted
            wrapMode: Text.WordWrap
        }

        // Spacer
        Item { Layout.fillHeight: true }
    }
}
