import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0

MapItemGroup {
    id: root

    property alias tirMapLayer: tirMapLayer

    visible: tirMapLayer.active

    MapItemView {
        model: tirMapLayer.tirModel

        delegate: Tir { }
    }

    TirMapLayer {
        id: tirMapLayer
        layerName: Layers.tirTrackMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(tirMapLayer)
            TrackManager.registerLayer(MqttClientService.getTopicFromLayer(Layers.tirTrackMapLayer()), tirMapLayer)
            MqttClientService.registerLayer(Layers.tirTrackMapLayer(), tirMapLayer)
            tirMapLayer.map = MapController.map
            tirMapLayer.initialize()
        }
    }

    Connections {
        target: MapController

        function onMapLoaded() {
            tirMapLayer.map = MapController.map
            MapController.map.addMapItemGroup(root)
        }
    }
}
