import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0

BaseMapLayer {
    id: root
    _mapLayer: tirMapLayer

    property alias tirMapLayer: tirMapLayer

    visible: tirMapLayer.active

    MapItemView {
        model: tirMapLayer.tirModel

        delegate: Tir {
            tirModel: tirMapLayer.tirModel
        }
    }

    TirMapLayer {
        id: tirMapLayer
        layerName: Layers.tirTrackMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(tirMapLayer)
            TrackManager.registerLayer(MqttClientService.getTopicFromLayer(Layers.tirTrackMapLayer()), tirMapLayer)
            MqttClientService.registerLayer(Layers.tirTrackMapLayer(), tirMapLayer)
            tirMapLayer.map = MapController.map
        }
    }
}
