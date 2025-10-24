import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0

BaseMapLayer {
    id: root
    _mapLayer: poiMapLayer

    property alias poiMapLayer: poiMapLayer

    // visible: poiMapLayer.active

    MapItemView {
        model: PoiModel

        delegate: PoiPoint { }
    }

    PoiMapLayerController {
        id: poiMapLayer
        layerName: Layers.poiMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(poiMapLayer)
            poiMapLayer.map = MapController.map
            poiMapLayer.initialize()
        }
    }
}
