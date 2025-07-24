import QtQuick 2.15
import QtPositioning 6.8
import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var polygon: null
    property bool isUpdatingCoordinates: false // Flag per prevenire loop

    // Funzione per calcolare il centro del poligono
    function calculatePolygonCenter(coordinates) {
        if (!coordinates || coordinates.length < 3) return null;

        let centerLat = 0;
        let centerLon = 0;
        let validPoints = 0;

        // Calcola il centroide medio (escludi l'ultimo punto se è di chiusura)
        const pointsToUse = coordinates.length > 3 &&
            Math.abs(coordinates[0].latitude - coordinates[coordinates.length - 1].latitude) < 0.000001 &&
            Math.abs(coordinates[0].longitude - coordinates[coordinates.length - 1].longitude) < 0.000001
            ? coordinates.length - 1 : coordinates.length;

        for (let i = 0; i < pointsToUse; i++) {
            const coord = coordinates[i];
            if (coord && typeof coord.latitude === 'number' && typeof coord.longitude === 'number') {
                centerLat += coord.latitude;
                centerLon += coord.longitude;
                validPoints++;
            }
        }

        if (validPoints > 0) {
            return QtPositioning.coordinate(centerLat / validPoints, centerLon / validPoints);
        }

        return null;
    }

    Connections {
        target: drawingArea.loader.item
        ignoreUnknownSignals: true

        function onPolygonCreated(newPolygon) {
            if (topToolbar.currentMode !== 'poi-area') return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            console.log("[PolygonEditor.onCreated] Path:", newPolygon.path)

            handler.polygon = newPolygon

            // Calcola il centro del poligono (bounding box)
            let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
            for (let coord of newPolygon.path) {
                const p = mapView.fromCoordinate(coord, false)
                minX = Math.min(minX, p.x);
                minY = Math.min(minY, p.y);
                maxX = Math.max(maxX, p.x);
                maxY = Math.max(maxY, p.y);
            }
            const centerPoint = Qt.point((minX + maxX)/2, (minY + maxY)/2)
            const centerCoord = mapView.toCoordinate(centerPoint)
            mapView.center = centerCoord

            // Posiziona il popup al centro
            polygonPoiPopup.x = (parent.width - polygonPoiPopup.width) / 2
            polygonPoiPopup.y = (parent.height - polygonPoiPopup.height) / 2

            // IMPORTANTE: Segnala che stiamo per impostare coordinate dall'esterno
            console.log("=== SETTING INITIAL COORDINATES FROM CREATED POLYGON ===")

            // Imposta le coordinate del poligono nel popup
            polygonPoiPopup.setPolygonCoordinates(newPolygon.path)

            // Apri il popup
            polygonPoiPopup.open()
        }
    }

    Connections {
        target: polygonPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onPolygonChanged(coordinates) {
            console.log("=== PolygonPoiInsertHandler.onPolygonChanged ===")
            console.log("Received coordinates:", coordinates.length, "points")
            console.log("isUpdatingCoordinates:", handler.isUpdatingCoordinates)
            console.log("Current mode:", topToolbar.currentMode)
            console.log("Handler enabled:", topToolbar.currentMode === "poi-area" && handler.savingIndex < 0)

            // RIPRISTINA QUESTO CONTROLLO ESSENZIALE!
            if (handler.isUpdatingCoordinates) {
                console.log("BLOCKED by isUpdatingCoordinates flag - preventing editor loop!")
                return
            }

            console.log("Processing polygon coordinate changes...")
            handler.isUpdatingCoordinates = true

            // Aggiorna il poligono con le nuove coordinate
            handler.polygon = {
                path: coordinates
            }

            // Aggiorna il PolygonEditor
            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                console.log("DrawingArea loader item found:", drawingArea.loader.item.objectName)

                if (drawingArea.loader.item.objectName === "PolygonEditor") {
                    console.log("=== UPDATING PolygonEditor ===")

                    const currentPath = drawingArea.loader.item.path
                    console.log("Current path length:", currentPath ? currentPath.length : "null")
                    console.log("New coordinates length:", coordinates.length)

                    // Controllo se serve aggiornamento
                    let needsUpdate = !currentPath || currentPath.length !== coordinates.length

                    if (!needsUpdate && currentPath) {
                        for (let i = 0; i < coordinates.length; i++) {
                            const current = currentPath[i]
                            const newCoord = coordinates[i]
                            if (!current || !newCoord ||
                                Math.abs(current.latitude - newCoord.latitude) > 0.000001 ||
                                Math.abs(current.longitude - newCoord.longitude) > 0.000001) {
                                needsUpdate = true
                                break
                            }
                        }
                    }

                    if (needsUpdate) {
                        console.log("=== APPLYING PATH UPDATE TO EDITOR ===")

                        // Prova diverse proprietà del PolygonEditor
                        try {
                            // Dal log vediamo che il PolygonEditor ha "resetPreview" - proviamo altre proprietà
                            const editor = drawingArea.loader.item

                            // Verifica se ha una proprietà "polygon" o "polygonPath"
                            if (editor.hasOwnProperty("polygon")) {
                                console.log("Using 'polygon' property")
                                editor.polygon = coordinates
                            } else if (editor.hasOwnProperty("polygonPath")) {
                                console.log("Using 'polygonPath' property")
                                editor.polygonPath = coordinates
                            } else if (editor.hasOwnProperty("vertices")) {
                                console.log("Using 'vertices' property")
                                editor.vertices = coordinates
                            } else if (editor.hasOwnProperty("coordinates")) {
                                console.log("Using 'coordinates' property")
                                editor.coordinates = coordinates
                            } else if (editor.hasOwnProperty("path")) {
                                console.log("Using 'path' property")
                                editor.path = coordinates
                            } else {
                                // Se non ha proprietà dirette, prova a chiamare resetPreview e ricreare
                                console.log("No direct property found - trying resetPreview + recreation")
                                if (editor.hasOwnProperty("resetPreview")) {
                                    editor.resetPreview()
                                }

                                console.log("Using fallback method - setting internal path if available")
                                // Prova a settare direttamente se ha una proprietà interna
                                if (editor.hasOwnProperty("_path")) {
                                    editor._path = coordinates
                                } else if (editor.hasOwnProperty("pathPoints")) {
                                    editor.pathPoints = coordinates
                                }
                            }

                            console.log("Path update completed successfully")
                        } catch (error) {
                            console.error("Error updating PolygonEditor:", error)
                        }
                    } else {
                        console.log("No update needed - coordinates are the same")
                    }
                } else {
                    console.log("Current editor is not PolygonEditor:", drawingArea.loader.item.objectName)
                }
            } else {
                console.error("DrawingArea or loader not available!")
                console.log("drawingArea:", !!drawingArea)
                console.log("drawingArea.loader:", !!(drawingArea && drawingArea.loader))
                console.log("drawingArea.loader.item:", !!(drawingArea && drawingArea.loader && drawingArea.loader.item))
            }

            // CORREZIONE: Calcolo centro più robusto
            if (coordinates.length >= 3) {
                console.log("Recalculating map center...")

                // Calcola il centro usando coordinate geografiche direttamente
                let minLat = Infinity, minLon = Infinity, maxLat = -Infinity, maxLon = -Infinity;

                for (let coord of coordinates) {
                    if (coord && typeof coord.latitude === 'number' && typeof coord.longitude === 'number') {
                        minLat = Math.min(minLat, coord.latitude);
                        minLon = Math.min(minLon, coord.longitude);
                        maxLat = Math.max(maxLat, coord.latitude);
                        maxLon = Math.max(maxLon, coord.longitude);
                    }
                }

                if (minLat !== Infinity && minLon !== Infinity) {
                    const centerLat = (minLat + maxLat) / 2;
                    const centerLon = (minLon + maxLon) / 2;
                    const centerCoord = QtPositioning.coordinate(centerLat, centerLon);

                    console.log("New map center:", centerLat, centerLon);
                    mapView.center = centerCoord;
                } else {
                    console.error("Could not calculate center - invalid coordinates");
                }
            }

            // Reset del flag
            Qt.callLater(function() {
                handler.isUpdatingCoordinates = false
                console.log("=== PolygonChanged processing complete, flag reset ===")
            })
        }

        function onSaveClicked(details) {
            if (!handler.polygon) return

            console.log("Polygon POI Handler - Saving with details:", JSON.stringify({
                label: details.label,
                category: details.category ? details.category.name : "null",
                categoryKey: details.category ? details.category.key : "null",
                type: details.type ? details.type.value : "null",
                typeKey: details.type ? details.type.key : "null",
                healthStatus: details.healthStatus ? details.healthStatus.value : "null",
                healthStatusKey: details.healthStatus ? details.healthStatus.key : "null",
                operationalState: details.operationalState ? details.operationalState.value : "null",
                operationalStateKey: details.operationalState ? details.operationalState.key : "null",
                pointsCount: details.coordinates ? details.coordinates.length : handler.polygon.path.length
            }))

            // Se l'utente ha modificato le coordinate, usa quelle
            let finalPath = handler.polygon.path
            if (details.coordinates && details.coordinates.length > 0) {
                finalPath = details.coordinates
            }

            // Verifica che ci siano almeno 3 punti per un poligono valido
            if (finalPath.length < 3) {
                console.error("Cannot save polygon with less than 3 points:", finalPath.length)
                return
            }

            console.log("Final coordinates for save:", finalPath.length, "points")
            console.log("Is polygon closed?", finalPath.length > 0 &&
                Math.abs(finalPath[0].latitude - finalPath[finalPath.length - 1].latitude) < 0.000001 &&
                Math.abs(finalPath[0].longitude - finalPath[finalPath.length - 1].longitude) < 0.000001)

            // Crea il poligono usando ShapeModel
            const data = ShapeModel.createPolygon(details.id, details.label, finalPath)

            // AGGIUNTA: Calcola il centro del poligono per posizionare il testo
            const polygonCenter = calculatePolygonCenter(finalPath);
            if (polygonCenter) {
                console.log("Polygon center calculated:", polygonCenter.latitude, polygonCenter.longitude);
                // Se ShapeModel supporta una proprietà per la posizione del testo, impostala qui
                if (data.hasOwnProperty("labelPosition")) {
                    data.labelPosition = polygonCenter;
                } else if (data.hasOwnProperty("textPosition")) {
                    data.textPosition = polygonCenter;
                } else if (data.geometry && data.geometry.hasOwnProperty("coordinate")) {
                    // Imposta il centro come coordinata principale
                    data.geometry.coordinate = {
                        x: polygonCenter.longitude,
                        y: polygonCenter.latitude
                    };
                }
            }

            // Aggiungi i dettagli aggiuntivi usando prefillData
            handler.prefillData(data, details)

            // Assicurati che i nomi siano popolati correttamente dai dati ricevuti
            if (details.category && details.category.name) {
                data.categoryName = details.category.name
            }
            if (details.type && details.type.value) {
                data.typeName = details.type.value
            }
            if (details.healthStatus && details.healthStatus.value) {
                data.healthStatusName = details.healthStatus.value
            }
            if (details.operationalState && details.operationalState.value) {
                data.operationalStateName = details.operationalState.value
            }

            console.log("SAVING POLYGON (POI) - Final Data:", JSON.stringify({
                id: data.id,
                label: data.label,
                categoryName: data.categoryName,
                typeName: data.typeName,
                healthStatusName: data.healthStatusName,
                operationalStateName: data.operationalStateName,
                coordinatesCount: data.geometry.coordinates.length
            }))

            // Verifica che i dati siano completi prima del salvataggio
            if (!data.label || !details.category || !details.type) {
                console.error("Missing required data for Polygon POI save:", {
                    hasLabel: !!data.label,
                    hasCategory: !!details.category,
                    hasType: !!details.type
                })
                return
            }

            try {
                // Salva nel modello
                handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
                staticPoiLayerInstance.businessLogic.poiModel.append(data)
                PoiController.savePoiFromQml(data)

                console.log("Polygon POI saved successfully")
            } catch (error) {
                console.error("Error saving polygon POI:", error)
                handler.savingIndex = -1 // Reset saving index on error
                return
            }

            // IMPORTANTE: Pulisci il preview del poligono dopo il salvataggio
            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "PolygonEditor") {
                console.log("Cleaning polygon preview after save")
                drawingArea.loader.item.resetPreview()
            }

            // Reset dello stato del handler
            handler.resetState()
        }

        function onClosed() {
            console.log("Polygon popup closed - cleaning up")
            handler.resetState()
        }
    }

    // Funzione per resettare lo stato del handler
    function resetState() {
        // Pulisci il preview del poligono quando il popup si chiude
        if (drawingArea.loader.item && drawingArea.loader.item.objectName === "PolygonEditor") {
            console.log("Cleaning polygon preview on state reset")
            drawingArea.loader.item.resetPreview()
        }

        // Reset dello stato del handler
        handler.polygon = null
        handler.isUpdatingCoordinates = false
    }

    // I Connections per categoryComboBox e typeComboBox sono gestiti dal BaseAreaPoiInsertHandler
}
