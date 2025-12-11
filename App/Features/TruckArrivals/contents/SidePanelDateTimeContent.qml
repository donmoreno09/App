import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.TruckArrivals 1.0
import App.Features.Language 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Theme.spacing.s5

    required property TruckArrivalController controller

    readonly property var startDT: dtRangePicker._combineDateTime(
        dtRangePicker.startDate,
        dtRangePicker.selectedHour,
        dtRangePicker.selectedMinute,
        dtRangePicker.selectedAMPM
    )
    readonly property var endDT: dtRangePicker._combineDateTime(
        dtRangePicker.endDate,
        dtRangePicker.endHour,
        dtRangePicker.endMinute,
        dtRangePicker.endAMPM
    )
    property alias hasValidSelection: dtRangePicker.hasValidSelection

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 250
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.DateTimePicker {
        id: dtRangePicker
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        visible: !controller.isLoading
        mode: "range"
        is24Hour: true
    }

    Text {
        visible: !controller.isLoading
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        color: Theme.colors.textMuted
        text: dtRangePicker.rangeText
    }

    StatCard {
        visible: !controller.isLoading
        icon: "qrc:/App/assets/icons/truck.svg"
        title: `${TranslationManager.revision}` && qsTr("Arriving Trucks")
        value: controller.dateTimeRangeArrivalCount.toString() + " " + qsTr(" trucks")
        Layout.fillWidth: true
    }

    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1)
        dtRangePicker.setDateRange(today, tomorrow)
    }
}
