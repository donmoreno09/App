import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var rect: null

    Connections {
        target: drawingArea.loader.item
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onRectangleCreated(rect) {
            if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            console.log("[RectangleEditor.onReleased] ↖️", rect.topLeft, " ↘️", rect.bottomRight)
            handler.rect = rect

            const centerCoord = QtPositioning.coordinate(
                (rect.topLeft.latitude  + rect.bottomRight.latitude)  / 2,
                (rect.topLeft.longitude + rect.bottomRight.longitude) / 2
            )
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
            if (!handler.rect) return

            const coordinates = ShapeModel.rectToQtCoordinates(handler.rect, QtPositioning)
            const data = ShapeModel.createPolygon(details.id, details.label, coordinates)
            handler.prefillData(data, details)
            console.log("SAVING RECTANGLE (POLYGON):", JSON.stringify(data))
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.rect = null
        }
    }
}
