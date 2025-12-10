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

    property alias startDate: rangePicker.startDate
    property alias endDate: rangePicker.endDate
    property alias hasValidSelection: rangePicker.hasValidSelection

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 250
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.DatePicker {
        id: rangePicker
        visible: !controller.isLoading
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        mode: "range"
        standalone: false
    }

    Text {
        Layout.fillWidth: true
        visible: !controller.isLoading
        horizontalAlignment: Text.AlignHCenter
        color: Theme.colors.textMuted
        text: rangePicker.rangeText
    }

    StatCard {
        visible: !controller.isLoading
        Layout.fillWidth: true
        icon: "qrc:/App/assets/icons/truck.svg"
        title: `${TranslationManager.revision}` && qsTr("Arrivals in range")
        value: controller.dateRangeArrivalCount.toString() + " " + qsTr(" trucks")
    }

    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today)
        tomorrow.setDate(today.getDate() + 1)
        rangePicker.startDate = today
        rangePicker.endDate = tomorrow
    }
}
