import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.Arrivals 1.0

PanelTemplate {
    title.text: qsTr("Date Range Selection")

    ColumnLayout {
        width: parent.width
        spacing: 16

        ShipArrivalController { id: ctrl }

        SidePanelDateContent {
            controller: ctrl
            Layout.fillWidth: true
            anchors.fill: undefined   // let Layout do the sizing
        }
    }
}
