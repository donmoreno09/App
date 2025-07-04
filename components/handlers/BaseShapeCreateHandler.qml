import QtQuick 2.15
import QtPositioning 6.8

import raise.singleton.controllers 1.0

Item {
    id: handler
    property int savingIndex: -1

    Connections {
        target: shapePopup
        ignoreUnknownSignals: true
        // only allow these connections to fire when it's on shape tools for poi area insertion
        enabled: topToolbar.currentMode === 'shapes'

        function onOpened() {
            drawingArea.loader.item.enabled = false
        }

        function onClosed() {
            drawingArea.loader.item.resetPreview()
            drawingArea.loader.item.enabled = true
        }
    }

    Connections {
        target: ShapeController

        function onShapeSavedSuccessfully(uuid) {
            if (handler.savingIndex < 0) return

            const data = annotationLayerInstance.businessLogic.annotationModel.at(handler.savingIndex)
            data.id = uuid
            annotationLayerInstance.businessLogic.annotationModel.setItemAt(handler.savingIndex, data)
            console.log("SAVED SHAPE SUCCESSFULLY:", JSON.stringify(data))
            handler.savingIndex = -1
        }

        function onShapeSaveFailed() {
            if (handler.savingIndex < 0) return

            annotationLayerInstance.businessLogic.annotationModel.removeItemAt(handler.savingIndex)
            handler.savingIndex = -1
        }
    }
}
