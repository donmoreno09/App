import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0

MapItemGroup {
    id: root

    property alias trackMapLayer: trackMapLayer

    visible: trackMapLayer.active

    MapItemView {
        model: trackMapLayer.trackModel

        delegate: Track { }
    }

    TrackMapLayer {
        id: trackMapLayer
        layerName: Layers.aisTrackMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(trackMapLayer)
            TrackManager.registerLayer(MqttClientService.getTopicFromLayer(Layers.aisTrackMapLayer()), trackMapLayer)
            MqttClientService.registerLayer(Layers.aisTrackMapLayer(), trackMapLayer)
            trackMapLayer.map = MapController.map
            trackMapLayer.initialize()
        }
    }

    Connections {
        target: MapController

        function onMapLoaded() {
            trackMapLayer.map = MapController.map
            MapController.map.addMapItemGroup(root)
        }
    }
}
