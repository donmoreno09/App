import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BaseShapeCreateHandler {
    id: handler
    property var polyline: null

    Connections {
        target: drawingArea.loader.item
        enabled: topToolbar.currentMode === 'shapes'
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onPolylineCreated(polyline) {
            console.log("[PolylineEditor.onCreated] Path:", polyline.path)
            handler.polyline = polyline

            let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
            for (let coord of polyline.path) {
                const p = mapView.fromCoordinate(coord, false)
                minX = Math.min(minX, p.x);
                minY = Math.min(minY, p.y);
                maxX = Math.max(maxX, p.x);
                maxY = Math.max(maxY, p.y);
            }
            const centerPoint = Qt.point((minX + maxX)/2, (minY + maxY)/2)
            const centerCoord = mapView.toCoordinate(centerPoint)
            mapView.center = centerCoord

            shapePopup.x = (parent.width - shapePopup.width) / 2
            shapePopup.y = parent.height / 2 - shapePopup.height - 24
            shapePopup.open()
        }
    }

    Connections {
        target: shapePopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'shapes'

        function onSaveClicked(details) {
            // ignore popup save if not this handler
            if (!handler.polyline) return

            const data = ShapeModel.createLineString(details.id, details.label, handler.polyline.path)
            console.log("SAVING POLYLINE SHAPE:", JSON.stringify(data))
            handler.savingIndex = annotationLayerInstance.businessLogic.annotationModel.rowCount()
            annotationLayerInstance.businessLogic.annotationModel.append(data)
            ShapeController.saveShapeFromQml(data)
        }

        function onClosed() {
            handler.polyline = null
        }
    }
}
