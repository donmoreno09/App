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

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.DatePicker {
        id: rangePicker
        mode: "range"
        standalone: false
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 10
        visible: !controller.isLoading
    }

    Text {
        Layout.fillWidth: true
        visible: !controller.isLoading
        horizontalAlignment: Text.AlignHCenter
        text: (rangePicker.startDate && rangePicker.endDate)
              ? `${TranslationManager.revision}` && qsTr("Selected: %1 — %2")
                    .arg(Qt.formatDate(rangePicker.startDate, "dd/MMM/yyyy"))
                    .arg(Qt.formatDate(rangePicker.endDate,   "dd/MMM/yyyy"))
              : `${TranslationManager.revision}` && qsTr("Select a date range")
        color: Theme.colors.textMuted
    }

    StatCard {
        visible: !controller.isLoading
        icon: "qrc:/App/assets/icons/truck.svg"
        title: `${TranslationManager.revision}` && qsTr("Arrivals in range")
        value: controller.dateRangeArrivalCount.toString() + " " + qsTr(" trucks")
        Layout.fillWidth: true
    }

    UI.VerticalSpacer {}

    UI.Button {
        visible: !controller.isLoading
        variant: UI.ButtonStyles.Primary
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.margins: 10
        text: `${TranslationManager.revision}` && qsTr("Fetch Arrivals")
        enabled: !controller.isLoading && (rangePicker.startDate && rangePicker.endDate)

        onClicked: controller.fetchDateRangeShipArrivals(rangePicker.startDate, rangePicker.endDate)
    }

    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today)
        tomorrow.setDate(today.getDate() + 1)
        rangePicker.startDate = today
        rangePicker.endDate = tomorrow
    }
}
