import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var ellipse: null

    Connections {
        target: drawingArea.loader.item
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onEllipseCreated(ellipse) {
            if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            console.log("[EllipseEditor.onReleased] ⊙", ellipse.center, " rLat:", ellipse.radiusLat, " rLon:", ellipse.radiusLon)
            handler.ellipse = ellipse

            mapView.center = ellipse.center

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
            if (!handler.ellipse) return

            // Remember that radiusA => longitude and radiusB => latitude
            const data = ShapeModel.createEllipse(details.id, details.label, ellipse.center, ellipse.radiusLon, ellipse.radiusLat)
            handler.prefillData(data, details)
            console.log("SAVING ELLIPSE:", JSON.stringify(data))
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.ellipse = null
        }
    }
}
