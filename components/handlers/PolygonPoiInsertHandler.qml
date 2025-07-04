import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var polygon: null

    Connections {
        target: drawingArea.loader.item
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onPolygonCreated(polygon) {
            if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            console.log("[PolygonEditor.onCreated] Path:", polygon.path)
            handler.polygon = polygon

            let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
            for (let coord of polygon.path) {
                const p = mapView.fromCoordinate(coord, false)
                minX = Math.min(minX, p.x);
                minY = Math.min(minY, p.y);
                maxX = Math.max(maxX, p.x);
                maxY = Math.max(maxY, p.y);
            }
            const centerPoint = Qt.point((minX + maxX)/2, (minY + maxY)/2)
            const centerCoord = mapView.toCoordinate(centerPoint)
            mapView.center = centerCoord

            insertPoiPopup.x = (parent.width - insertPoiPopup.width) / 2
            insertPoiPopup.y = parent.height / 2 - insertPoiPopup.height - 24
            insertPoiPopup.open()
        }
    }

    Connections {
        target: insertPoiPopup
        ignoreUnknownSignals: true
        // only allow these connections to fire when it's on shape tools for poi area insertion
        enabled: topToolbar.currentMode === 'poi-area'

        function onSaveClicked(details) {
            // ignore insert poi popup save if not this handler
            if (!handler.polygon) return

            const data = ShapeModel.createPolygon(details.id, details.label, handler.polygon.path)
            handler.prefillData(data, details)
            console.log("SAVING POLYGON:", JSON.stringify(data))
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.polygon = null
        }
    }
}
