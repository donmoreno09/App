import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import raise.singleton.layermanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0

Rectangle {
    id: mapObjectDetailsPanel

    Layout.fillWidth: true
    Layout.fillHeight: detailsPanelExpanded
    Layout.minimumHeight: 40
    height: detailsPanelExpanded ? 0 : 40
    color: "#101e2c"
    border.color: "#2d3b50"
    border.width: 1
    radius: 10

    property var selectedObjects: LayerManager.selectedObjects
    property bool detailsPanelExpanded: false

    visible: selectedObjects && selectedObjects.length > 0

    // Translation strings
    property string selectedAssetsText: qsTr("Selected Assets")
    property string labelText: qsTr("Label:")
    property string editText: qsTr("Edit")
    property string removeText: qsTr("Remove")
    property string updatePoiText: qsTr("Update POI")
    property string updateRectanglePoiText: qsTr("Update Rectangle POI")
    property string updateEllipsePoiText: qsTr("Update Ellipse POI")
    property string updatePolygonPoiText: qsTr("Update Polygon POI")
    property string updateShapeText: qsTr("Update Shape")
    property string removeObjectTitleText: qsTr("Remove Object")
    property string removeObjectDescText: qsTr("Are you sure you want to remove this object?")
    property string removeButtonText: qsTr("Remove")
    property string updateLabelText: qsTr("Update Label")

    function retranslateUi() {
        selectedAssetsText        = qsTr("Selected Assets")
        labelText                 = qsTr("Label:")
        editText                  = qsTr("Edit")
        removeText                = qsTr("Remove")
        updatePoiText              = qsTr("UPDATE POI:")
        updateRectanglePoiText     = qsTr("UPDATE RECTANGLE POI:")
        updateEllipsePoiText       = qsTr("UPDATE ELLIPSE POI:")
        updatePolygonPoiText       = qsTr("UPDATE POLYGON POI:")
        updateShapeText            = qsTr("UPDATE SHAPE:")
        removeObjectTitleText      = qsTr("Remove object?")
        removeObjectDescText       = qsTr("Are you sure you want to remove")
        removeButtonText           = qsTr("Remove")
        updateLabelText            = qsTr("Update")
    }

    function isRectangle(geometry) {
        if (!geometry || !geometry.coordinates || geometry.shapeTypeId !== 3) return false;
        if (geometry.coordinates.length !== 5) return false;

        const coords = geometry.coordinates;
        const x1 = coords[0].x, y1 = coords[0].y;
        const x2 = coords[1].x, y2 = coords[1].y;
        const x3 = coords[2].x, y3 = coords[2].y;
        const x4 = coords[3].x, y4 = coords[3].y;

        return (
            Math.abs(x1 - x4) < 0.000001 && Math.abs(x2 - x3) < 0.000001 &&
            Math.abs(y1 - y2) < 0.000001 && Math.abs(y3 - y4) < 0.000001 &&
            Math.abs(x1 - x2) > 0.000001 && Math.abs(y1 - y3) > 0.000001
        );
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Header with expand/collapse button
        RowLayout {
            Layout.fillWidth: true
            height: 30

            Text {
                text: selectedAssetsText + " (" + (selectedObjects ? selectedObjects.length : 0) + ")"
                color: "white"
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
            }

            Button {
                width: 30
                height: 30

                background: Rectangle {
                    color: "#2e4e70"
                    radius: 4
                }

                contentItem: Text {
                    text: detailsPanelExpanded ? "▲" : "▼"
                    color: "white"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                onClicked: detailsPanelExpanded = !detailsPanelExpanded
            }
        }

        // Details content
        Item {
            id: detailsContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: detailsPanelExpanded
            clip: true

            property int implicitHeight: detailsPanelExpanded ? listView.contentHeight : 0

            ListView {
                id: listView
                anchors.fill: parent
                model: selectedObjects
                spacing: 6
                clip: true

                delegate: Rectangle {
                    width: listView.width
                    height: column.implicitHeight + 12
                    radius: 6
                    color: "#f21f3154"
                    border.color: "#3a506b"
                    border.width: 1

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
                        anchors.margins: 6
                        spacing: 4

                        Text {
                            text: labelText + " " + JSON.stringify(modelData.label)
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                            wrapMode: Text.Wrap
                            width: parent.width
                        }

                        Repeater {
                            property var filteredKeys: Object.entries(jsObject)
                                                        .filter(entry => entry[0] !== "id")
                                                        .map(entry => entry[0])
                            model: filteredKeys
                            delegate: Text {
                                text: modelData + ": " + jsObject[modelData]
                                color: "white"
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            spacing: 6

                            StyledButton {
                                text: editText
                                onClicked: {
                                    if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                                        shapePopup.labelField.text = modelData.label
                                        shapePopup.open()
                                    } else {
                                        poiPopup.labelField.text = modelData.label
                                        ellipsePoiPopup.labelField.text = modelData.label
                                        rectanglePoiPopup.labelField.text = modelData.label
                                        polygonPoiPopup.labelField.text = modelData.label

                                        if (modelData.geometry && modelData.geometry.coordinate) {
                                            poiPopup.longitudeField.text = Number(modelData.geometry.coordinate.x || 0).toFixed(6)
                                            poiPopup.latitudeField.text = Number(modelData.geometry.coordinate.y || 0).toFixed(6)
                                        } else {
                                            poiPopup.longitudeField.text = "0.000000"
                                            poiPopup.latitudeField.text = "0.000000"
                                        }

                                        if (modelData.geometry.shapeTypeId === 3) {
                                            if (isRectangle(modelData.geometry) && modelData.geometry.coordinates) {
                                                const coords = modelData.geometry.coordinates;
                                                rectanglePoiPopup.topLeftLat.text = coords[0].y.toFixed(6);
                                                rectanglePoiPopup.topLeftLon.text = coords[0].x.toFixed(6);
                                                rectanglePoiPopup.bottomRightLat.text = coords[2].y.toFixed(6);
                                                rectanglePoiPopup.bottomRightLon.text = coords[2].x.toFixed(6);
                                            } else if (modelData.geometry.coordinates?.length) {
                                                const coordinates = modelData.geometry.coordinates.map(coord =>
                                                    QtPositioning.coordinate(coord.y, coord.x)
                                                );
                                                polygonPoiPopup.setPolygonCoordinates(coordinates);
                                            }
                                        } else if (modelData.geometry.shapeTypeId === 5 && modelData.geometry.coordinate) {
                                            ellipsePoiPopup.centerLat.text = Number(modelData.geometry.coordinate.y).toFixed(6)
                                            ellipsePoiPopup.centerLon.text = Number(modelData.geometry.coordinate.x).toFixed(6)
                                            ellipsePoiPopup.radiusLatField.text = Number(modelData.geometry.radiusA || 0).toFixed(6)
                                            ellipsePoiPopup.radiusLonField.text = Number(modelData.geometry.radiusB || 0).toFixed(6)
                                        }

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

                                        poiPopupDataLoader.currentPoiCategory = categoryId
                                        poiPopupDataLoader.currentPoiType = typeId
                                        rectanglePoiPopupDataLoader.currentPoiCategory = categoryId
                                        rectanglePoiPopupDataLoader.currentPoiType = typeId
                                        ellipsePoiPopupDataLoader.currentPoiCategory = categoryId
                                        ellipsePoiPopupDataLoader.currentPoiType = typeId
                                        polygonPoiPopupDataLoader.currentPoiCategory = categoryId
                                        polygonPoiPopupDataLoader.currentPoiType = typeId

                                        poiPopup.healthStatusComboBox.currentIndex = PoiOptionsController.healthStatuses.findIndex((h) => h.key === modelData.healthStatusId)
                                        poiPopup.operationalStateComboBox.currentIndex = PoiOptionsController.operationalStates.findIndex((o) => o.key === modelData.operationalStateId)
                                        rectanglePoiPopup.healthStatusComboBox.currentIndex = PoiOptionsController.healthStatuses.findIndex((h) => h.key === modelData.healthStatusId)
                                        rectanglePoiPopup.operationalStateComboBox.currentIndex = PoiOptionsController.operationalStates.findIndex((o) => o.key === modelData.operationalStateId)
                                        ellipsePoiPopup.healthStatusComboBox.currentIndex = PoiOptionsController.healthStatuses.findIndex((h) => h.key === modelData.healthStatusId)
                                        ellipsePoiPopup.operationalStateComboBox.currentIndex = PoiOptionsController.operationalStates.findIndex((o) => o.key === modelData.operationalStateId)
                                        polygonPoiPopup.healthStatusComboBox.currentIndex = PoiOptionsController.healthStatuses.findIndex((h) => h.key === modelData.healthStatusId)
                                        polygonPoiPopup.operationalStateComboBox.currentIndex = PoiOptionsController.operationalStates.findIndex((o) => o.key === modelData.operationalStateId)

                                        PoiController.getPoi(modelData.id);

                                        if (modelData.geometry.shapeTypeId === 1) {
                                            poiPopup.open()
                                        } else if (modelData.geometry.shapeTypeId === 5) {
                                            ellipsePoiPopup.open()
                                        } else if (modelData.geometry.shapeTypeId === 3) {
                                            isRectangle(modelData.geometry) ? rectanglePoiPopup.open() : polygonPoiPopup.open()
                                        } else {
                                            poiPopup.open()
                                        }
                                    }
                                }
                            }

                            StyledButton {
                                text: removeText
                                onClicked: confirmModal.open()
                            }
                        }
                    }

                    // Popups and data loaders (unchanged)
                    PoiPopup { /* ... same as original but without logs */ }
                    RectanglePoiPopup { /* ... */ }
                    EllipsePoiPopup { /* ... */ }
                    PolygonPoiPopup { /* ... */ }
                    ShapePopup { /* ... */ }
                    PoiPopupDataLoader { id: poiPopupDataLoader; targetPoiPopup: poiPopup }
                    PoiPopupDataLoader { id: rectanglePoiPopupDataLoader; targetPoiPopup: rectanglePoiPopup }
                    PoiPopupDataLoader { id: ellipsePoiPopupDataLoader; targetPoiPopup: ellipsePoiPopup }
                    PoiPopupDataLoader { id: polygonPoiPopupDataLoader; targetPoiPopup: polygonPoiPopup }

                    ConfirmModal {
                        id: confirmModal
                        title: removeObjectTitleText
                        description: `${removeObjectDescText} ${modelData.label}?`
                        confirmBtnText: removeButtonText
                        onConfirm: {
                            if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                                ShapeController.deleteShapeFromQml(modelData.id)
                                const shapeModel = annotationLayerInstance.businessLogic.annotationModel
                                for (let i = 0; i < shapeModel.rowCount(); i++) {
                                    if (shapeModel.at(i).id === modelData.id) {
                                        shapeModel.removeItemAt(i)
                                        break
                                    }
                                }
                                annotationLayerInstance.businessLogic.syncSelectedObject(modelData, true)
                            } else {
                                PoiController.deletePoiFromQml(modelData.id)
                                const poiModel = staticPoiLayerInstance.businessLogic.poiModel
                                for (let i = 0; i < poiModel.rowCount(); i++) {
                                    if (poiModel.at(i).id === modelData.id) {
                                        poiModel.removeItemAt(i)
                                        break
                                    }
                                }
                                staticPoiLayerInstance.businessLogic.syncSelectedObject(modelData, true)
                            }
                        }
                    }

                    Connections {
                        target: PoiController
                        function onPoiFetchedSuccessfully(poi) {
                            if (poi.details?.metadata?.note) {
                                poiPopup.noteField.text = poi.details.metadata.note
                                rectanglePoiPopup.noteField.text = poi.details.metadata.note
                                ellipsePoiPopup.noteField.text = poi.details.metadata.note
                                polygonPoiPopup.noteField.text = poi.details.metadata.note
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: LanguageController
        function onLanguageChanged() { retranslateUi() }
    }

    Connections {
        target: LayerManager
        function onSelectedObjectsChanged() {
            selectedObjects = LayerManager.selectedObjects
            if (selectedObjects && selectedObjects.length > 0) detailsPanelExpanded = true
        }
    }
}
