import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.Arrivals 1.0
import App.Features.Language 1.0


ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 10

    required property ShipArrivalController controller

    onVisibleChanged: if (visible) controller.fetchAllArrivalData()

    BusyIndicator {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillHeight: true
        running: controller.isLoading
        visible: controller.isLoading
    }

    StatCard {
        icon: "qrc:/App/assets/icons/stopwatch.svg"
        title: (TranslationManager.revision, qsTr("Next Hour"))
        value: controller.currentHourArrivalCount.toString() + (TranslationManager.revision, qsTr(" trucks"))
        Layout.fillWidth: true
    }

    StatCard {
        icon: "qrc:/App/assets/icons/calendar-arrivals.svg"
        title: (TranslationManager.revision, qsTr("Today"))
        value: controller.todayArrivalCount.toString() + (TranslationManager.revision, qsTr(" trucks"))
        Layout.fillWidth: true
    }


    Item { Layout.fillHeight: true }

    UI.Button {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.margins: 10
        variant: UI.ButtonStyles.Primary
        text: (TranslationManager.revision, qsTr("Fetch Arrivals"))
        onClicked: controller.fetchAllArrivalData()
    }
}
