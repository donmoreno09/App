import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.Arrivals 1.0
import App.Features.Language 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Theme.spacing.s5

    required property ShipArrivalController controller

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.DateTimePicker {
        id: dtRange
        mode: "range"
        is24Hour: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 10
        visible: !controller.isLoading

    }

    Text {
        visible: !controller.isLoading
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        color: Theme.colors.text

        function fmt(dt) { return Qt.formatDateTime(dt, "dd/MMM/yyyy HH:mm") }

        text: (dtRange.startDate && dtRange.endDate)
              ? (TranslationManager.revision, qsTr("Selected: %1 — %2"))
                  .arg(fmt(dtRange._combineDateTime(dtRange.startDate,  dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)))
                  .arg(fmt(dtRange._combineDateTime(dtRange.endDate, dtRange.endHour, dtRange.endMinute, dtRange.endAMPM)))
              : (TranslationManager.revision, qsTr("Select a date & time range"))
    }

    StatCard {
        visible: !controller.isLoading
        icon: "qrc:/App/assets/icons/stopwatch.svg"
        title: (TranslationManager.revision, qsTr("Arrivals in date-time range"))
        value: controller.dateRangeArrivalCount.toString() + (TranslationManager.revision, qsTr(" trucks"))
        Layout.fillWidth: true
    }

    UI.VerticalSpacer {}

    UI.Button {
        variant: UI.ButtonStyles.Primary
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.margins: 10
        enabled: dtRange.hasValidSelection && !controller.isLoading
        onClicked: {
            const startDT = dtRange._combineDateTime(dtRange.startDate, dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)
            const endDT   = dtRange._combineDateTime(dtRange.endDate,   dtRange.endHour,     dtRange.endMinute,     dtRange.endAMPM)
            controller.fetchDateTimeRangeShipArrivals(startDT, endDT)
        }
    }

    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1)
        dtRange.setDateRange(today, tomorrow)
    }
}
