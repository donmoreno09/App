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

    onVisibleChanged: if (visible && !controller.isLoading) controller.fetchAllArrivalData()

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    StatCard {
        icon: "qrc:/App/assets/icons/stopwatch.svg"
        title: `${TranslationManager.revision}` && qsTr("Next Hour")
        value: controller.currentHourArrivalCount.toString() + `${TranslationManager.revision}` && qsTr(" trucks")
        Layout.fillWidth: true
        visible: !controller.isLoading
    }

    StatCard {
        icon: "qrc:/App/assets/icons/calendar-arrivals.svg"
        title: `${TranslationManager.revision}` && qsTr("Today")
        value: controller.todayArrivalCount.toString() + `${TranslationManager.revision}` && qsTr(" trucks")
        Layout.fillWidth: true
        visible: !controller.isLoading
    }


    UI.VerticalSpacer {}

    UI.Button {
        visible: !controller.isLoading
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.margins: 10
        variant: UI.ButtonStyles.Primary
        text: `${TranslationManager.revision}` && qsTr("Fetch Arrivals")
        onClicked: controller.fetchAllArrivalData()
    }
}
