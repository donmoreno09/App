import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.panelmanager 1.0
import raise.singleton.mqtt 1.0

import "../ui/tracks"

MapItemGroup {
    id: trackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    property string layerName: "TrackMapLayer"

    visible: isVisible

    Component {
        id: trackDelegate

        Track {
            trackType: MqttClientService.getTopicFromLayer("TrackLayer1")
        }
    }

    Repeater {
        id: repeaterTracks
        model: trackMapLayerBusinessLogic.tracks
        delegate: trackDelegate
    }

    Component.onCompleted: {
        console.log("[TrackMapLayerComponent:Component.onCompleted] layer : " + trackMapLayerComponent.layerName + " notify layer ready...")
        LayerManager.registerLayer(trackMapLayerBusinessLogic)
        MqttClientService.registerLayer("TrackLayer1", trackMapLayerBusinessLogic);
        trackMapLayerBusinessLogic.initialize()
    }

    TrackMapLayer {
        id: trackMapLayerBusinessLogic
        layerName: trackMapLayerComponent.layerName
        zoomLevel: trackMapLayerComponent.zoomLevel
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
                    PanelManager.activePanel.trackData = m.trackData   // refresh info
                    break
                }
            }
        }
    }
}
