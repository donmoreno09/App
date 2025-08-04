import QtQuick 6.8
import QtQuick.Shapes 6.8
import QtLocation 6.8
import QtPositioning 6.8

import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel
import "../ui"

MapItemGroup {
    id: staticPoiMapLayerComponent

    property real zoomLevel: 0
    property alias businessLogic: staticPoiMapLayerBusinessLogic
    property alias isVisible: staticPoiMapLayerBusinessLogic.isVisible
    property alias isEnabled: staticPoiMapLayerBusinessLogic.isEnabled

    property string layerName: "Points of Interest"

    visible: isVisible

    MapItemView {
        model: staticPoiMapLayerBusinessLogic.poiModel

        delegate: MapObjectLoader {
            color: "green"
            bgColor: "#4488cc88"
            source: {
                switch (modelData.geometry.shapeTypeId) {
                case ShapeModel.POINT_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/PoiMarker.qml")
                case ShapeModel.ELLIPSE_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/Ellipse.qml")
                case ShapeModel.POLYGON_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/Polygon.qml")
                }
                return ""
            }

            Connections {
                target: item
                ignoreUnknownSignals: true

                function onModified() {
                    PoiController.updatePoiFromQml(modelData)
                    console.log("MODIFIED:", JSON.stringify(modelData))
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("[StaticPoiMapLayerComponent:Component.onCompleted] layer : " + staticPoiMapLayerComponent.layerName + " qmlReady, registering layer")
        LayerManager.registerLayer(staticPoiMapLayerBusinessLogic)
        staticPoiMapLayerBusinessLogic.initialize()
    }

    StaticPoiMapLayer {
        id: staticPoiMapLayerBusinessLogic
        layerName: staticPoiMapLayerComponent.layerName
        zoomLevel: staticPoiMapLayerComponent.zoomLevel
    }

    Connections {
        target: staticPoiMapLayerBusinessLogic
        function onLayerReady() {
            LayerManager.notifyLayerReady(staticPoiMapLayerBusinessLogic)
        }
    }
}
