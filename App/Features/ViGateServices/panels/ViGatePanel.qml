import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.Panels 1.0
import App.Features.ViGateServices 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Gate Transits")
    clip: true

    ScrollView {
        width: parent.width
        height: parent.height
        contentWidth: availableWidth
        clip: true

        ViGateContent {
            width: parent.width
            controller: ViGateController
        }
    }
}
