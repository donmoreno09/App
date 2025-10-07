import QtQuick 6.8
import QtPositioning 6.8
import raise.singleton.controllers 1.0
/*!
    \qmltype BaseAreaPoiInsertHandler
    \brief A handler for common POI area logic.
    This handler connects with signals of AreaPoiPopup, EllipsePoiPopup and PolygonPoiPopup components
    populating their comboboxes with data.
*/
BasePoiInsertHandler {
    id: handler

    // ========== CONNECTIONS PER AREA POI POPUP (RETTANGOLI) ==========
    Connections {
        target: areaPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area' && savingIndex < 0

        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            areaPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            areaPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)

            var types = categories[areaPoiPopup.categoryComboBox.currentIndex].values
            areaPoiPopup.typeComboBox.model = types.map((t) => t.value)
            areaPoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }
    }

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

    // ========== CONNECTIONS PER ELLIPSE POI POPUP (ELLISSI) ==========
    Connections {
        target: ellipsePoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area' && savingIndex < 0

        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            ellipsePoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            ellipsePoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)

            var types = categories[ellipsePoiPopup.categoryComboBox.currentIndex].values
            ellipsePoiPopup.typeComboBox.model = types.map((t) => t.value)
            ellipsePoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }
    }

    Connections {
        target: ellipsePoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[index].values

            ellipsePoiPopup.typeComboBox.model = types.map((t) => t.value)
            ellipsePoiPopup.typeComboBox.currentIndex = 0

            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }

    Connections {
        target: ellipsePoiPopup.typeComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[ellipsePoiPopup.categoryComboBox.currentIndex].values

            topToolbar.currentPoiType = types[index].key
        }
    }

    // ========== CONNECTIONS PER POLYGON POI POPUP (POLIGONI) ==========
    Connections {
        target: polygonPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area' && savingIndex < 0

        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            polygonPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            polygonPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)

            var types = categories[polygonPoiPopup.categoryComboBox.currentIndex].values
            polygonPoiPopup.typeComboBox.model = types.map((t) => t.value)
            polygonPoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }
    }

    Connections {
        target: polygonPoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[index].values

            polygonPoiPopup.typeComboBox.model = types.map((t) => t.value)
            polygonPoiPopup.typeComboBox.currentIndex = 0

            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }

    Connections {
        target: polygonPoiPopup.typeComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[polygonPoiPopup.categoryComboBox.currentIndex].values

            topToolbar.currentPoiType = types[index].key
        }
    }
}
