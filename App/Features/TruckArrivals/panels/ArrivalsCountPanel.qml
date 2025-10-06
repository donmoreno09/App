import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.TruckArrivals 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

PanelTemplate {
    title.text: qsTr("Truck Arrivals")

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TruckArrivalController { id: ctrl }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            SidePanelArrivalContent {
                controller: ctrl
                Layout.fillWidth: true
            }
        }

        UI.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.margins: 10
            variant: UI.ButtonStyles.Primary
            text: (TranslationManager.revision, qsTr("Fetch Arrivals"))
            onClicked: ctrl.fetchAllArrivalData()
        }
    }
}
