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

        function onOpened() {
            // Popola i combo box per area POI (primi 4 elementi)
            var categories = PoiOptionsController.types.slice(0, 4)
            areaPoiPopup.categoryComboBox.model = categories.map((c) => c.name)

            // Trova l'indice della categoria corrente
            var categoryIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)
            if (categoryIndex >= 0) {
                areaPoiPopup.categoryComboBox.currentIndex = categoryIndex

                // Popola i tipi per la categoria selezionata
                var types = categories[categoryIndex].values
                areaPoiPopup.typeComboBox.model = types.map((t) => t.value)

                var typeIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
                if (typeIndex >= 0) {
                    areaPoiPopup.typeComboBox.currentIndex = typeIndex
                }
            }
        }

        function onRectangleChanged(topLat, topLon, bottomLat, bottomLon) {
            // Aggiorna il rettangolo quando le coordinate cambiano nel popup
            handler.rect = {
                topLeft: QtPositioning.coordinate(topLat, topLon),
                bottomRight: QtPositioning.coordinate(bottomLat, bottomLon)
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

            console.log("Saving rectangle with details:", JSON.stringify(details))

            // Converti il rettangolo in coordinate per il poligono
            const coordinates = ShapeModel.rectToQtCoordinates(handler.rect, QtPositioning)
            const data = ShapeModel.createPolygon(details.id, details.label, coordinates)

            // Aggiungi i dettagli aggiuntivi
            handler.prefillData(data, details)

            console.log("SAVING RECTANGLE (POLYGON):", JSON.stringify(data))

            // Salva nel modello
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.rect = null
        }
    }

    // Gestisce i cambiamenti nella selezione della categoria
    Connections {
        target: areaPoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[index].values

            areaPoiPopup.typeComboBox.model = types.map((t) => t.value)
            areaPoiPopup.typeComboBox.currentIndex = 0

            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }

    // Gestisce i cambiamenti nella selezione del tipo
    Connections {
        target: areaPoiPopup.typeComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[areaPoiPopup.categoryComboBox.currentIndex].values

            topToolbar.currentPoiType = types[index].key
        }
    }
}
