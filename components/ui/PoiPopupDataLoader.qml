import QtQuick 2.15

import raise.singleton.controllers 1.0

Item {
    id: loader

    property var targetPoiPopup
    property int currentPoiCategory
    property int currentPoiType

    signal categoryChanged(var category)
    signal typeChanged(var type)

    Connections {
        target: targetPoiPopup
        ignoreUnknownSignals: true

        function onOpened() {
            var categories = currentPoiCategory > 4 ? PoiOptionsController.types.slice(4) : PoiOptionsController.types.slice(0, 4)
            targetPoiPopup.categoryComboBox.model = categories.map((c) => c.name)
            targetPoiPopup.categoryComboBox.currentIndex = categories.findIndex((c) => c.key === currentPoiCategory)

            var types = categories[targetPoiPopup.categoryComboBox.currentIndex].values
            targetPoiPopup.typeComboBox.model = types.map((t) => t.value)
            targetPoiPopup.typeComboBox.currentIndex = types.findIndex((t) => t.key === currentPoiType)
        }
    }

    Connections {
        target: targetPoiPopup.categoryComboBox
        ignoreUnknownSignals: true

        function onActivated(index) {
            var categories = currentPoiCategory > 4 ? PoiOptionsController.types.slice(4) : PoiOptionsController.types.slice(0, 4)
            var types = categories[index].values
            targetPoiPopup.typeComboBox.model = types.map((t) => t.value)
            targetPoiPopup.typeComboBox.currentIndex = 0

            categoryChanged(categories[index].key)
            typeChanged(types[0].key)
        }
    }

    Connections {
        target: targetPoiPopup.typeComboBox
        ignoreUnknownSignals: true

        function onActivated(index) {
            var categories = currentPoiCategory > 4 ? PoiOptionsController.types.slice(4) : PoiOptionsController.types.slice(0, 4)
            var types = categories[targetPoiPopup.categoryComboBox.currentIndex].values
            typeChanged(types[index].key)
        }
    }
}
