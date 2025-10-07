import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BaseShapeCreateHandler {
    id: handler
    property var ellipse: null

    Connections {
        target: drawingArea.loader.item
        enabled: topToolbar.currentMode === 'shapes'
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onEllipseCreated(ellipse) {
            console.log("[EllipseEditor.onReleased] ⊙", ellipse.center, " rLat:", ellipse.radiusLat, " rLon:", ellipse.radiusLon)
            handler.ellipse = ellipse

            mapView.center = ellipse.center

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
            if (!handler.ellipse) return

            // Remember that radiusA => longitude and radiusB => latitude
            const data = ShapeModel.createEllipse(details.id, details.label, ellipse.center, ellipse.radiusLon, ellipse.radiusLat)
            console.log("SAVING ELLIPSE SHAPE:", JSON.stringify(data))
            handler.savingIndex = annotationLayerInstance.businessLogic.annotationModel.rowCount()
            annotationLayerInstance.businessLogic.annotationModel.append(data)
            ShapeController.saveShapeFromQml(data)
        }

        function onClosed() {
            handler.ellipse = null
        }
    }
}
