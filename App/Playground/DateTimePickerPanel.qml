import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("DatePicker Components Test"))

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            anchors.margins: Theme.spacing.s4
            spacing: Theme.spacing.s6

            // Header
            Text {
                text: (TranslationManager.revision, qsTr("DateTimePicker vs DatePicker Test"))
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // DateTimePicker Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("DateTimePicker Component (Clean Architecture)"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.accent500
                }

                // Basic DateTimePicker
                UI.DateTimePicker {
                    id: dateTimePicker
                    Layout.fillWidth: true
                    Layout.maximumWidth: 400
                    label: (TranslationManager.revision, qsTr("DateTimePicker - Select Date"))
                    required: true
                    placeholderText: "DD/MM/YYYY"

                    onDateSelected: function(date) {
                        dateTimeResult.text = (TranslationManager.revision, qsTr("DateTimePicker Selected: ")) + Qt.formatDate(date, "dd/MM/yyyy")
                        console.log("DateTimePicker - Date selected:", Qt.formatDate(date, "dd/MM/yyyy"))
                    }

                    onCleared: {
                        dateTimeResult.text = (TranslationManager.revision, qsTr("DateTimePicker - Selection cleared"))
                        console.log("DateTimePicker - Selection cleared")
                    }
                }

                Text {
                    id: dateTimeResult
                    text: (TranslationManager.revision, qsTr("No DateTimePicker selection"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.textMuted
                    wrapMode: Text.WordWrap
                }

                // DateTimePicker with constraints
                UI.DateTimePicker {
                    id: constrainedDateTimePicker
                    Layout.fillWidth: true
                    Layout.maximumWidth: 400
                    label: (TranslationManager.revision, qsTr("DateTimePicker - Limited Range"))
                    minimumDate: new Date(2024, 0, 1)
                    maximumDate: new Date(2025, 11, 31)
                    size: "sm"

                    onDateSelected: function(date) {
                        constrainedDateTimeResult.text = (TranslationManager.revision, qsTr("Constrained DateTimePicker: ")) + Qt.formatDate(date, "dd/MM/yyyy")
                    }
                }

                Text {
                    id: constrainedDateTimeResult
                    text: (TranslationManager.revision, qsTr("DateTimePicker with 2024-2025 range"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.textMuted
                    wrapMode: Text.WordWrap
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // DatePicker Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("DatePicker Component (Multiple Modes)"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.accent500
                }

                // Calendar type selector
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s3

                    Text {
                        text: (TranslationManager.revision, qsTr("Calendar Mode:"))
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        color: Theme.colors.text
                    }

                    UI.Button {
                        text: "Single"
                        size: "sm"
                        variant: datePicker.calendarType === "single" ? "primary" : "secondary"
                        onClicked: datePicker.calendarType = "single"
                    }

                    UI.Button {
                        text: "Range"
                        size: "sm"
                        variant: datePicker.calendarType === "range" ? "primary" : "secondary"
                        onClicked: datePicker.calendarType = "range"
                    }

                    UI.Button {
                        text: "Year"
                        size: "sm"
                        variant: datePicker.calendarType === "year" ? "primary" : "secondary"
                        onClicked: datePicker.calendarType = "year"
                    }

                    UI.Button {
                        text: "Month"
                        size: "sm"
                        variant: datePicker.calendarType === "month" ? "primary" : "secondary"
                        onClicked: datePicker.calendarType = "month"
                    }
                }

                // Direct DatePicker component
                UI.DatePicker {
                    id: datePicker
                    Layout.alignment: Qt.AlignHCenter
                    calendarType: "single"

                    onDateSelected: function(date) {
                        datePickerResult.text = (TranslationManager.revision, qsTr("DatePicker Single: ")) + Qt.formatDate(date, "dd/MM/yyyy")
                        console.log("DatePicker - Date selected:", Qt.formatDate(date, "dd/MM/yyyy"))
                    }

                    onRangeSelected: function(startDate, endDate) {
                        datePickerResult.text = (TranslationManager.revision, qsTr("DatePicker Range: ")) +
                                             Qt.formatDate(startDate, "dd/MM/yyyy") + " - " + Qt.formatDate(endDate, "dd/MM/yyyy")
                        console.log("DatePicker - Range selected:", Qt.formatDate(startDate, "dd/MM/yyyy"), "to", Qt.formatDate(endDate, "dd/MM/yyyy"))
                    }

                    onYearSelected: function(year) {
                        datePickerResult.text = (TranslationManager.revision, qsTr("DatePicker Year: ")) + year
                        console.log("DatePicker - Year selected:", year)
                    }

                    onMonthSelected: function(month, year) {
                        datePickerResult.text = (TranslationManager.revision, qsTr("DatePicker Month: ")) +
                                             Qt.locale().monthName(month) + " " + year
                        console.log("DatePicker - Month selected:", Qt.locale().monthName(month), year)
                    }
                }

                Text {
                    id: datePickerResult
                    text: (TranslationManager.revision, qsTr("No DatePicker selection - Use Apply button"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.textMuted
                    wrapMode: Text.WordWrap
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Comparison Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Component Comparison"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.spacing.s6
                    rowSpacing: Theme.spacing.s3

                    // DateTimePicker characteristics
                    Text {
                        text: (TranslationManager.revision, qsTr("DateTimePicker:"))
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightMedium
                        color: Theme.colors.accent500
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s1

                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Clean separation of concerns"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Form-integrated with label/validation"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Input field + popup pattern"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Size variants support"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Single date selection only"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                    }

                    // DatePicker characteristics
                    Text {
                        text: (TranslationManager.revision, qsTr("DatePicker:"))
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightMedium
                        color: Theme.colors.accent500
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s1

                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Multiple selection modes"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Direct calendar component"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Range, year, month selection"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Apply/Clear button pattern"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: "• " + (TranslationManager.revision, qsTr("Self-contained calendar"))
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize125
                            color: Theme.colors.text
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Control buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s3

                Text {
                    text: (TranslationManager.revision, qsTr("Test Controls:"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.text
                    Layout.alignment: Qt.AlignVCenter
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Set Today"))
                    size: "sm"
                    variant: "secondary"
                    onClicked: {
                        const today = new Date()
                        dateTimePicker.selectedDate = today
                        constrainedDateTimePicker.selectedDate = today
                        datePicker.selectedDate = today
                    }
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Clear All"))
                    size: "sm"
                    variant: "ghost"
                    onClicked: {
                        dateTimePicker.selectedDate = new Date(NaN)
                        constrainedDateTimePicker.selectedDate = new Date(NaN)
                        datePicker.selectedDate = new Date(NaN)
                        datePicker.startDate = new Date(NaN)
                        datePicker.endDate = new Date(NaN)

                        dateTimeResult.text = (TranslationManager.revision, qsTr("All selections cleared"))
                        constrainedDateTimeResult.text = (TranslationManager.revision, qsTr("All selections cleared"))
                        datePickerResult.text = (TranslationManager.revision, qsTr("All selections cleared"))
                    }
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Log Comparison"))
                    size: "sm"
                    variant: "primary"
                    onClicked: {
                        console.log("=== Component Comparison ===")
                        console.log("DateTimePicker:")
                        console.log("  - isEmpty:", dateTimePicker.isEmpty, "isValid:", dateTimePicker.isValid)
                        console.log("  - selectedDate:", dateTimePicker.selectedDate)
                        console.log("  - errorMessage:", dateTimePicker.errorMessage)

                        console.log("DatePicker:")
                        console.log("  - calendarType:", datePicker.calendarType)
                        console.log("  - selectedDate:", datePicker.selectedDate)
                        console.log("  - startDate:", datePicker.startDate)
                        console.log("  - endDate:", datePicker.endDate)
                        console.log("  - selectedYear:", datePicker.selectedYear)
                        console.log("  - selectedMonth:", datePicker.selectedMonth)
                        console.log("=============================")
                    }
                }
            }

            // Spacer
            Item { Layout.fillHeight: true }
        }
    }
}
