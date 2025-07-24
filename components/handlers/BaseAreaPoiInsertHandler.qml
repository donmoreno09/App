import QtQuick 6.8
import QtPositioning 6.8
import raise.singleton.controllers 1.0
/*!
    \qmltype BaseAreaPoiInsertHandler
    \brief A handler for common POI area logic.
    This handler connects with signals of the AreaPoiPopup component
    populating its comboboxes with data.
*/
BasePoiInsertHandler {
    id: handler
    Connections {
        target: areaPoiPopup  // Cambiato da insertPoiPopup a areaPoiPopup
        ignoreUnknownSignals: true
        // only allow these connections to fire when it's on shape tools for poi area insertion
        enabled: topToolbar.currentMode === 'poi-area' && savingIndex < 0
        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            areaPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            areaPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)
            var types = categories[areaPoiPopup.categoryComboBox.currentIndex].values
            areaPoiPopup.typeComboBox.model = types.map((t) => t.value)  // Corretto typeComboBox
            areaPoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }
    }
    Connections {
        target: areaPoiPopup.categoryComboBox  // Cambiato da insertPoiPopup a areaPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'
        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[index].values
            areaPoiPopup.typeComboBox.model = types.map((t) => t.value)  // Corretto typeComboBox
            areaPoiPopup.typeComboBox.currentIndex = 0
            topToolbar.currentPoiCategory = categories[index].key
            topToolbar.currentPoiType = types[0].key
        }
    }
    Connections {
        target: areaPoiPopup.typeComboBox  // Cambiato da insertPoiPopup a areaPoiPopup e corretto typeComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'
        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[areaPoiPopup.categoryComboBox.currentIndex].values
            topToolbar.currentPoiType = types[index].key
        }
    }
}
