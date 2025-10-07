import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BasePoiInsertHandler {
    id: handler
    property var point: null
    property var currentCoordinate: QtPositioning.coordinate(0, 0)

    MapQuickItem {
        id: poiMarker
        coordinate: handler.currentCoordinate
        visible: handler.point !== null
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2
        sourceItem: Rectangle {
            width: 12
            height: 12
            color: "white"
            radius: width / 2
            border.color: "red"
            border.width: 2
        }
    }

    Connections {
        target: drawingArea.loader.item
        ignoreUnknownSignals: true
        function onPointCreated(point) {
            if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            handler.point = point
            handler.currentCoordinate = point.coordinate
            mapView.center = handler.currentCoordinate

            insertPoiPopup.x = (parent.width - insertPoiPopup.width) / 2
            insertPoiPopup.y = (parent.height - insertPoiPopup.height) / 2

            insertPoiPopup.open()
        }
    }

    Connections {
        target: insertPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-point' && savingIndex < 0

        function onOpened() {
            var categories = PoiOptionsController.types.slice(4)
            insertPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            insertPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)

            var types = categories[insertPoiPopup.categoryComboBox.currentIndex].values
            insertPoiPopup.typeComboBox.model = types.map((t) => t.value)
            insertPoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)

            if (handler.currentCoordinate.isValid) {
                insertPoiPopup.setCoordinates(handler.currentCoordinate.latitude, handler.currentCoordinate.longitude)
            }
        }

        function onCoordinatesChanged(latitude, longitude) {
            if (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
                handler.currentCoordinate = QtPositioning.coordinate(latitude, longitude)

                if (handler.point) {
                    handler.point.coordinate = handler.currentCoordinate
                }

                mapView.center = handler.currentCoordinate
            }
        }

        function onSaveClicked(details) {
            if (!handler.point) return

            var finalCoordinate = QtPositioning.coordinate(details.latitude, details.longitude)

            const data = ShapeModel.createPoint(details.id, details.label, finalCoordinate)
            handler.prefillData(data, details)

            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.point = null
            handler.currentCoordinate = QtPositioning.coordinate(0, 0)
        }
    }

    Connections {
        target: insertPoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-point'
        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(4)
            var types = categories[index].values
            insertPoiPopup.typeComboBox.model = types.map((t) => t.value)
            insertPoiPopup.typeComboBox.currentIndex = 0
            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }

    Connections {
        target: insertPoiPopup.typeComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-point'
        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(4)
            var types = categories[insertPoiPopup.categoryComboBox.currentIndex].values
            topToolbar.currentPoiType = types[index].key
        }
    }
}
