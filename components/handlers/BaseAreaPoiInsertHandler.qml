import QtQuick 6.8
import QtPositioning 6.8

import raise.singleton.controllers 1.0

/*!
    \qmltype BaseAreaPoiInsertHandler
    \brief A handler for common POI area logic.

    This handler connects with signals of the InsertPoiPopup component
    populating its comboboxes with data.
*/
BasePoiInsertHandler {
    id: handler

    Connections {
        target: insertPoiPopup
        ignoreUnknownSignals: true
        // only allow these connections to fire when it's on shape tools for poi area insertion
        enabled: topToolbar.currentMode === 'poi-area' && savingIndex < 0

        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            insertPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            insertPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === topToolbar.currentPoiCategory)

            var types = categories[insertPoiPopup.categoryComboBox.currentIndex].values
            insertPoiPopup.typeComboxBox.model = types.map((t) => t.value)
            insertPoiPopup.typeComboxBox.currentIndex = types.findIndex((t) => t.key === topToolbar.currentPoiType)
        }
    }

    Connections {
        target: insertPoiPopup.categoryComboBox
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
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
        enabled: topToolbar.currentMode === 'poi-area'

        function onActivated(index) {
            var categories = PoiOptionsController.types.slice(0, 4)
            var types = categories[insertPoiPopup.categoryComboBox.currentIndex].values
            topToolbar.currentPoiType = types[index].key
        }
    }
}
