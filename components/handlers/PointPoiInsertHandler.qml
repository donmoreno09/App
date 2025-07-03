import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.controllers 1.0

import "../models/shapes.js" as ShapeModel

BasePoiInsertHandler {
    id: handler
    property var point: null

    MapQuickItem {
        id: poiMarker
        coordinate: QtPositioning.coordinate(0, 0)
        visible: false
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
        // depending on current loaded item, some signals are unknown so ignore their warnings
        ignoreUnknownSignals: true

        function onPointCreated(point) {
            if (!(topToolbar.currentMode === 'poi-area' || topToolbar.currentMode === 'poi-point')) return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            handler.point = point
            mapView.center = handler.point.coordinate

            insertPoiPopup.x = (parent.width - insertPoiPopup.width) / 2
            insertPoiPopup.y = parent.height / 2 - insertPoiPopup.height - 24
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
            insertPoiPopup.typeComboxBox.model = types.map((t) => t.value)
            insertPoiPopup.typeComboxBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }

        function onSaveClicked(details) {
            // ignore insert poi popup save if not this handler
            if (!handler.point) return

            const data = ShapeModel.createPoint(details.id, details.label, handler.point.coordinate)
            handler.prefillData(data, details)
            console.log("SAVING POINT:", JSON.stringify(data))
            handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
            staticPoiLayerInstance.businessLogic.poiModel.append(data)
            PoiController.savePoiFromQml(data)
        }

        function onClosed() {
            handler.point = null
        }
    }

    Connections {
        target: insertPoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-point'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(4)
            var types = categories[index].values
            insertPoiPopup.typeComboxBox.model = types.map((t) => t.value)
            insertPoiPopup.typeComboxBox.currentIndex = 0

            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }

    Connections {
        target: insertPoiPopup.typeComboxBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-point'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(4)
            var types = categories[insertPoiPopup.categoryComboBox.currentIndex].values
            topToolbar.currentPoiType = types[index].key
        }
    }
}
