// components/SummaryCard.qml
import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Features.ViGateServices 1.0

GroupBox {
    title: qsTr("Summary")
    Layout.fillWidth: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Total Entries"); opacity: 0.7 }
            Label { text: ViGateStore.totalEntries; font.bold: true }
        }
        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Total Exits"); opacity: 0.7 }
            Label { text: ViGateStore.totalExits; font.bold: true }
        }
        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Vehicle Entries"); opacity: 0.7 }
            Label { text: ViGateStore.totalVehicleEntries; font.bold: true }
        }
        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Vehicle Exits"); opacity: 0.7 }
            Label { text: ViGateStore.totalVehicleExits; font.bold: true }
        }
        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Ped Entries"); opacity: 0.7 }
            Label { text: ViGateStore.totalPedestrianEntries; font.bold: true }
        }
        ColumnLayout {
            spacing: 4
            Label { text: qsTr("Ped Exits"); opacity: 0.7 }
            Label { text: ViGateStore.totalPedestrianExits; font.bold: true }
        }
    }
}
