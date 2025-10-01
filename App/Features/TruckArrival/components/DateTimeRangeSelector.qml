import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

ColumnLayout {
    id: root

    property date startDateTime: new Date()
    property date endDateTime: new Date()
    property bool isValid: startDateTime < endDateTime

    signal rangeChanged(date start, date end)

    spacing: Theme.spacing.s4

    // DateTime Picker
    UI.DateTimePicker {
        id: dateTimePicker
        Layout.fillWidth: true
        mode: "range"
        is24Hour: true

        onRangeApplied: function(start, end) {
            root.startDateTime = start
            root.endDateTime = end
            root.rangeChanged(start, end)
        }

        onSelectionChanged: {
            // Live preview
            if (hasValidSelection) {
                const startDT = _combineDateTime(startDate, selectedHour, selectedMinute, selectedAMPM)
                const endDT = _combineDateTime(endDate, endHour, endMinute, endAMPM)

                if (!isNaN(startDT.getTime()) && !isNaN(endDT.getTime())) {
                    root.startDateTime = startDT
                    root.endDateTime = endDT
                }
            }
        }
    }

    // Selected range display
    Text {
        visible: root.isValid
        text: (TranslationManager.revision, qsTr("Selected: ")) +
              Qt.formatDateTime(root.startDateTime, "dd MMM yyyy hh:mm") + " - " +
              Qt.formatDateTime(root.endDateTime, "dd MMM yyyy hh:mm")
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        color: Theme.colors.textMuted
        Layout.alignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
    }

    // Error message
    Text {
        visible: !root.isValid
        text: (TranslationManager.revision, qsTr("End time must be after start time"))
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.fontSize150
        color: Theme.colors.error500
        Layout.alignment: Qt.AlignHCenter
    }
}
