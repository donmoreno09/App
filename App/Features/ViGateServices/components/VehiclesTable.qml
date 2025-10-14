import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Features.ViGateServices 1.0

GroupBox {
    id: root
    title: qsTr("Vehicles")
    Layout.fillWidth: true

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 8
        spacing: 0

        // Header
        GridLayout {
            id: headerGrid
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 12
            rowSpacing: 4

            Label {
                text: qsTr("Start Date")
                font.bold: true
                Layout.preferredWidth: 180
            }
            Label {
                text: qsTr("Plate")
                font.bold: true
                Layout.preferredWidth: 100
            }
            Label {
                text: qsTr("Direction")
                font.bold: true
                Layout.fillWidth: true
            }
        }

        // Scrollable content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 200
            clip: true

            ListView {
                spacing: 2
                model: ViGateStore.vehicles

                delegate: GridLayout {
                    width: ListView.view.width
                    columns: 3
                    columnSpacing: 12
                    rowSpacing: 2

                    required property var modelData

                    Label {
                        text: modelData.startDate
                        Layout.preferredWidth: 180
                        elide: Text.ElideRight
                    }
                    Label {
                        text: modelData.plate
                        Layout.preferredWidth: 100
                        elide: Text.ElideRight
                    }
                    Label {
                        text: modelData.direction
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
