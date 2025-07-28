import QtQuick 2.15
import QtPositioning 6.8
import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var ellipse: null

    Connections {
        target: drawingArea.loader.item
        ignoreUnknownSignals: true

        function onEllipseCreated(newEllipse) {
            if (topToolbar.currentMode !== 'poi-area') return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            handler.ellipse = newEllipse
            mapView.center = newEllipse.center

            ellipsePoiPopup.x = (parent.width - ellipsePoiPopup.width) / 2
            ellipsePoiPopup.y = (parent.height - ellipsePoiPopup.height) / 2

            ellipsePoiPopup.setEllipseCoordinates(
                newEllipse.center.latitude,
                newEllipse.center.longitude,
                newEllipse.radiusLat,
                newEllipse.radiusLon
            )

            ellipsePoiPopup.open()
        }
    }

    Connections {
        target: ellipsePoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onEllipseChanged(centerLat, centerLon, radiusLat, radiusLon) {
            handler.ellipse = {
                center: QtPositioning.coordinate(centerLat, centerLon),
                radiusLat: radiusLat,
                radiusLon: radiusLon
            }

            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                if (drawingArea.loader.item.objectName === "EllipseEditor") {
                    drawingArea.loader.item.center = handler.ellipse.center
                    drawingArea.loader.item.radiusLat = handler.ellipse.radiusLat
                    drawingArea.loader.item.radiusLon = handler.ellipse.radiusLon
                    drawingArea.loader.item.calculatePreviewRadii()
                }
            }

            mapView.center = handler.ellipse.center
        }

        function onSaveClicked(details) {
            if (!handler.ellipse) return

            let finalEllipse = handler.ellipse
            if (details.center && details.radiusLat && details.radiusLon) {
                finalEllipse = {
                    center: details.center,
                    radiusLat: details.radiusLat,
                    radiusLon: details.radiusLon
                }
            }

            const data = ShapeModel.createEllipse(
                details.id,
                details.label,
                finalEllipse.center,
                finalEllipse.radiusLon,
                finalEllipse.radiusLat
            )

            handler.prefillData(data, details)

            if (!data.label || !details.category || !details.type) {
                return
            }

            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)

            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "EllipseEditor") {
                drawingArea.loader.item.resetPreview()
            }

            handler.ellipse = null
        }

        function onClosed() {
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "EllipseEditor") {
                drawingArea.loader.item.resetPreview()
            }

            handler.ellipse = null
        }
    }
}
