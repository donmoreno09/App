import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Map Layers"))

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s8

        spacing: Theme.spacing.s6

        component LayerToggle : RowLayout {
            required property string label
            property alias toggle: toggle

            Layout.fillWidth: true

            Label {
                text: (TranslationManager.revision, qsTr(label))
            }

            UI.HorizontalSpacer { }

            UI.Toggle { id: toggle }
        }

        LayerToggle {
            label: (TranslationManager.revision, qsTr("AIS Map Layer"))
            toggle.checked: TrackManager.getLayer("ais").active
            toggle.onCheckedChanged: {
                if (toggle.checked) TrackManager.activate("ais")
                else TrackManager.deactivate("ais")
            }
        }

        LayerToggle {
            label: (TranslationManager.revision, qsTr("Doc-Space Map Layer"))
            toggle.checked: TrackManager.getLayer("doc-space").active
            toggle.onCheckedChanged: {
                if (toggle.checked) TrackManager.activate("doc-space")
                else TrackManager.deactivate("doc-space")
            }
        }

        LayerToggle {
            label: (TranslationManager.revision, qsTr("TIR Map Layer"))
            toggle.checked: TrackManager.getLayer("tir").active
            toggle.onCheckedChanged: {
                if (toggle.checked) TrackManager.activate("tir")
                else TrackManager.deactivate("tir")
            }
        }
    }
}
