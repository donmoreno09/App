// import QtQuick 2.15
// import QtPositioning 6.8

// import raise.singleton.controllers 1.0
// import "../models/shapes.js" as ShapeModel

// BaseAreaPoiInsertHandler {
//     id: handler
//     property var rect: null

//     Connections {
//         target: drawingArea.loader.item
//         // depending on current loaded item, some signals are unknown so ignore their warnings
//         ignoreUnknownSignals: true

//         function onRectangleCreated(rect) {
//             if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
//             if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

//             console.log("[RectangleEditor.onReleased] ↖️", rect.topLeft, " ↘️", rect.bottomRight)
//             handler.rect = rect

//             const centerCoord = QtPositioning.coordinate(
//                 (rect.topLeft.latitude  + rect.bottomRight.latitude)  / 2,
//                 (rect.topLeft.longitude + rect.bottomRight.longitude) / 2
//             )
//             mapView.center = centerCoord

//             insertPoiPopup.x = (parent.width - insertPoiPopup.width) / 2
//             insertPoiPopup.y = parent.height / 2 - insertPoiPopup.height - 24
//             insertPoiPopup.open()
//         }
//     }

//     Connections {
//         target: insertPoiPopup
//         ignoreUnknownSignals: true
//         // only allow these connections to fire when it's on shape tools for poi area insertion
//         enabled: topToolbar.currentMode === 'poi-area'

//         function onSaveClicked(details) {
//             // ignore insert poi popup save if not this handler
//             if (!handler.rect) return

//             const coordinates = ShapeModel.rectToQtCoordinates(handler.rect, QtPositioning)
//             const data = ShapeModel.createPolygon(details.id, details.label, coordinates)
//             handler.prefillData(data, details)
//             console.log("SAVING RECTANGLE (POLYGON):", JSON.stringify(data))
//             handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
//             staticPoiLayerInstance.businessLogic.poiModel.append(data)
//             PoiController.savePoiFromQml(data)
//         }

//         function onClosed() {
//             handler.rect = null
//         }
//     }
// }

// ✅ RectanglePoiInsertHandler.qml - Gestisce rettangolo manuale e da disegno

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

        function onRectangleCreated(newRect) {
            if (topToolbar.currentMode !== "poi-area") return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            console.log("[RectangleEditor.onReleased] ↖️", newRect.topLeft, " ↘️", newRect.bottomRight)
            handler.rect = newRect

            const center = QtPositioning.coordinate(
                (newRect.topLeft.latitude + newRect.bottomRight.latitude) / 2,
                (newRect.topLeft.longitude + newRect.bottomRight.longitude) / 2
            )

            mapView.center = center

            areaPoiPopup.x = (parent.width - areaPoiPopup.width) / 2
            areaPoiPopup.y = (parent.height - areaPoiPopup.height) / 2

            areaPoiPopup.setCoordinates(
                newRect.topLeft.latitude,
                newRect.topLeft.longitude,
                newRect.bottomRight.latitude,
                newRect.bottomRight.longitude
            )
            areaPoiPopup.open()
        }
    }

    Connections {
        target: areaPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area"

        function onRectangleChanged(topLat, topLon, bottomLat, bottomLon) {
            handler.rect = {
                topLeft: QtPositioning.coordinate(topLat, topLon),
                bottomRight: QtPositioning.coordinate(bottomLat, bottomLon)
            }
        }

        function onSaveClicked(details) {
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

