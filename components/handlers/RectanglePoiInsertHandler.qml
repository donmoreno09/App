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

            console.log("[RectangleEditor.onReleased] ↖", newRect.topLeft, " ↘", newRect.bottomRight)

            handler.rect = newRect

            const center = QtPositioning.coordinate(
                (newRect.topLeft.latitude + newRect.bottomRight.latitude) / 2,
                (newRect.topLeft.longitude + newRect.bottomRight.longitude) / 2
            )
            mapView.center = center

            // Posiziona il popup al centro
            areaPoiPopup.x = (parent.width - areaPoiPopup.width) / 2
            areaPoiPopup.y = (parent.height - areaPoiPopup.height) / 2

            // Imposta le coordinate nel popup
            areaPoiPopup.setCoordinates(
                newRect.topLeft.latitude,
                newRect.topLeft.longitude,
                newRect.bottomRight.latitude,
                newRect.bottomRight.longitude
            )

            // Apri il popup
            areaPoiPopup.open()
        }
    }

    Connections {
        target: areaPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onRectangleChanged(topLat, topLon, bottomLat, bottomLon) {
            console.log("RectangleChanged called with:", topLat, topLon, bottomLat, bottomLon)

            // Aggiorna il rettangolo quando le coordinate cambiano nel popup
            handler.rect = {
                topLeft: QtPositioning.coordinate(topLat, topLon),
                bottomRight: QtPositioning.coordinate(bottomLat, bottomLon)
            }

            // CRUCIALE: Aggiorna anche il RectangleEditor per mostrare il nuovo rettangolo
            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                console.log("DrawingArea loader item found:", drawingArea.loader.item.objectName)

                if (drawingArea.loader.item.objectName === "RectangleEditor") {
                    console.log("Updating RectangleEditor coordinates")
                    drawingArea.loader.item.topLeft = QtPositioning.coordinate(topLat, topLon)
                    drawingArea.loader.item.bottomRight = QtPositioning.coordinate(bottomLat, bottomLon)
                } else {
                    console.log("Current editor is not RectangleEditor:", drawingArea.loader.item.objectName)
                }
            } else {
                console.log("DrawingArea or loader not available")
            }

            // Aggiorna la vista mappa al centro del nuovo rettangolo
            const center = QtPositioning.coordinate(
                (topLat + bottomLat) / 2,
                (topLon + bottomLon) / 2
            )
            mapView.center = center
        }

        function onSaveClicked(details) {
            if (!handler.rect) return

            console.log("Rectangle POI Handler - Saving with details:", JSON.stringify({
                label: details.label,
                category: details.category ? details.category.name : "null",
                type: details.type ? details.type.value : "null",
                categoryId: details.categoryId,
                typeId: details.typeId,
                healthStatus: details.healthStatus ? details.healthStatus.value : "null",
                operationalState: details.operationalState ? details.operationalState.value : "null",
                topLeft: details.topLeft ? [details.topLeft.latitude, details.topLeft.longitude] : "null",
                bottomRight: details.bottomRight ? [details.bottomRight.latitude, details.bottomRight.longitude] : "null"
            }))

            // Usa le coordinate dal details se disponibili, altrimenti usa handler.rect
            const finalRect = {
                topLeft: details.topLeft || handler.rect.topLeft,
                bottomRight: details.bottomRight || handler.rect.bottomRight
            }

            // Converti il rettangolo in coordinate per il poligono
            const coordinates = ShapeModel.rectToQtCoordinates(finalRect, QtPositioning)
            const data = ShapeModel.createPolygon(details.id, details.label, coordinates)

            // Aggiungi i dettagli aggiuntivi usando prefillData
            handler.prefillData(data, details)

            console.log("SAVING RECTANGLE (POLYGON) - Final Data:", JSON.stringify(data))

            // Verifica che i dati siano completi prima del salvataggio
            if (!data.label || !details.category || !details.type) {
                console.error("Missing required data for POI save:", {
                    hasLabel: !!data.label,
                    hasCategory: !!details.category,
                    hasType: !!details.type,
                    categoryId: details.categoryId,
                    typeId: details.typeId
                })
                return
            }

            // Salva nel modello
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.rect = null

            // Nascondi il rettangolo quando il popup si chiude
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "RectangleEditor") {
                drawingArea.loader.item.resetPreview()
            }
        }
    }

    // I Connections per categoryComboBox e typeComboBox sono ora gestiti dal BaseAreaPoiInsertHandler
    // Non servono più qui, evitando duplicazioni
}
