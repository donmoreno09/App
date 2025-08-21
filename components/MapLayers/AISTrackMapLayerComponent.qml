import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.panelmanager 1.0
import raise.singleton.trackmanager 1.0
import raise.singleton.mqtt 1.0
import raise.singleton.language 1.0

import "../ui/tracks"

MapItemGroup {
    id: aisTrackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    // Automatic retranslation properties
    property string layerNameText: qsTr("AIS Tracks")

    property string layerName: layerNameText

    visible: isVisible

    // Auto-retranslate when language changes
    function retranslateUi() {
        layerNameText = qsTr("AIS Tracks")
    }

    Component {
        id: trackDelegate

        Track {
            trackType: MqttClientService.getTopicFromLayer("AISTrackMapLayer")
        }
    }

    Repeater {
        id: repeaterTracks
        model: trackMapLayerBusinessLogic.tracks
        delegate: trackDelegate
    }

    Component.onCompleted: {
        console.log("[aisTrackMapLayerComponent:Component.onCompleted] layer : " + aisTrackMapLayerComponent.layerName + " notify layer ready...")
        LayerManager.registerLayer(trackMapLayerBusinessLogic)
        TrackManager.registerLayer(MqttClientService.getTopicFromLayer("AISTrackMapLayer"), trackMapLayerBusinessLogic)
        MqttClientService.registerLayer("AISTrackMapLayer", trackMapLayerBusinessLogic);
        trackMapLayerBusinessLogic.initialize()
    }

    TrackMapLayer {
        id: trackMapLayerBusinessLogic
        layerName: aisTrackMapLayerComponent.layerName
        zoomLevel: aisTrackMapLayerComponent.zoomLevel
    }

    Connections {
        target: trackMapLayerBusinessLogic

        function onLayerReady() {
            LayerManager.notifyLayerReady(trackMapLayerBusinessLogic)
        }

        function onTracksChanged() {
            if (!PanelManager.activePanel)
                return

            const uid = PanelManager.currentUid
            for (let i = 0; i < repeaterTracks.count; ++i) {
                const m = repeaterTracks.itemAt(i)
                if (m && m.trackData.iridess_uid === uid) {
                    if (PanelManager.linkedMarker !== m) {
                        PanelManager.linkedMarker = m
                        m.linkToPanel(PanelManager.activePanel.link || PanelManager.activePanel)
                    }
                    m.trackData.tracktype = MqttClientService.getTopicFromLayer("DocSpaceTrackMapLayer")
                    PanelManager.activePanel.trackData = m.trackData   // refresh info
                    break
                }
            }
        }


        function onActivated() {
            console.log("AIS ACTIVATED!")
            aisTrackMapLayerComponent.visible = true
        }

        function onDeactivated() {
            console.log("AIS DEACTIVATED!")
            aisTrackMapLayerComponent.visible = false
        }
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            aisTrackMapLayerComponent.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
