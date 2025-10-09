import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.TruckArrivals 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

PanelTemplate {
    title.text: qsTr("Date Range Selection")

    TruckArrivalController { id: ctrl }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        SidePanelDateContent {
            anchors.fill: parent
            controller: ctrl
            Layout.fillWidth: true
        }
    }
}
