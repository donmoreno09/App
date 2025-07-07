import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.mqtt 1.0
import "../ui/tracks"

MapItemGroup {
    id: trackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    property string layerName: "TrackMapLayer2"

    visible: isVisible

    property Component trackPanelComponent: Qt.createComponent("../ui/legacy/panels/track/BaseTrackPanel.qml")
    property var activePanel

    function showTrackPanel(trackData, marker) {
        console.log("[TrackPanel] sono arrivato qua")
        if (activePanel)       // chiudi pannello precedente se esiste
            activePanel.destroy()

        activePanel = trackPanelComponent.createObject(
            /* parent */ Qt.application.activeWindow || trackMapLayerComponent,
            {
              marker: marker,
              trackData: trackData,
              trackUid: trackData.iridess_uid || "unknown",
              trackChannel: "smartport"
            })
        activePanel.open(marker, activePanel)   // posiziona e mostra
    }

    Component {
        id: trackDelegate

        Track {
            id: marker  // 👈 nome importante!
            onRequestPanel:  {
                console.log("[TrackPanel] onRequestPanel arrivato!")
                trackMapLayerComponent.showTrackPanel(trackData, markerInstance)
            }
            onTestSignal: {
                console.log("[TrackPanel] test signal")
            }
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
        MqttClientService.registerLayer("TrackLayer2", trackMapLayerBusinessLogic);
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
    }
}
