import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePicker
    \brief Clean DatePicker following the app's design system architecture

    Follows the same patterns as Button.qml - uses theme tokens, separates concerns,
    and delegates complex UI to child components.
*/

Item {
    id: root

    // Public API - matches your other form components
    property string label: ""
    property bool required: false
    property bool enabled: true
    property string placeholderText: "DD/MM/YYYY"
    property string dateFormat: "dd/MM/yyyy"
    property string size: "md"

    // Date properties
    property date selectedDate: new Date(NaN) // Invalid date = empty
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []

    // State
    readonly property bool isValid: _validateDate(selectedDate)
    readonly property bool isEmpty: !selectedDate || isNaN(selectedDate.getTime())
    property string errorMessage: ""

    // Styling - follows your Button pattern
    readonly property var _sizeVariants: ({
        "sm": { height: Theme.spacing.s8, fontSize: Theme.typography.fontSize150, padding: Theme.spacing.s2 },
        "md": { height: Theme.spacing.s10, fontSize: Theme.typography.fontSize175, padding: Theme.spacing.s3 },
        "lg": { height: Theme.spacing.s12, fontSize: Theme.typography.fontSize200, padding: Theme.spacing.s4 }
    })
    readonly property var _currentSize: _sizeVariants[size] || _sizeVariants["md"]

    // Signals
    signal dateSelected(date date)
    signal cleared()

    // Layout
    implicitWidth: 300
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacing.s1

        // Label - reusable pattern from your other form components
        Text {
            visible: root.label !== ""
            Layout.fillWidth: true
            text: root.label + (root.required ? " *" : "")

            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightMedium
            color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
        }

        // Input field - delegates to a focused component
        DateTimePickerField {
            id: inputField
            Layout.fillWidth: true
            Layout.preferredHeight: root._currentSize.height

            enabled: root.enabled
            isEmpty: root.isEmpty
            isValid: root.isValid
            selectedDate: root.selectedDate
            placeholderText: root.placeholderText
            dateFormat: root.dateFormat
            fontSize: root._currentSize.fontSize
            padding: root._currentSize.padding

            onClicked: calendarPopup.toggle()
        }

        // Error message - consistent with your validation patterns
        Text {
            visible: !root.isValid && !root.isEmpty && root.errorMessage !== ""
            Layout.fillWidth: true
            text: root.errorMessage

            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize125
            color: Theme.colors.error500
            wrapMode: Text.WordWrap
        }
    }

    // Calendar popup - separate component for complex UI
    DateTimePickerPopup {
        id: calendarPopup
        parent: inputField

        selectedDate: root.selectedDate
        minimumDate: root.minimumDate
        maximumDate: root.maximumDate
        disabledDates: root.disabledDates
        dateFormat: root.dateFormat

        onDateSelected: function(date) {
            root.selectedDate = date
            root.errorMessage = ""
            root.dateSelected(date)
        }

        onCleared: {
            root.selectedDate = new Date(NaN)
            root.errorMessage = ""
            root.cleared()
        }
    }

    // Private functions - kept minimal
    function _validateDate(date) {
        if (!date || isNaN(date.getTime())) return false
        if (date < root.minimumDate || date > root.maximumDate) return false
        return !_isDateDisabled(date)
    }

    function _isDateDisabled(date) {
        if (!root.disabledDates || root.disabledDates.length === 0) return false
        const dateString = date.toDateString()
        return root.disabledDates.some(d => d.toDateString() === dateString)
    }

    // Auto-validation on date change
    onSelectedDateChanged: {
        if (selectedDate < minimumDate) {
            errorMessage = `Date must be after ${Qt.formatDate(minimumDate, dateFormat)}`
        } else if (selectedDate > maximumDate) {
            errorMessage = `Date must be before ${Qt.formatDate(maximumDate, dateFormat)}`
        } else if (_isDateDisabled(selectedDate)) {
            errorMessage = "Selected date is not available"
        } else {
            errorMessage = ""
        }
    }
}
