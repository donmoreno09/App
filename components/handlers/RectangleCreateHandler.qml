import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BaseShapeCreateHandler {
    id: handler

    property var rect: null

    Connections {
        target: drawingArea.loader.item
        enabled: topToolbar.currentMode === "shapes"
        ignoreUnknownSignals: true

        function onRectangleCreated(newRect) {
            console.log("[RectangleEditor.onReleased] ↖️", newRect.topLeft, " ↘️", newRect.bottomRight)
            handler.rect = newRect

            const centerCoord = QtPositioning.coordinate(
                (newRect.topLeft.latitude + newRect.bottomRight.latitude) / 2,
                (newRect.topLeft.longitude + newRect.bottomRight.longitude) / 2
            )
            mapView.center = centerCoord

            shapePopup.x = (parent.width - shapePopup.width) / 2
            shapePopup.y = parent.height / 2 - shapePopup.height - 24
            shapePopup.open()
        }
    }

    Connections {
        target: shapePopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "shapes"

        function onSaveClicked(details) {
            if (!handler.rect) return

            const coordinates = ShapeModel.rectToQtCoordinates(handler.rect, QtPositioning)
            const data = ShapeModel.createPolygon(details.id, details.label, coordinates)
            console.log("SAVING RECTANGLE (POLYGON) SHAPE:", JSON.stringify(data))

            handler.savingIndex = annotationLayerInstance.businessLogic.annotationModel.rowCount()
            annotationLayerInstance.businessLogic.annotationModel.append(data)
            ShapeController.saveShapeFromQml(data)
        }

        function onClosed() {
            handler.rect = null
        }
    }
}

