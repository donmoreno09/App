import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

BaseMapLayer {
    id: root
    _mapLayer: poiMapLayer
    z: Theme.elevation.layerShapes

    property alias poiMapLayer: poiMapLayer

    // visible: poiMapLayer.active

    MapItemView {
        model: PoiModel

        delegate: MapItemGroup {
            id: loader
            // If poi is selected, put it on top
            z: MapModeController.poi && MapModeController.poi.id === id ? Theme.elevation.z100 + 100 : 0

            required property int index
            required property int modelIndex // model's exclusive for index
            required property var model
            required property string id
            required property string label
            required property int shapeTypeId
            required property bool isRectangle
            required property geoCoordinate coordinate
            required property geoCoordinate topLeft
            required property geoCoordinate bottomRight
            required property real radiusA
            required property real radiusB
            required property var coordinates

            Component.onCompleted: {
                let source = ""
                switch (shapeTypeId) {
                case MapModeController.PointType:
                    source = "qrc:/App/map-objects/PoiPoint.qml"
                    break;
                case MapModeController.EllipseType:
                    source = "qrc:/App/map-objects/PoiEllipse.qml"
                    break;
                case MapModeController.PolygonType:
                    if (isRectangle) source = "qrc:/App/map-objects/PoiRectangle.qml"
                    else source = "qrc:/App/map-objects/PoiPolygon.qml"
                    break;
                }

                const component = Qt.createComponent(source, Qt.Asynchronous)
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
