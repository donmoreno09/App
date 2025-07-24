// import QtQuick 2.15
// import QtPositioning 6.8

// import raise.singleton.controllers 1.0

// import "../models/shapes.js" as ShapeModel

// BaseAreaPoiInsertHandler {
//     id: handler
//     property var ellipse: null

//     Connections {
//         target: drawingArea.loader.item
//         // depending on current loaded item, some signals are unknown so ignore their warnings
//         ignoreUnknownSignals: true

//         function onEllipseCreated(ellipse) {
//             if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
//             if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

//             console.log("[EllipseEditor.onReleased] ⊙", ellipse.center, " rLat:", ellipse.radiusLat, " rLon:", ellipse.radiusLon)
//             handler.ellipse = ellipse

//             mapView.center = ellipse.center

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
//             if (!handler.ellipse) return

//             // Remember that radiusA => longitude and radiusB => latitude
//             const data = ShapeModel.createEllipse(details.id, details.label, ellipse.center, ellipse.radiusLon, ellipse.radiusLat)
//             handler.prefillData(data, details)
//             console.log("SAVING ELLIPSE:", JSON.stringify(data))
//             handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
//             staticPoiLayerInstance.businessLogic.poiModel.append(data)
//             PoiController.savePoiFromQml(data)
//         }

//         function onClosed() {
//             handler.ellipse = null
//         }
//     }
// }


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
            areaPoiPopup.x = (parent.width - areaPoiPopup.width) / 2
            areaPoiPopup.y = (parent.height - areaPoiPopup.height) / 2

            // Converti l'ellisse in coordinate rettangolari per il popup
            // L'ellisse è definita da center + radius, convertiamo in topLeft/bottomRight
            const topLeft = QtPositioning.coordinate(
                newEllipse.center.latitude + newEllipse.radiusLat,
                newEllipse.center.longitude - newEllipse.radiusLon
            )
            const bottomRight = QtPositioning.coordinate(
                newEllipse.center.latitude - newEllipse.radiusLat,
                newEllipse.center.longitude + newEllipse.radiusLon
            )

            // Imposta le coordinate nel popup (bounding box dell'ellisse)
            areaPoiPopup.setCoordinates(
                topLeft.latitude,
                topLeft.longitude,
                bottomRight.latitude,
                bottomRight.longitude
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
            console.log("Ellipse coordinates changed:", topLat, topLon, bottomLat, bottomLon)

            // Riconverti le coordinate rettangolari in ellisse
            const centerLat = (topLat + bottomLat) / 2
            const centerLon = (topLon + bottomLon) / 2
            const radiusLat = Math.abs(topLat - bottomLat) / 2
            const radiusLon = Math.abs(topLon - bottomLon) / 2

            // Aggiorna l'ellisse
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

            // Se l'utente ha modificato le coordinate, usa quelle invece dell'ellisse originale
            let finalEllipse = handler.ellipse
            if (details.topLeft && details.bottomRight) {
                // L'utente ha modificato le coordinate, riconverti in ellisse
                const centerLat = (details.topLeft.latitude + details.bottomRight.latitude) / 2
                const centerLon = (details.topLeft.longitude + details.bottomRight.longitude) / 2
                const radiusLat = Math.abs(details.topLeft.latitude - details.bottomRight.latitude) / 2
                const radiusLon = Math.abs(details.topLeft.longitude - details.bottomRight.longitude) / 2

                finalEllipse = {
                    center: QtPositioning.coordinate(centerLat, centerLon),
                    radiusLat: radiusLat,
                    radiusLon: radiusLon
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
        }

        function onClosed() {
            handler.ellipse = null

            // Nascondi l'ellisse quando il popup si chiude
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "EllipseEditor") {
                drawingArea.loader.item.resetPreview()
            }
        }
    }

    // I Connections per categoryComboBox e typeComboBox sono gestiti dal BaseAreaPoiInsertHandler
}
