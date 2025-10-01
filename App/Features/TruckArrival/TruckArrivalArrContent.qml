import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Features.SidePanel 1.0
import App.Features.TruckArrival 1.0

PanelTemplate {
    id: root
    title.text: qsTr("Truck Arrivals — Counters")

    // Optional model hookup (MV-ready)
    TruckArrivalModel { id: arrivalsModel }
    TruckArrivalController {
        id: controller
        model: arrivalsModel
    }

    // Simple reusable error banner (built-in controls only)
    component ErrorBanner: Rectangle {
        required property string text
        visible: text.length > 0
        color: "#FDECEA"         // soft red bg
        border.color: "#F5C2C0"
        radius: 8
        Layout.fillWidth: true
        implicitHeight: 40
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            Label { text: "⚠️"; verticalAlignment: Label.AlignVCenter }
            Label { text: parent.parent.text; wrapMode: Label.Wrap; verticalAlignment: Label.AlignVCenter }
        }
    }

    content: ColumnLayout {
        anchors.fill: parent
        spacing: 12

        ErrorBanner { text: controller.lastError }

        RowLayout {
            Layout.fillWidth: true
            BusyIndicator {
                running: controller.isLoading
                visible: controller.isLoading
            }
            Label {
                text: controller.isLoading ? qsTr("Loading…") : ""
                visible: controller.isLoading
                verticalAlignment: Label.AlignVCenter
            }
        }

        // Today & Current Hour cards (keep old logic)
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ArrivalStatsCard {
                Layout.fillWidth: true
                title: qsTr("Today")
                value: controller.todayCount
                isLoading: controller.isLoading
            }

            ArrivalStatsCard {
                Layout.fillWidth: true
                title: qsTr("Current Hour")
                value: controller.currentHourCount
                isLoading: controller.isLoading
            }
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: controller.fetchAllBasicData()
}
