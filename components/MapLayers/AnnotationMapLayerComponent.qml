import QtQuick 6.8
import QtQuick.Shapes 6.8
import QtLocation 6.8
import QtPositioning 6.8

import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel
import "../ui"
import "../ui/shapes"

MapItemGroup {
    id: annotationMapLayerComponent

    property real zoomLevel: 0
    property alias businessLogic: annotationLayerBusinessLogic
    property alias isVisible: annotationLayerBusinessLogic.isVisible
    property alias isEnabled: annotationLayerBusinessLogic.isEnabled

    property string layerName: "AnnotationMapLayer"

    visible: isVisible

    // Punti statici hardcoded per verifica
    property var hardcodedAnnotations: [
        ShapeModel.createPoint("ANN-01", "Annotation 1", QtPositioning.coordinate(44.1005, 9.8220)),
        ShapeModel.createPoint("ANN-02", "Annotation 2", QtPositioning.coordinate(44.1030, 9.8290)),
    ]

    MapItemView {
        id: mapItemView
        model: annotationLayerBusinessLogic.annotationModel

        delegate: MapObjectLoader {
            color: "yellow"
            bgColor: "#44e6e600"
            source: {
                switch (modelData.geometry.shapeTypeId) {
                case ShapeModel.POINT_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/AnnotationMarker.qml")
                case ShapeModel.ELLIPSE_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/Ellipse.qml")
                case ShapeModel.LINE_STRING_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/Polyline.qml")
                case ShapeModel.POLYGON_TYPE_ID:
                    return Qt.resolvedUrl("../ui/shapes/Polygon.qml")
                }
                return ""
            }

            Connections {
                target: item
                ignoreUnknownSignals: true

                function onModified() {
                    ShapeController.updateShapeFromQml(modelData)
                    console.log("MODIFIED SHAPE:", JSON.stringify(modelData))
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("[AnnotationMapLayerComponent:Component.onCompleted] layer : " + annotationMapLayerComponent.layerName + " qmlReady, registering layer")
        // annotationLayerBusinessLogic.annotationModel.resetWith(hardcodedAnnotations) // for testing purposes
        LayerManager.registerLayer(annotationLayerBusinessLogic)
        annotationLayerBusinessLogic.initialize()
    }

    AnnotationMapLayer {
        id: annotationLayerBusinessLogic
        layerName: annotationMapLayerComponent.layerName
        zoomLevel: annotationMapLayerComponent.zoomLevel
    }

    Connections {
        target: annotationLayerBusinessLogic
        function onLayerReady() {
            LayerManager.notifyLayerReady(annotationLayerBusinessLogic)
        }
    }
}
