import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0   // PanelTemplate
import App.Features.Arrivals 1.0    // controller + content

PanelTemplate {
    title.text: qsTr("Truck Arrivals")

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        ShipArrivalController { id: ctrl }

        SidePanelArrContent {
            controller: ctrl
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
