import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.Panels 1.0
import App.Features.TrailerPredictions 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Waiting Time Prediction")

    TrailerPredictionController { id: ctrl }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        TrailersPredictionsContent {
            anchors.fill: parent
            controller: ctrl
        }
    }
}
