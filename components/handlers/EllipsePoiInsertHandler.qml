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

            console.log("[EllipseEditor.onReleased] ⊙", newEllipse.center, " rLat:", newEllipse.radiusLat, " rLon:", newEllipse.radiusLon)

            handler.ellipse = newEllipse

            // Centra la mappa sull'ellisse
            mapView.center = newEllipse.center

            // Posiziona il popup al centro
            ellipsePoiPopup.x = (parent.width - ellipsePoiPopup.width) / 2
            ellipsePoiPopup.y = (parent.height - ellipsePoiPopup.height) / 2

            // Imposta direttamente i parametri dell'ellisse nel popup
            ellipsePoiPopup.setEllipseCoordinates(
                newEllipse.center.latitude,
                newEllipse.center.longitude,
                newEllipse.radiusLat,
                newEllipse.radiusLon
            )

            // Apri il popup
            ellipsePoiPopup.open()
        }
    }

    Connections {
        target: ellipsePoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onEllipseChanged(centerLat, centerLon, radiusLat, radiusLon) {
            console.log("Ellipse parameters changed:", centerLat, centerLon, radiusLat, radiusLon)

            // Aggiorna l'ellisse direttamente dai parametri del popup
            handler.ellipse = {
                center: QtPositioning.coordinate(centerLat, centerLon),
                radiusLat: radiusLat,
                radiusLon: radiusLon
            }

            console.log("Updated ellipse:", handler.ellipse.center, "rLat:", handler.ellipse.radiusLat, "rLon:", handler.ellipse.radiusLon)

            // Aggiorna l'EllipseEditor per mostrare la nuova ellisse
            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                console.log("DrawingArea loader item found:", drawingArea.loader.item.objectName)

                if (drawingArea.loader.item.objectName === "EllipseEditor") {
                    console.log("Updating EllipseEditor coordinates")
                    drawingArea.loader.item.center = handler.ellipse.center
                    drawingArea.loader.item.radiusLat = handler.ellipse.radiusLat
                    drawingArea.loader.item.radiusLon = handler.ellipse.radiusLon
                    // Ricalcola i raggi di preview
                    drawingArea.loader.item.calculatePreviewRadii()
                } else {
                    console.log("Current editor is not EllipseEditor:", drawingArea.loader.item.objectName)
                }
            } else {
                console.log("DrawingArea or loader not available")
            }

            // Aggiorna la vista mappa al centro della nuova ellisse
            mapView.center = handler.ellipse.center
        }

        function onSaveClicked(details) {
            if (!handler.ellipse) return

            console.log("Ellipse POI Handler - Saving with details:", JSON.stringify({
                label: details.label,
                category: details.category ? details.category.name : "null",
                type: details.type ? details.type.value : "null",
                healthStatus: details.healthStatus ? details.healthStatus.value : "null",
                operationalState: details.operationalState ? details.operationalState.value : "null",
                center: [handler.ellipse.center.latitude, handler.ellipse.center.longitude],
                radiusLat: handler.ellipse.radiusLat,
                radiusLon: handler.ellipse.radiusLon
            }))

            // Se l'utente ha modificato i parametri, usa quelli invece dell'ellisse originale
            let finalEllipse = handler.ellipse
            if (details.center && details.radiusLat && details.radiusLon) {
                // L'utente ha modificato i parametri nel popup
                finalEllipse = {
                    center: details.center,
                    radiusLat: details.radiusLat,
                    radiusLon: details.radiusLon
                }
            }

            // Crea l'ellisse usando ShapeModel
            // Nota: radiusA => longitude, radiusB => latitude (come nell'handler originale)
            const data = ShapeModel.createEllipse(
                details.id,
                details.label,
                finalEllipse.center,
                finalEllipse.radiusLon,  // radiusA (longitude)
                finalEllipse.radiusLat   // radiusB (latitude)
            )

            // Aggiungi i dettagli aggiuntivi usando prefillData
            handler.prefillData(data, details)

            console.log("SAVING ELLIPSE (POI) - Final Data:", JSON.stringify(data))

            // Verifica che i dati siano completi prima del salvataggio
            if (!data.label || !details.category || !details.type) {
                console.error("Missing required data for Ellipse POI save:", {
                    hasLabel: !!data.label,
                    hasCategory: !!details.category,
                    hasType: !!details.type
                })
                return
            }

            // Salva nel modello
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)

            // IMPORTANTE: Pulisci il preview dell'ellisse dopo il salvataggio
            // per evitare che rimangano due ellissi visibili
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "EllipseEditor") {
                console.log("Cleaning ellipse preview after save")
                drawingArea.loader.item.resetPreview()
            }

            // Reset dello stato del handler
            handler.ellipse = null
        }

        function onClosed() {
            // Pulisci il preview dell'ellisse quando il popup si chiude
            // (sia per Cancel che per Save)
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "EllipseEditor") {
                console.log("Cleaning ellipse preview on popup close")
                drawingArea.loader.item.resetPreview()
            }

            // Reset dello stato del handler
            handler.ellipse = null
        }
    }

    // I Connections per categoryComboBox e typeComboBox sono gestiti dal BaseAreaPoiInsertHandler
}
