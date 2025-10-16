import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.ViGateServices 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("ViGate Services"))

    ViGateController { id: ctrl }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ViGateContent {
            width: parent.width
            controller: ctrl
        }
    }
}
