import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0

MapItemGroup {
    property alias trackMapLayer: trackMapLayer

    TrackMapLayer {
        id: trackMapLayer
        layerName: Layers.aisMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(trackMapLayer)
            trackMapLayer.map = MapController.map
            trackMapLayer.initialize()
        }
    }

    Connections {
        target: MapController

        function onMapLoaded() {
            trackMapLayer.map = MapController.map
        }
    }
}
