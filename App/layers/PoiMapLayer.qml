import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

BaseMapLayer {
    id: root
    _mapLayer: poiMapLayer

    property alias poiMapLayer: poiMapLayer

    // visible: poiMapLayer.active

    MapItemView {
        model: PoiModel

        delegate: MapItemGroup {
            id: loader

            required property int index
            required property var model
            required property string id
            required property string label
            required property int shapeTypeId
            required property bool isRectangle
            required property geoCoordinate topLeft
            required property geoCoordinate bottomRight
            required property var coordinates

            Component.onCompleted: {
                let source = ""
                switch (shapeTypeId) {
                case MapModeController.PointType:
                    source = "qrc:/App/map-objects/PoiPoint.qml"
                    break;
                case MapModeController.PolygonType:
                    if (isRectangle) source = "qrc:/App/map-objects/PoiRectangle.qml"
                    else source = "qrc:/App/map-objects/PoiPolygon.qml"
                    break;
                }

                const component = Qt.createComponent(source)
                component.createObject(loader)
            }
        }
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
