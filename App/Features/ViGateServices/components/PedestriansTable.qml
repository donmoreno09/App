// components/PedestriansTable.qml
import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Features.ViGateServices 1.0

GroupBox {
    title: qsTr("Pedestrians")
    Layout.fillWidth: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label { text: qsTr("Start Date"); width: 240; font.bold: true }
            Label { text: qsTr("Direction");  width: 100; font.bold: true }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            clip: true
            spacing: 2
            model: ViGateStore.pedestrians
            delegate: Row {
                required property var modelData
                spacing: 12
                width: parent ? parent.width : 0
                Label { text: modelData.startDate; width: 240 }
                Label { text: modelData.direction; width: 100 }
            }
        }
    }
}
