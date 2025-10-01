import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

ColumnLayout {
    id: root

    property date startDate: new Date()
    property date endDate: new Date()
    property bool isValid: startDate <= endDate

    signal rangeChanged(date start, date end)

    spacing: Theme.spacing.s4

    // Date Range Picker
    UI.DatePicker {
        id: datePicker
        Layout.fillWidth: true
        mode: "range"

        startDate: root.startDate
        endDate: root.endDate

        onRangeSelected: function(start, end) {
            root.startDate = start
            root.endDate = end
            root.rangeChanged(start, end)
        }
    }

    // Selected range display
    Text {
        visible: root.isValid
        text: (TranslationManager.revision, qsTr("Selected: ")) +
              Qt.formatDate(root.startDate, "dd MMM yyyy") + " - " +
              Qt.formatDate(root.endDate, "dd MMM yyyy")
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        color: Theme.colors.textMuted
        Layout.alignment: Qt.AlignHCenter
    }

    // Error message
    Text {
        visible: !root.isValid
        text: (TranslationManager.revision, qsTr("Invalid date range"))
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        color: Theme.colors.error500
        Layout.alignment: Qt.AlignHCenter
    }
}
