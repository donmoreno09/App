import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Features.ViGateServices 1.0

GroupBox {
    title: qsTr("Summary")
    Layout.fillWidth: true

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 2
        columnSpacing: 12
        rowSpacing: 4

        // Header
        Label {
            text: qsTr("Metric")
            font.bold: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Value")
            font.bold: true
            Layout.fillWidth: true
        }

        // Rows
        Label {
            text: qsTr("Total Entries")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalEntries
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Total Exits")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalExits
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Vehicle Entries")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalVehicleEntries
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Vehicle Exits")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalVehicleExits
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Ped Entries")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalPedestrianEntries
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Ped Exits")
            opacity: 0.7
            Layout.fillWidth: true
        }
        Label {
            text: ViGateStore.totalPedestrianExits
            font.bold: true
            Layout.fillWidth: true
        }
    }
}
