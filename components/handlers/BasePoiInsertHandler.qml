import QtQuick 6.8
import QtPositioning 6.8

import raise.singleton.controllers 1.0

/*!
    \qmltype BasePoiInsertHandler
    \brief A handler for common POI logic.

    BasePoiInsertHandler contains the logic of handling POI's REST responses.

    If a POI is saved successfully, it mutates the POI data updating its ID.

    If a POI failed saving, it gets removed from the model.
*/
Item {
    id: handler
    property int savingIndex: -1

    /*!
        \qmlmethod void BasePoiInsertHandler::prefillData(var data, var details)
        \brief Prefills POI data before saving to BE.

        Since the BE requires certain properties to be present, this function handles it.

        \param data The POI to prefill data in.
        \param details Data that comes from the InsertPoiPopup's on save.
    */
    function prefillData(data, details) {
        data.layerId = 1
        data.layerName = "Static POI Layer"
        data.typeId = details.type.key
        data.typeName = details.type.value
        data.categoryId = 1
        data.categoryName = PoiOptionsController.categories[data.categoryId - 1].value
        data.healthStatusId = 1
        data.healthStatusName = PoiOptionsController.healthStatuses[data.healthStatusId - 1].value
        data.operationalStateId = 1
        data.operationalStateName = PoiOptionsController.operationalStates[data.operationalStateId - 1].value
        data.details = {
            metadata: { note: details.note }
        }
    }

    Connections {
        target: insertPoiPopup

        function onOpened() {
            var categories = PoiOptionsController.types.slice(0, 4)
            drawingArea.loader.item.enabled = false
        }

        function onClosed() {
            drawingArea.loader.item.resetPreview()
            drawingArea.loader.item.enabled = true
        }
    }

    Connections {
        target: PoiController

        function onPoiSavedSuccessfully(uuid) {
            if (handler.savingIndex < 0) return

            const data = staticPoiLayerInstance.businessLogic.poiModel.at(handler.savingIndex)
            data.id = uuid
            staticPoiLayerInstance.businessLogic.poiModel.setItemAt(handler.savingIndex, data)
            console.log("SAVED SUCCESSFULLY:", JSON.stringify(data))
            handler.savingIndex = -1
        }

        function onPoiSaveFailed() {
            if (handler.savingIndex < 0) return

            staticPoiLayerInstance.businessLogic.poiModel.removeItemAt(handler.savingIndex)
            handler.savingIndex = -1
        }
    }
}
