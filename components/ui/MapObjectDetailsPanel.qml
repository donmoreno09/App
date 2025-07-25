import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import raise.singleton.layermanager 1.0
import raise.singleton.controllers 1.0

Item {
    id: detailsPanel
    width: 300
    height: 400

    property var selectedObjects: LayerManager.selectedObjects

    Rectangle {
        anchors.fill: parent
        color: "#1F3154"
        border.color: "#3a4a6a"
        border.width: 1
        radius: 12
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Rectangle {
            width: parent.width
            height: 40
            radius: 6
            color: "#2a2a2a"
            border.color: "#3a4a6a"
            border.width: 1

            Text {
                text: "Selected Assets"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 14
                anchors.centerIn: parent
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 60
            model: selectedObjects
            clip: true
            spacing: 6

            delegate: Rectangle {
                width: parent.width
                height: column.implicitHeight
                radius: 6
                color: "#1F3154"
                border.color: "#3a4a6a"
                border.width: 1
                anchors.margins: 4

                property var jsObject: {
                    const obj = JSON.parse(JSON.stringify(modelData))
                    delete obj.categoryId
                    delete obj.typeId
                    delete obj.healthStatusId
                    delete obj.operationalStateId
                    delete obj.layerId
                    delete obj.layer
                    return obj
                }

                Column {
                    id: column
                    anchors.fill: parent
                    padding: 6
                    spacing: 6

                    Text {
                        text: "Label: " + JSON.stringify(modelData.label)
                        color: "white"
                        font.bold: true
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }

                    Repeater {
                        property var filteredKeys: Object.entries(jsObject)
                                                    .filter(entry => entry[0] !== "id")
                                                    .map(entry => entry[0])

                        model: filteredKeys
                        delegate: Text {
                            text: modelData + ": " + jsObject[modelData]
                            color: "#ffffff"
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        spacing: 6

                        StyledButton {
                            text: "Edit"

                            onClicked: {
                                if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                                    shapePopup.labelField.text = modelData.label
                                    shapePopup.open()
                                } else {
                                    poiPopup.labelField.text = modelData.label

                                    // find typeId by looping through each category
                                    let categoryId = -1
                                    let typeId = -1
                                    for (const c of PoiOptionsController.types) {
                                        for (const v of c.values) {
                                            if (v.value === modelData.typeName) {
                                                categoryId = c.key
                                                typeId = v.key
                                                break
                                            }
                                        }

                                        if (categoryId >= 0) break
                                    }

                                    const type = modelData.type
                                    poiPopupDataLoader.currentPoiCategory = categoryId
                                    poiPopupDataLoader.currentPoiType = typeId

                                    poiPopup.healthStatusComboBox.currentIndex = PoiOptionsController.healthStatuses.findIndex((h) => h.key === modelData.healthStatusId)
                                    poiPopup.operationalStateComboBox.currentIndex = PoiOptionsController.operationalStates.findIndex((o) => o.key === modelData.operationalStateId)

                                    PoiController.getPoi(modelData.id);
                                    //poiPopup.noteField.text = modelData.note
                                    poiPopup.open()
                                }
                            }
                        }

                        Connections {
                            target: PoiController

                            function onPoiFetchedSuccessfully(poi) {
                                if (poi.details && poi.details.metadata && poi.details.metadata.note) {
                                    poiPopup.noteField.text = poi.details.metadata.note
                                }
                            }
                        }

                        StyledButton {
                            text: "Remove"

                            onClicked: {
                                confirmModal.open()
                            }
                        }
                    }
                }

                PoiPopup {
                    id: poiPopup
                    title: `Update ${modelData.label}?`
                    visible: false
                    parent: root

                    onSaveClicked: function (details) {
                        // TODO: Update to use model instead of using "for" to manually update
                        const dataToSave = JSON.parse(JSON.stringify(modelData))
                        dataToSave.label = details.label
                        dataToSave.typeId = details.type.key
                        dataToSave.typeName = details.type.value
                        dataToSave.healthStatusId = details.healthStatus.key
                        dataToSave.healthStatusName = details.healthStatus.value
                        dataToSave.operationalStateId = details.operationalState.key
                        dataToSave.operationalStateName = details.operationalState.value
                        dataToSave.details = { metadata: { note: details.note } }

                        console.log("UPDATE POI:", JSON.stringify(dataToSave))
                        PoiController.updatePoiFromQml(dataToSave)

                        const poiModel = root.staticPoiLayerInstance.businessLogic.poiModel
                        for (let i = 0; i < poiModel.rowCount(); i++) {
                            const poi = poiModel.at(i)
                            if (poi.id === dataToSave.id) {
                                poiModel.setItemAt(i, dataToSave)
                                break
                            }
                        }

                        staticPoiLayerInstance.businessLogic.syncSelectedObject(dataToSave)
                    }
                }

                ShapePopup {
                    id: shapePopup
                    title: `Update ${modelData.label}?`
                    visible: false
                    parent: root

                    onSaveClicked: function (details) {
                        // TODO: Update to use model instead of using "for" to manually update
                        const dataToSave = JSON.parse(JSON.stringify(modelData))
                        dataToSave.label = details.label

                        console.log("UPDATE POI:", JSON.stringify(dataToSave))
                        ShapeController.updateShapeFromQml(dataToSave)

                        const shapeModel = root.annotationLayerInstance.businessLogic.annotationModel
                        for (let i = 0; i < shapeModel.rowCount(); i++) {
                            const shape = shapeModel.at(i)
                            if (shape.id === dataToSave.id) {
                                shapeModel.setItemAt(i, dataToSave)
                                break
                            }
                        }

                        annotationLayerInstance.businessLogic.syncSelectedObject(dataToSave)
                    }
                }

                PoiPopupDataLoader {
                    id: poiPopupDataLoader
                    targetPoiPopup: poiPopup
                }

                ConfirmModal {
                    id: confirmModal

                    title: "Remove object?"
                    description: `Are you sure you want to remove ${modelData.label}?`
                    confirmBtnText: "Remove"

                    onConfirm: {
                        if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                            ShapeController.deleteShapeFromQml(modelData.id)

                            const shapeModel = root.annotationLayerInstance.businessLogic.annotationModel
                            for (let is = 0; is < shapeModel.rowCount(); is++) {
                                const shape = shapeModel.at(is)
                                if (shape.id === modelData.id) {
                                    shapeModel.removeItemAt(is)
                                    break
                                }
                            }

                            // the `true` flag means to remove the object from the selected objects pane
                            annotationLayerInstance.businessLogic.syncSelectedObject(modelData, true)
                        } else {
                            PoiController.deletePoiFromQml(modelData.id)

                            const poiModel = root.staticPoiLayerInstance.businessLogic.poiModel
                            for (let ip = 0; ip < poiModel.rowCount(); ip++) {
                                const poi = poiModel.at(ip)
                                if (poi.id === modelData.id) {
                                    poiModel.removeItemAt(ip)
                                    break
                                }
                            }

                            // the `true` flag means to remove the object from the selected objects pane
                            staticPoiLayerInstance.businessLogic.syncSelectedObject(modelData, true)
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: LayerManager
        function onSelectedObjectsChanged() {
            console.log("🔁 Oggetti selezionati aggiornati:\n" + JSON.stringify(LayerManager.selectedObjects, null, 2))
            selectedObjects = LayerManager.selectedObjects
        }
    }
}
