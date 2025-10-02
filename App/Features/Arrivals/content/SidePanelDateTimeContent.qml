import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.Arrivals 1.0
import App.Features.Language 1.0

ColumnLayout {
    id: root
    spacing: 20

    required property ShipArrivalController controller

    // Date-time range picker (replacing CalendarDateInterval + 2x TimePicker)
    UI.DateTimePicker {
        id: dtRange
        mode: "range"
        is24Hour: true
        Layout.alignment: Qt.AlignHCenter
    }

    // Selected datetime range label
    Text {
        Layout.fillWidth: true
        color: Theme.colors.text

        function fmt(dt) { return Qt.formatDateTime(dt, "dd/MM/yyyy HH:mm") }

        text: (dtRange.startDate && dtRange.endDate)
              ? (TranslationManager.revision, qsTr("Selected: %1 — %2"))
                  .arg(fmt(dtRange._combineDateTime(dtRange.startDate,  dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)))
                  .arg(fmt(dtRange._combineDateTime(dtRange.endDate, dtRange.endHour, dtRange.endMinute, dtRange.endAMPM)))
              : (TranslationManager.revision, qsTr("Select a date & time range"))
        elide: Text.ElideRight
        maximumLineCount: 2
    }

    // Stat card for the total in the selected datetime range
    StatCard {
        icon: "🕒"
        title: (TranslationManager.revision, qsTr("Arrivals in date-time range"))
        value: controller.dateTimeRangeArrivalCount >= 0
               ? controller.dateTimeRangeArrivalCount.toString()
               : "0"
        Layout.fillWidth: true
    }

    // Manual fetch button
    UI.Button {
        enabled: dtRange.hasValidSelection && !controller.isLoading
        contentItem: Text {
            text: (TranslationManager.revision, qsTr("Fetch Date-Time Range"))
            color: Theme.colors.text
            anchors.centerIn: parent
        }
        onClicked: {
            const startDT = dtRange._combineDateTime(dtRange.startDate, dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)
            const endDT   = dtRange._combineDateTime(dtRange.endDate,   dtRange.endHour,     dtRange.endMinute,     dtRange.endAMPM)
            controller.fetchDateTimeRangeShipArrivals(startDT, endDT)
        }
    }

    // Defaults: today → tomorrow (time defaults handled by component)
    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1)
        dtRange.setDateRange(today, tomorrow)
    }
}
