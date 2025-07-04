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


    Repeater {
        id: repeaterTracks
        model: trackMapLayerBusinessLogic.tracks
        delegate: Track {}
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
