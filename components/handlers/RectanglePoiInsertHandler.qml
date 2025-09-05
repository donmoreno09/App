import QtQuick 2.15
import QtPositioning 6.8
import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var rect: null

    Connections {
        target: drawingArea.loader.item
        ignoreUnknownSignals: true

        function onRectangleCreated(newRect) {
            if (topToolbar.currentMode !== "poi-area") return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

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
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onRectangleChanged(topLat, topLon, bottomLat, bottomLon) {
            handler.rect = {
                topLeft: QtPositioning.coordinate(topLat, topLon),
                bottomRight: QtPositioning.coordinate(bottomLat, bottomLon)
            }

            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                if (drawingArea.loader.item.objectName === "RectangleEditor") {
                    drawingArea.loader.item.topLeft = QtPositioning.coordinate(topLat, topLon)
                    drawingArea.loader.item.bottomRight = QtPositioning.coordinate(bottomLat, bottomLon)
                }
            }

            const center = QtPositioning.coordinate(
                (topLat + bottomLat) / 2,
                (topLon + bottomLon) / 2
            )
            mapView.center = center
        }

        function onSaveClicked(details) {
            if (!handler.rect) return

            const finalRect = {
                topLeft: details.topLeft || handler.rect.topLeft,
                bottomRight: details.bottomRight || handler.rect.bottomRight
            }

            const coordinates = ShapeModel.rectToQtCoordinates(finalRect, QtPositioning)
            const data = ShapeModel.createPolygon(details.id, details.label, coordinates)

            handler.prefillData(data, details)

            if (!data.label || !details.category || !details.type) {
                return
            }

            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)

            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "RectangleEditor") {
                drawingArea.loader.item.resetPreview()
            }

            handler.rect = null
        }

        function onClosed() {
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "RectangleEditor") {
                drawingArea.loader.item.resetPreview()
            }

            handler.rect = null
        }
    }
}
