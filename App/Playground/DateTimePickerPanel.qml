import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Date & Time Picker Test"))

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
                text: (TranslationManager.revision, qsTr("Date & Time Picker Components"))
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 1. Single Date Selection
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: (TranslationManager.revision, qsTr("Single Date Selection"))
                }

                FieldLabel {
                    title: (TranslationManager.revision, qsTr("Select Date"))
                    required: true
                }

                PickerInputField {
                    id: singleDateInput
                    placeholder: "DD/MM/YYYY"
                    focused: singleDatePopup.opened

                    property date selectedDate: new Date(NaN)
                    displayText: !isNaN(selectedDate.getTime()) ?
                               Qt.formatDate(selectedDate, "dd/MM/yyyy") : ""

                    onClicked: singleDatePopup.toggle()

                    PickerPopup {
                        id: singleDatePopup
                        pickerContent: Component {
                            UI.DatePicker {
                                id: picker
                                mode: "single"
                                selectedDate: singleDateInput.selectedDate

                                onDateSelected: function(date) {
                                    singleDateInput.selectedDate = date
                                    singleDateResult.result = (TranslationManager.revision, qsTr("Single Date: ")) +
                                                            Qt.formatDate(date, "dd/MM/yyyy")
                                    singleDatePopup.close()
                                }

                                onCurrentViewChanged: {
                                    singleDatePopup.currentView = currentView
                                }
                            }
                        }
                        onClosed: singleDateInput.focused = false
                    }
                }

                ResultText {
                    id: singleDateResult
                    result: (TranslationManager.revision, qsTr("No single date selected"))
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 2. Date Range Selection
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: (TranslationManager.revision, qsTr("Date Range Selection"))
                }

                FieldLabel {
                    title: (TranslationManager.revision, qsTr("Select Date Range"))
                    required: true
                }

                PickerInputField {
                    id: dateRangeInput
                    placeholder: "DD/MM/YYYY - DD/MM/YYYY"
                    focused: dateRangePopup.opened

                    property date startDate: new Date(NaN)
                    property date endDate: new Date(NaN)
                    displayText: {
                        const hasStart = !isNaN(startDate.getTime())
                        const hasEnd = !isNaN(endDate.getTime())

                        if (!hasStart && !hasEnd) return ""
                        if (hasStart && hasEnd) {
                            return Qt.formatDate(startDate, "dd/MM/yyyy") + " - " +
                                   Qt.formatDate(endDate, "dd/MM/yyyy")
                        }
                        if (hasStart) return Qt.formatDate(startDate, "dd/MM/yyyy") + " - ..."
                        return ""
                    }

                    onClicked: dateRangePopup.toggle()

                    PickerPopup {
                        id: dateRangePopup
                        pickerContent: Component {
                            UI.DatePicker {
                                mode: "range"
                                startDate: dateRangeInput.startDate
                                endDate: dateRangeInput.endDate

                                onRangeSelected: function(startDate, endDate) {
                                    dateRangeInput.startDate = startDate
                                    dateRangeInput.endDate = endDate
                                    dateRangeResult.result = (TranslationManager.revision, qsTr("Date Range: ")) +
                                                           Qt.formatDate(startDate, "dd/MM/yyyy") + " - " +
                                                           Qt.formatDate(endDate, "dd/MM/yyyy")
                                    dateRangePopup.close()
                                }

                                onCurrentViewChanged: {
                                    dateRangePopup.currentView = currentView
                                }
                            }
                        }
                        onClosed: dateRangeInput.focused = false
                    }
                }

                ResultText {
                    id: dateRangeResult
                    result: (TranslationManager.revision, qsTr("No date range selected"))
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 3. Time Selection (24H)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: (TranslationManager.revision, qsTr("Time Selection (24H)"))
                }

                FieldLabel {
                    title: (TranslationManager.revision, qsTr("Select Time"))
                    required: true
                }

                PickerInputField {
                    id: time24Input
                    placeholder: "HH:MM"
                    iconSource: "qrc:/App/assets/icons/clock.svg"
                    focused: time24Popup.opened

                    property int selectedHour: -1
                    property int selectedMinute: -1
                    displayText: (selectedHour !== -1 && selectedMinute !== -1) ?
                               selectedHour.toString().padStart(2, '0') + ":" +
                               selectedMinute.toString().padStart(2, '0') : ""

                    onClicked: time24Popup.toggle()

                    PickerPopup {
                        id: time24Popup
                        height: 200 // TimePicker height
                        pickerContent: Component {
                            UI.TimePicker {
                                is24Hour: true
                                selectedHour: time24Input.selectedHour === -1 ? 0 : time24Input.selectedHour
                                selectedMinute: time24Input.selectedMinute === -1 ? 0 : time24Input.selectedMinute

                                onTimeSelected: function(hour, minute, isAM) {
                                    time24Input.selectedHour = hour
                                    time24Input.selectedMinute = minute
                                    time24Result.result = (TranslationManager.revision, qsTr("24H Time: ")) +
                                                        hour.toString().padStart(2, '0') + ":" +
                                                        minute.toString().padStart(2, '0')
                                    time24Popup.close()
                                }
                            }
                        }
                        onClosed: time24Input.focused = false
                    }
                }

                ResultText {
                    id: time24Result
                    result: (TranslationManager.revision, qsTr("No time selected"))
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 4. Time Selection (12H)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: (TranslationManager.revision, qsTr("Time Selection (12H AM/PM)"))
                }

                FieldLabel {
                    title: (TranslationManager.revision, qsTr("Select Time"))
                    required: true
                }

                PickerInputField {
                    id: time12Input
                    placeholder: "HH:MM AM/PM"
                    iconSource: "qrc:/App/assets/icons/clock.svg"
                    focused: time12Popup.opened

                    property int selectedHour: -1
                    property int selectedMinute: -1
                    property bool selectedAMPM: true
                    displayText: (selectedHour !== -1 && selectedMinute !== -1) ?
                               selectedHour.toString().padStart(2, '0') + ":" +
                               selectedMinute.toString().padStart(2, '0') + " " +
                               (selectedAMPM ? "AM" : "PM") : ""

                    onClicked: time12Popup.toggle()

                    PickerPopup {
                        id: time12Popup
                        height: 200 // TimePicker height
                        pickerContent: Component {
                            UI.TimePicker {
                                is24Hour: false
                                selectedHour: time12Input.selectedHour === -1 ? 12 : time12Input.selectedHour
                                selectedMinute: time12Input.selectedMinute === -1 ? 0 : time12Input.selectedMinute
                                selectedAMPM: time12Input.selectedAMPM

                                onTimeSelected: function(hour, minute, isAM) {
                                    time12Input.selectedHour = hour
                                    time12Input.selectedMinute = minute
                                    time12Input.selectedAMPM = isAM
                                    time12Result.result = (TranslationManager.revision, qsTr("12H Time: ")) +
                                                        hour.toString().padStart(2, '0') + ":" +
                                                        minute.toString().padStart(2, '0') + " " +
                                                        (isAM ? "AM" : "PM")
                                    time12Popup.close()
                                }
                            }
                        }
                        onClosed: time12Input.focused = false
                    }
                }

                ResultText {
                    id: time12Result
                    result: (TranslationManager.revision, qsTr("No time selected"))
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 5. DateTime Selection (Combined)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                SectionHeader {
                    title: (TranslationManager.revision, qsTr("DateTime Selection (Combined)"))
                }

                FieldLabel {
                    title: (TranslationManager.revision, qsTr("Select Date & Time"))
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
                                        dateTimeResult.result = (TranslationManager.revision, qsTr("Live Preview: ")) +
                                                              Qt.formatDateTime(currentDateTime, "dd/MM/yyyy hh:mm")
                                    } else {
                                        dateTimeResult.result = (TranslationManager.revision, qsTr("Select date and time..."))
                                    }
                                }

                                // Final confirmation when Apply is clicked
                                onDateTimeApplied: function(dateTime) {
                                    dateTimeInput.selectedDateTime = dateTime
                                    dateTimeResult.result = (TranslationManager.revision, qsTr("Applied: ")) +
                                                          Qt.formatDateTime(dateTime, "dd/MM/yyyy hh:mm")
                                    dateTimePopup.close()
                                }

                                // When user clears selection
                                onSelectionCleared: {
                                    dateTimeInput.selectedDateTime = new Date(NaN)
                                    dateTimeResult.result = (TranslationManager.revision, qsTr("Selection cleared"))
                                }
                            }
                        }
                        onClosed: dateTimeInput.focused = false
                    }
                }

                ResultText {
                    id: dateTimeResult
                    result: (TranslationManager.revision, qsTr("No datetime selected"))
                }
            }

                // Replace the DateTime Range Selection section in your test page:

                // 6. DateTime Range Selection (Combined)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    SectionHeader {
                        title: (TranslationManager.revision, qsTr("DateTime Range Selection (Combined)"))
                    }

                    FieldLabel {
                        title: (TranslationManager.revision, qsTr("Select Date & Time Range"))
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

                                                dateTimeRangeResult.result = (TranslationManager.revision, qsTr("Live Preview: ")) +
                                                                           Qt.formatDateTime(startDT, "dd/MM/yyyy hh:mm") + " - " +
                                                                           Qt.formatDateTime(endDT, "dd/MM/yyyy hh:mm")
                                            }
                                        } else {
                                            // Show partial selection feedback
                                            if (!isNaN(startDate.getTime()) && isNaN(endDate.getTime())) {
                                                dateTimeRangeResult.result = (TranslationManager.revision, qsTr("Start date selected, choose end date..."))
                                            } else {
                                                dateTimeRangeResult.result = (TranslationManager.revision, qsTr("Select date range and time..."))
                                            }
                                        }
                                    }

                                    // Final confirmation when Apply is clicked
                                    onRangeApplied: function(startDateTime, endDateTime) {
                                        dateTimeRangeInput.startDateTime = startDateTime
                                        dateTimeRangeInput.endDateTime = endDateTime
                                        dateTimeRangeResult.result = (TranslationManager.revision, qsTr("Applied Range: ")) +
                                                                   Qt.formatDateTime(startDateTime, "dd/MM/yyyy hh:mm") + " - " +
                                                                   Qt.formatDateTime(endDateTime, "dd/MM/yyyy hh:mm")
                                        dateTimeRangePopup.close()
                                    }

                                    // When user clears selection
                                    onSelectionCleared: {
                                        dateTimeRangeInput.startDateTime = new Date(NaN)
                                        dateTimeRangeInput.endDateTime = new Date(NaN)
                                        dateTimeRangeResult.result = (TranslationManager.revision, qsTr("Range selection cleared"))
                                    }
                                }
                            }
                            onClosed: dateTimeRangeInput.focused = false
                        }
                    }

                    ResultText {
                        id: dateTimeRangeResult
                        result: (TranslationManager.revision, qsTr("No datetime range selected"))
                    }
                }

            // Test Controls
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Test Controls"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.accent500
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s3

                    UI.Button {
                        text: (TranslationManager.revision, qsTr("Set Today/Now"))
                        size: "md"
                        variant: "secondary"
                        onClicked: {
                            const now = new Date()

                            // Single date
                            singleDateInput.selectedDate = now
                            singleDateResult.result = (TranslationManager.revision, qsTr("Single Date: ")) +
                                                    Qt.formatDate(now, "dd/MM/yyyy")

                            // Time inputs
                            time24Input.selectedHour = now.getHours()
                            time24Input.selectedMinute = now.getMinutes()
                            time24Result.result = (TranslationManager.revision, qsTr("24H Time: ")) +
                                                now.getHours().toString().padStart(2, '0') + ":" +
                                                now.getMinutes().toString().padStart(2, '0')

                            const hour24 = now.getHours()
                            const isAM = hour24 < 12
                            const hour12 = hour24 === 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
                            time12Input.selectedHour = hour12
                            time12Input.selectedMinute = now.getMinutes()
                            time12Input.selectedAMPM = isAM
                            time12Result.result = (TranslationManager.revision, qsTr("12H Time: ")) +
                                                hour12.toString().padStart(2, '0') + ":" +
                                                now.getMinutes().toString().padStart(2, '0') + " " +
                                                (isAM ? "AM" : "PM")

                            // DateTime
                            dateTimeInput.selectedDateTime = now
                            dateTimeResult.result = (TranslationManager.revision, qsTr("DateTime: ")) +
                                                  Qt.formatDateTime(now, "dd/MM/yyyy hh:mm")
                        }
                    }

                    UI.Button {
                        text: (TranslationManager.revision, qsTr("Set This Week"))
                        size: "md"
                        variant: "secondary"
                        onClicked: {
                            const today = new Date()
                            const startOfWeek = new Date(today)
                            startOfWeek.setDate(today.getDate() - today.getDay())
                            const endOfWeek = new Date(startOfWeek)
                            endOfWeek.setDate(startOfWeek.getDate() + 6)

                            dateRangeInput.startDate = startOfWeek
                            dateRangeInput.endDate = endOfWeek
                            dateRangeResult.result = (TranslationManager.revision, qsTr("Date Range: ")) +
                                                   Qt.formatDate(startOfWeek, "dd/MM/yyyy") + " - " +
                                                   Qt.formatDate(endOfWeek, "dd/MM/yyyy")
                        }
                    }

                    UI.Button {
                        text: (TranslationManager.revision, qsTr("Clear All"))
                        size: "md"
                        variant: "ghost"
                        onClicked: {
                            // Clear all inputs
                            singleDateInput.selectedDate = new Date(NaN)
                            dateRangeInput.startDate = new Date(NaN)
                            dateRangeInput.endDate = new Date(NaN)
                            time24Input.selectedHour = -1
                            time24Input.selectedMinute = -1
                            time12Input.selectedHour = -1
                            time12Input.selectedMinute = -1
                            dateTimeInput.selectedDateTime = new Date(NaN)

                            // Clear all results
                            singleDateResult.result = (TranslationManager.revision, qsTr("All selections cleared"))
                            dateRangeResult.result = (TranslationManager.revision, qsTr("All selections cleared"))
                            time24Result.result = (TranslationManager.revision, qsTr("All selections cleared"))
                            time12Result.result = (TranslationManager.revision, qsTr("All selections cleared"))
                            dateTimeResult.result = (TranslationManager.revision, qsTr("All selections cleared"))
                        }
                    }
                }
            }

            // Spacer
            Item { Layout.preferredHeight: Theme.spacing.s6 }
        }
    }
}
