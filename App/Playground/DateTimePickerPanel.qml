import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("DatePicker Input Field Test"))

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
                text: (TranslationManager.revision, qsTr("DatePicker with Input Field"))
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Single Date Input Field
            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: Theme.spacing.s4

            //     Text {
            //         text: (TranslationManager.revision, qsTr("Single Date Selection"))
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize175
            //         font.weight: Theme.typography.weightMedium
            //         color: Theme.colors.accent500
            //     }

            //     // Label
            //     Text {
            //         text: (TranslationManager.revision, qsTr("Select Date")) + " *"
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize150
            //         font.weight: Theme.typography.weightMedium
            //         color: Theme.colors.text
            //     }

            //     // Input field for single date
            //     Rectangle {
            //         id: singleInputField
            //         Layout.fillWidth: true
            //         Layout.maximumWidth: 400
            //         Layout.preferredHeight: Theme.spacing.s10

            //         color: Theme.colors.primary900
            //         property bool focused: singlePopup.opened
            //         property date selectedDate: new Date(NaN)
            //         property string placeholderText: "DD/MM/YYYY"
            //         property string dateFormat: "dd/MM/yyyy"

            //         // Bottom border (underline effect)
            //         Rectangle {
            //             anchors.bottom: parent.bottom
            //             anchors.left: parent.left
            //             anchors.right: parent.right
            //             height: singleInputField.focused ? Theme.borders.b2 : Theme.borders.b1
            //             color: "white"

            //             Behavior on height {
            //                 NumberAnimation {
            //                     duration: Theme.motion.panelTransitionMs
            //                     easing.type: Theme.motion.panelTransitionEasing
            //                 }
            //             }
            //         }

            //         RowLayout {
            //             anchors.fill: parent
            //             anchors.leftMargin: Theme.spacing.s3
            //             anchors.rightMargin: Theme.spacing.s3
            //             anchors.topMargin: Theme.spacing.s3
            //             spacing: Theme.spacing.s2

            //             // Display text
            //             Text {
            //                 Layout.fillWidth: true
            //                 text: {
            //                     if (!singleInputField.selectedDate || isNaN(singleInputField.selectedDate.getTime())) {
            //                         return singleInputField.placeholderText
            //                     }
            //                     return Qt.formatDate(singleInputField.selectedDate, singleInputField.dateFormat)
            //                 }

            //                 font.family: Theme.typography.familySans
            //                 font.pixelSize: Theme.typography.fontSize175
            //                 font.weight: Theme.typography.weightRegular
            //                 color: {
            //                     if (!singleInputField.selectedDate || isNaN(singleInputField.selectedDate.getTime())) {
            //                         return Theme.colors.textMuted
            //                     }
            //                     return Theme.colors.text
            //                 }
            //                 verticalAlignment: Text.AlignVCenter
            //             }

            //             // Calendar icon
            //             Image {
            //                 Layout.preferredWidth: Theme.icons.sizeMd
            //                 Layout.preferredHeight: Theme.icons.sizeMd
            //                 source: "qrc:/App/assets/icons/calendar.svg"
            //             }
            //         }

            //         // Click handler
            //         MouseArea {
            //             anchors.fill: parent
            //             cursorShape: Qt.PointingHandCursor

            //             onClicked: {
            //                 singleInputField.focused = true
            //                 singlePopup.toggle()
            //             }
            //         }

            //         // DatePicker popup
            //         Popup {
            //             id: singlePopup
            //             x: 0
            //             y: parent.height
            //             width: parent.width
            //             height: 400

            //             modal: false
            //             focus: true
            //             closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            //             background: Rectangle {
            //                 color: Theme.colors.transparent
            //             }

            //             UI.DatePicker {
            //                 anchors.fill: parent
            //                 mode: "single"
            //                 selectedDate: singleInputField.selectedDate

            //                 onDateSelected: function(date) {
            //                     singleInputField.selectedDate = date
            //                     singleResult.text = (TranslationManager.revision, qsTr("Single Date: ")) + Qt.formatDate(date, "dd/MM/yyyy")
            //                     singlePopup.close()
            //                 }
            //             }

            //             function toggle() {
            //                 if (opened) {
            //                     close()
            //                 } else {
            //                     open()
            //                 }
            //             }

            //             onClosed: {
            //                 singleInputField.focused = false
            //             }
            //         }
            //     }

            //     Text {
            //         id: singleResult
            //         text: (TranslationManager.revision, qsTr("No single date selected"))
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize150
            //         color: Theme.colors.textMuted
            //     }
            // }

            // UI.HorizontalDivider { Layout.fillWidth: true }

            // // Range Date Input Field
            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: Theme.spacing.s4

            //     Text {
            //         text: (TranslationManager.revision, qsTr("Date Range Selection"))
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize175
            //         font.weight: Theme.typography.weightMedium
            //         color: Theme.colors.accent500
            //     }

            //     // Label
            //     Text {
            //         text: (TranslationManager.revision, qsTr("Select Date Range")) + " *"
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize150
            //         font.weight: Theme.typography.weightMedium
            //         color: Theme.colors.text
            //     }

            //     // Input field for range
            //     Rectangle {
            //         id: rangeInputField
            //         Layout.fillWidth: true
            //         Layout.maximumWidth: 400
            //         Layout.preferredHeight: Theme.spacing.s10

            //         color: Theme.colors.primary900
            //         property bool focused: rangePopup.opened
            //         property date startDate: new Date(NaN)
            //         property date endDate: new Date(NaN)
            //         property string placeholderText: "DD/MM/YYYY - DD/MM/YYYY"
            //         property string dateFormat: "dd/MM/yyyy"

            //         // Bottom border (underline effect)
            //         Rectangle {
            //             anchors.bottom: parent.bottom
            //             anchors.left: parent.left
            //             anchors.right: parent.right
            //             height: rangeInputField.focused ? Theme.borders.b2 : Theme.borders.b1
            //             color: "white"

            //             Behavior on height {
            //                 NumberAnimation {
            //                     duration: Theme.motion.panelTransitionMs
            //                     easing.type: Theme.motion.panelTransitionEasing
            //                 }
            //             }
            //         }

            //         RowLayout {
            //             anchors.fill: parent
            //             anchors.leftMargin: Theme.spacing.s3
            //             anchors.rightMargin: Theme.spacing.s3
            //             anchors.topMargin: Theme.spacing.s3
            //             anchors.bottomMargin: 0
            //             spacing: Theme.spacing.s2

            //             // Display text
            //             Text {
            //                 Layout.fillWidth: true
            //                 text: {
            //                     const hasStart = rangeInputField.startDate && !isNaN(rangeInputField.startDate.getTime())
            //                     const hasEnd = rangeInputField.endDate && !isNaN(rangeInputField.endDate.getTime())

            //                     if (!hasStart && !hasEnd) {
            //                         return rangeInputField.placeholderText
            //                     } else if (hasStart && hasEnd) {
            //                         return Qt.formatDate(rangeInputField.startDate, rangeInputField.dateFormat) +
            //                                " - " + Qt.formatDate(rangeInputField.endDate, rangeInputField.dateFormat)
            //                     } else if (hasStart) {
            //                         return Qt.formatDate(rangeInputField.startDate, rangeInputField.dateFormat) + " - ..."
            //                     }
            //                     return rangeInputField.placeholderText
            //                 }

            //                 font.family: Theme.typography.familySans
            //                 font.pixelSize: Theme.typography.fontSize175
            //                 font.weight: Theme.typography.weightRegular
            //                 color: {
            //                     const hasStart = rangeInputField.startDate && !isNaN(rangeInputField.startDate.getTime())
            //                     const hasEnd = rangeInputField.endDate && !isNaN(rangeInputField.endDate.getTime())
            //                     if (!hasStart && !hasEnd) {
            //                         return Theme.colors.textMuted
            //                     }
            //                     return Theme.colors.text
            //                 }
            //                 verticalAlignment: Text.AlignVCenter
            //             }

            //             // Calendar icon
            //             Image {
            //                 Layout.preferredWidth: Theme.icons.sizeMd
            //                 Layout.preferredHeight: Theme.icons.sizeMd
            //                 source: "qrc:/App/assets/icons/calendar.svg"
            //             }
            //         }

            //         // Click handler
            //         MouseArea {
            //             anchors.fill: parent
            //             cursorShape: Qt.PointingHandCursor

            //             onClicked: {
            //                 rangeInputField.focused = true
            //                 rangePopup.toggle()
            //             }
            //         }

            //         // DatePicker popup for range
            //         Popup {
            //             id: rangePopup
            //             x: 0
            //             y: parent.height
            //             width: parent.width
            //             height: 400

            //             modal: false
            //             focus: true
            //             closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            //             background: Rectangle {
            //                 color: Theme.colors.transparent
            //             }

            //             UI.DatePicker {
            //                 anchors.fill: parent
            //                 mode: "range"
            //                 startDate: rangeInputField.startDate
            //                 endDate: rangeInputField.endDate

            //                 onRangeSelected: function(startDate, endDate) {
            //                     rangeInputField.startDate = startDate
            //                     rangeInputField.endDate = endDate
            //                     rangeResult.text = (TranslationManager.revision, qsTr("Date Range: ")) +
            //                                       Qt.formatDate(startDate, "dd/MM/yyyy") + " - " + Qt.formatDate(endDate, "dd/MM/yyyy")
            //                     rangePopup.close()
            //                 }
            //             }

            //             function toggle() {
            //                 if (opened) {
            //                     close()
            //                 } else {
            //                     open()
            //                 }
            //             }

            //             onClosed: {
            //                 rangeInputField.focused = false
            //             }
            //         }
            //     }

            //     Text {
            //         id: rangeResult
            //         text: (TranslationManager.revision, qsTr("No date range selected"))
            //         font.family: Theme.typography.familySans
            //         font.pixelSize: Theme.typography.fontSize150
            //         color: Theme.colors.textMuted
            //     }
            // }

            // UI.HorizontalDivider { Layout.fillWidth: true }

            // 24-Hour Time Picker
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Time Picker Selection (24H)"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.accent500
                }

                // Label
                Text {
                    text: (TranslationManager.revision, qsTr("Select Time")) + " *"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                }

                // Input field for 24h time
                Rectangle {
                    id: time24InputField
                    Layout.fillWidth: true
                    Layout.maximumWidth: 400
                    Layout.preferredHeight: Theme.spacing.s10

                    color: Theme.colors.primary900
                    property bool focused: time24Popup.opened
                    property int selectedHour: -1
                    property int selectedMinute: -1
                    property string placeholderText: "hh:mm"

                    // Bottom border (underline effect)
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: time24InputField.focused ? Theme.borders.b2 : Theme.borders.b1
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
                            text: {
                                if (time24InputField.selectedHour === -1 || time24InputField.selectedMinute === -1) {
                                    return time24InputField.placeholderText
                                }
                                return time24InputField.selectedHour.toString().padStart(2, '0') + ":" +
                                       time24InputField.selectedMinute.toString().padStart(2, '0')
                            }

                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize175
                            font.weight: Theme.typography.weightRegular
                            color: {
                                if (time24InputField.selectedHour === -1 || time24InputField.selectedMinute === -1) {
                                    return Theme.colors.textMuted
                                }
                                return Theme.colors.text
                            }
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Clock icon
                        Image {
                            Layout.preferredWidth: Theme.icons.sizeMd
                            Layout.preferredHeight: Theme.icons.sizeMd
                            source: "qrc:/App/assets/icons/clock.svg"
                        }
                    }

                    // Click handler
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            time24InputField.focused = true
                            time24Popup.toggle()
                        }
                    }

                    // TimePicker popup
                    Popup {
                        id: time24Popup
                        x: 0
                        y: parent.height
                        width: parent.width
                        height: 400

                        modal: false
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                        background: Rectangle {
                            color: Theme.colors.transparent
                        }

                        UI.TimePicker {
                            anchors.fill: parent
                            is24Hour: true
                            selectedHour: time24InputField.selectedHour === -1 ? 0 : time24InputField.selectedHour
                            selectedMinute: time24InputField.selectedMinute === -1 ? 0 : time24InputField.selectedMinute

                            onTimeSelected: function(hour, minute, isAM) {
                                time24InputField.selectedHour = hour
                                time24InputField.selectedMinute = minute
                                time24Result.text = (TranslationManager.revision, qsTr("24H Time: ")) +
                                                   hour.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0')
                                time24Popup.close()
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
                            time24InputField.focused = false
                        }
                    }
                }

                Text {
                    id: time24Result
                    text: (TranslationManager.revision, qsTr("No time selected"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.textMuted
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 12-Hour Time Picker
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Time Picker Selection (12H AM/PM)"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.accent500
                }

                // Label
                Text {
                    text: (TranslationManager.revision, qsTr("Select Time")) + " *"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                }

                // Input field for 12h time
                Rectangle {
                    id: time12InputField
                    Layout.fillWidth: true
                    Layout.maximumWidth: 400
                    Layout.preferredHeight: Theme.spacing.s10

                    color: Theme.colors.primary900
                    property bool focused: time12Popup.opened
                    property int selectedHour: -1
                    property int selectedMinute: -1
                    property bool selectedAMPM: true
                    property string placeholderText: "hh:mm AM/PM"

                    // Bottom border (underline effect)
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: time12InputField.focused ? Theme.borders.b2 : Theme.borders.b1
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
                            text: {
                                if (time12InputField.selectedHour === -1 || time12InputField.selectedMinute === -1) {
                                    return time12InputField.placeholderText
                                }
                                return time12InputField.selectedHour.toString().padStart(2, '0') + ":" +
                                       time12InputField.selectedMinute.toString().padStart(2, '0') + " " +
                                       (time12InputField.selectedAMPM ? "AM" : "PM")
                            }

                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize175
                            font.weight: Theme.typography.weightRegular
                            color: {
                                if (time12InputField.selectedHour === -1 || time12InputField.selectedMinute === -1) {
                                    return Theme.colors.textMuted
                                }
                                return Theme.colors.text
                            }
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Clock icon
                        Image {
                            Layout.preferredWidth: Theme.icons.sizeMd
                            Layout.preferredHeight: Theme.icons.sizeMd
                            source: "qrc:/App/assets/icons/clock.svg"
                        }
                    }

                    // Click handler
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            time12InputField.focused = true
                            time12Popup.toggle()
                        }
                    }

                    // TimePicker popup for 12h
                    Popup {
                        id: time12Popup
                        x: 0
                        y: parent.height
                        width: parent.width
                        height: 400

                        modal: false
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                        background: Rectangle {
                            color: Theme.colors.transparent
                        }

                        UI.TimePicker {
                            anchors.fill: parent
                            is24Hour: false
                            selectedHour: time12InputField.selectedHour === -1 ? 12 : time12InputField.selectedHour
                            selectedMinute: time12InputField.selectedMinute === -1 ? 0 : time12InputField.selectedMinute
                            selectedAMPM: time12InputField.selectedAMPM

                            onTimeSelected: function(hour, minute, isAM) {
                                time12InputField.selectedHour = hour
                                time12InputField.selectedMinute = minute
                                time12InputField.selectedAMPM = isAM
                                time12Result.text = (TranslationManager.revision, qsTr("12H Time: ")) +
                                                   hour.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0') + " " +
                                                   (isAM ? "AM" : "PM")
                                time12Popup.close()
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
                            time12InputField.focused = false
                        }
                    }
                }

                Text {
                    id: time12Result
                    text: (TranslationManager.revision, qsTr("No time selected"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.textMuted
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Test Controls
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
                        singleInputField.selectedDate = today
                        singleResult.text = (TranslationManager.revision, qsTr("Single Date: ")) + Qt.formatDate(today, "dd/MM/yyyy")
                    }
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Set This Week"))
                    size: "sm"
                    variant: "secondary"
                    onClicked: {
                        const today = new Date()
                        const startOfWeek = new Date(today)
                        startOfWeek.setDate(today.getDate() - today.getDay())
                        const endOfWeek = new Date(startOfWeek)
                        endOfWeek.setDate(startOfWeek.getDate() + 6)

                        rangeInputField.startDate = startOfWeek
                        rangeInputField.endDate = endOfWeek
                        rangeResult.text = (TranslationManager.revision, qsTr("Date Range: ")) +
                                          Qt.formatDate(startOfWeek, "dd/MM/yyyy") + " - " + Qt.formatDate(endOfWeek, "dd/MM/yyyy")
                    }
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Set Current Time"))
                    size: "sm"
                    variant: "secondary"
                    onClicked: {
                        const now = new Date()
                        const hour24 = now.getHours()
                        const minute = now.getMinutes()

                        // Set 24h time
                        time24InputField.selectedHour = hour24
                        time24InputField.selectedMinute = minute
                        time24Result.text = (TranslationManager.revision, qsTr("24H Time: ")) +
                                           hour24.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0')

                        // Set 12h time
                        const isAM = hour24 < 12
                        const hour12 = hour24 === 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
                        time12InputField.selectedHour = hour12
                        time12InputField.selectedMinute = minute
                        time12InputField.selectedAMPM = isAM
                        time12Result.text = (TranslationManager.revision, qsTr("12H Time: ")) +
                                           hour12.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0') + " " +
                                           (isAM ? "AM" : "PM")
                    }
                }

                UI.Button {
                    text: (TranslationManager.revision, qsTr("Clear All"))
                    size: "sm"
                    variant: "ghost"
                    onClicked: {
                        singleInputField.selectedDate = new Date(NaN)
                        rangeInputField.startDate = new Date(NaN)
                        rangeInputField.endDate = new Date(NaN)

                        time24InputField.selectedHour = -1
                        time24InputField.selectedMinute = -1
                        time12InputField.selectedHour = -1
                        time12InputField.selectedMinute = -1

                        singleResult.text = (TranslationManager.revision, qsTr("All selections cleared"))
                        rangeResult.text = (TranslationManager.revision, qsTr("All selections cleared"))
                        time24Result.text = (TranslationManager.revision, qsTr("All selections cleared"))
                        time12Result.text = (TranslationManager.revision, qsTr("All selections cleared"))
                    }
                }
            }

        }
    }
}
