import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.Arrivals 1.0

PanelTemplate {
    title.text: qsTr("Date Time Range Selection")

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        ShipArrivalController { id: ctrl }

        SidePanelDateTimeContent {
            controller: ctrl
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
