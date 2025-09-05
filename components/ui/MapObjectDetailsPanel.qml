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
    property string removeObjectDescText: qsTr("Are you sure you want to remove")
    property string removeButtonText: qsTr("Remove")
    property string updateText: qsTr("Update")

    // Auto-retranslate when language changes
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

    visible: selectedObjects && selectedObjects.length > 0

    function isRectangle(geometry) {
        if (!geometry || !geometry.coordinates || geometry.shapeTypeId !== 3) {
            return false;
        }

        // Un rettangolo ha esattamente 5 coordinate (4 vertici + chiusura)
        if (geometry.coordinates.length !== 5) {
            return false;
        }

        const coords = geometry.coordinates;

        // Verifica che sia effettivamente un rettangolo
        const x1 = coords[0].x, y1 = coords[0].y;
        const x2 = coords[1].x, y2 = coords[1].y;
        const x3 = coords[2].x, y3 = coords[2].y;
        const x4 = coords[3].x, y4 = coords[3].y;

        // Verifica che sia un rettangolo (lati paralleli agli assi)
        const isRect = (
            Math.abs(x1 - x4) < 0.000001 && Math.abs(x2 - x3) < 0.000001 && // lati verticali
            Math.abs(y1 - y2) < 0.000001 && Math.abs(y3 - y4) < 0.000001 && // lati orizzontali
            Math.abs(x1 - x2) > 0.000001 && Math.abs(y1 - y3) > 0.000001    // non è un punto singolo
        );

        return isRect;
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
                text: mapObjectDetailsPanel.selectedAssetsText + " (" + (selectedObjects ? selectedObjects.length : 0) + ")"
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

                onClicked: {
                    detailsPanelExpanded = !detailsPanelExpanded
                }
            }
        }

        // Details content (only visible when expanded)
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
                            text: mapObjectDetailsPanel.labelText + " " + JSON.stringify(modelData.label)
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
                                text: mapObjectDetailsPanel.editText

                                onClicked: {

                                    console.log("=== POPUP DEBUG ===")
                                        console.log("poiPopup exists:", !!poiPopup)
                                        console.log("ellipsePoiPopup exists:", !!ellipsePoiPopup)
                                        console.log("rectanglePoiPopup exists:", !!rectanglePoiPopup)
                                        console.log("polygonPoiPopup exists:", !!polygonPoiPopup)

                                    if (ellipsePoiPopup) {
                                        console.log("ellipsePoiPopup properties:", Object.keys(ellipsePoiPopup))
                                        console.log("centerLat exists:", !!ellipsePoiPopup.centerLat)
                                        console.log("centerLon exists:", !!ellipsePoiPopup.centerLon)
                                    }

                                    console.log("=== DEBUG GEOMETRY ===")
                                        console.log("Full modelData:", JSON.stringify(modelData, null, 2))
                                        console.log("Geometry object:", JSON.stringify(modelData.geometry, null, 2))
                                        console.log("Geometry keys:", Object.keys(modelData.geometry || {}))
                                    if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                                        shapePopup.labelField.text = modelData.label
                                        shapePopup.open()
                                    } else {
                                        poiPopup.labelField.text = modelData.label
                                        ellipsePoiPopup.labelField.text = modelData.label
                                        rectanglePoiPopup.labelField.text = modelData.label
                                        polygonPoiPopup.labelField.text = modelData.label

                                        if (modelData.geometry && modelData.geometry.coordinate) {
                                            const longitude = Number(modelData.geometry.coordinate.x) || 0
                                            const latitude = Number(modelData.geometry.coordinate.y) || 0
                                            poiPopup.longitudeField.text = longitude.toFixed(6)
                                            poiPopup.latitudeField.text = latitude.toFixed(6)
                                        } else {
                                            // Fallback to default values
                                            poiPopup.longitudeField.text = "0.000000"
                                            poiPopup.latitudeField.text = "0.000000"
                                        }

                                        if (modelData.geometry.shapeTypeId === 3) {
                                            // Rectangle
                                            if (isRectangle(modelData.geometry)) {
                                                console.log("Opening Rectangle popup for:", modelData.label);


                                                if (modelData.geometry.coordinates) {
                                                    const coords = modelData.geometry.coordinates;
                                                    rectanglePoiPopup.topLeftLat.text = coords[0].y.toFixed(6);
                                                    rectanglePoiPopup.topLeftLon.text = coords[0].x.toFixed(6);
                                                    rectanglePoiPopup.bottomRightLat.text = coords[2].y.toFixed(6);
                                                    rectanglePoiPopup.bottomRightLon.text = coords[2].x.toFixed(6);
                                                }
                                            } else {
                                                console.log("Opening Polygon popup for:", modelData.label);

                                                // Polygon
                                                if (modelData.geometry.coordinates && modelData.geometry.coordinates.length) {
                                                    const coordinates = modelData.geometry.coordinates.map(coord =>
                                                        QtPositioning.coordinate(coord.y, coord.x)
                                                    );
                                                    polygonPoiPopup.setPolygonCoordinates(coordinates);
                                                }
                                            }
                                        } else if (modelData.geometry.shapeTypeId === 5) {
                                            // Ellipse
                                            if (modelData.geometry && modelData.geometry.coordinate) {
                                                ellipsePoiPopup.centerLat.text = Number(modelData.geometry.coordinate.y).toFixed(6)
                                                ellipsePoiPopup.centerLon.text = Number(modelData.geometry.coordinate.x).toFixed(6)

                                                const radiusA = Number(modelData.geometry.radiusA) || 0
                                                const radiusB = Number(modelData.geometry.radiusB) || 0
                                                ellipsePoiPopup.radiusLatField.text = radiusA.toFixed(6)
                                                ellipsePoiPopup.radiusLonField.text = radiusB.toFixed(6)
                                            }
                                        }

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

                                            if (isRectangle(modelData.geometry)) {
                                                console.log("Opening Rectangle popup for:", modelData.label);
                                                rectanglePoiPopup.open()
                                             } else {
                                                console.log("Opening Polygon popup for:", modelData.label);
                                                polygonPoiPopup.open()
                                             }
                                        } else {
                                            poiPopup.open()
                                        }
                                    }
                                }
                            }

                            StyledButton {
                                text: mapObjectDetailsPanel.removeText

                                onClicked: {
                                    confirmModal.open()
                                }
                            }
                        }
                    }

                    // Popup components for each item
                    PoiPopup {
                        id: poiPopup
                        title: mapObjectDetailsPanel.updateText + " " + modelData.label + "?"
                        visible: false
                        parent: root

                        onSaveClicked: function (details) {
                            const dataToSave = JSON.parse(JSON.stringify(modelData))
                            dataToSave.label = details.label
                            dataToSave.typeId = details.type.key
                            dataToSave.typeName = details.type.value
                            dataToSave.healthStatusId = details.healthStatus.key
                            dataToSave.healthStatusName = details.healthStatus.value
                            dataToSave.operationalStateId = details.operationalState.key
                            dataToSave.operationalStateName = details.operationalState.value
                            dataToSave.details = { metadata: { note: details.note } }

                            if (dataToSave.geometry && dataToSave.geometry.coordinate) {
                                dataToSave.geometry.coordinate.x = Number(details.longitude) || dataToSave.geometry.coordinate.x
                                dataToSave.geometry.coordinate.y = Number(details.latitude) || dataToSave.geometry.coordinate.y

                                // Aggiorna anche l'array coordinates se esiste
                                if (dataToSave.geometry.coordinates && dataToSave.geometry.coordinates[0]) {
                                    dataToSave.geometry.coordinates[0].x = dataToSave.geometry.coordinate.x
                                    dataToSave.geometry.coordinates[0].y = dataToSave.geometry.coordinate.y
                                }
                            }

                            console.log("UPDATE POI:", JSON.stringify(dataToSave))
                            PoiController.updatePoiFromQml(dataToSave)

                            const poiModel = staticPoiLayerInstance.businessLogic.poiModel
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

                    RectanglePoiPopup {
                        id: rectanglePoiPopup
                        title: mapObjectDetailsPanel.updateText + " " + modelData.label + "?"
                        visible: false
                        parent: root

                        onSaveClicked: function (details) {
                            const dataToSave = JSON.parse(JSON.stringify(modelData))
                            dataToSave.label = details.label
                            dataToSave.typeId = details.type.key
                            dataToSave.typeName = details.type.value
                            dataToSave.healthStatusId = details.healthStatus.key
                            dataToSave.healthStatusName = details.healthStatus.value
                            dataToSave.operationalStateId = details.operationalState.key
                            dataToSave.operationalStateName = details.operationalState.value
                            dataToSave.details = { metadata: { note: details.note } }

                            // Update rectangle coordinates
                            if (dataToSave.geometry) {
                                const topLeft = {
                                    x: Number(details.topLeft.longitude),
                                    y: Number(details.topLeft.latitude)
                                }
                                const bottomRight = {
                                    x: Number(details.bottomRight.longitude),
                                    y: Number(details.bottomRight.latitude)
                                }

                                const topRight = { x: bottomRight.x, y: topLeft.y }
                                const bottomLeft = { x: topLeft.x, y: bottomRight.y }

                                dataToSave.geometry.topLeft = topLeft
                                dataToSave.geometry.bottomRight = bottomRight
                                dataToSave.geometry.coordinates = [
                                    topLeft,
                                    topRight,
                                    bottomRight,
                                    bottomLeft,
                                    topLeft
                                ]
                            }


                            console.log("UPDATE RECTANGLE POI:", JSON.stringify(dataToSave))
                            PoiController.updatePoiFromQml(dataToSave)

                            const poiModel = staticPoiLayerInstance.businessLogic.poiModel
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

                    EllipsePoiPopup {
                        id: ellipsePoiPopup
                        title: mapObjectDetailsPanel.updateText + " " + modelData.label + "?"
                        visible: false
                        parent: root

                        onSaveClicked: function (details) {
                            const dataToSave = JSON.parse(JSON.stringify(modelData))
                            dataToSave.label = details.label
                            dataToSave.typeId = details.type.key
                            dataToSave.typeName = details.type.value
                            dataToSave.healthStatusId = details.healthStatus.key
                            dataToSave.healthStatusName = details.healthStatus.value
                            dataToSave.operationalStateId = details.operationalState.key
                            dataToSave.operationalStateName = details.operationalState.value
                            dataToSave.details = { metadata: { note: details.note } }

                            // Update ellipse coordinates
                            if (dataToSave.geometry && dataToSave.geometry.coordinate) {
                                dataToSave.geometry.coordinate.x = Number(details.center.longitude) || dataToSave.geometry.coordinate.x
                                dataToSave.geometry.coordinate.y = Number(details.center.latitude) || dataToSave.geometry.coordinate.y
                                dataToSave.geometry.radiusA = Number(details.radiusLat) || dataToSave.geometry.radiusA
                                dataToSave.geometry.radiusB = Number(details.radiusLon) || dataToSave.geometry.radiusB
                            }

                            console.log("UPDATE ELLIPSE POI:", JSON.stringify(dataToSave))
                            PoiController.updatePoiFromQml(dataToSave)

                            const poiModel = staticPoiLayerInstance.businessLogic.poiModel
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

                    PolygonPoiPopup {
                        id: polygonPoiPopup
                        title: mapObjectDetailsPanel.updateText + " " + modelData.label + "?"
                        visible: false
                        parent: root

                        onSaveClicked: function (details) {
                            const dataToSave = JSON.parse(JSON.stringify(modelData))
                            dataToSave.label = details.label
                            dataToSave.typeId = details.type.key
                            dataToSave.typeName = details.type.value
                            dataToSave.healthStatusId = details.healthStatus.key
                            dataToSave.healthStatusName = details.healthStatus.value
                            dataToSave.operationalStateId = details.operationalState.key
                            dataToSave.operationalStateName = details.operationalState.value
                            dataToSave.details = { metadata: { note: details.note } }

                            // Update polygon coordinates
                            if (dataToSave.geometry && details.coordinates) {
                                dataToSave.geometry.coordinates = details.coordinates.map(coord => ({
                                    x: coord.longitude,
                                    y: coord.latitude
                                }))
                            }

                            console.log("UPDATE POLYGON POI:", JSON.stringify(dataToSave))
                            PoiController.updatePoiFromQml(dataToSave)

                            const poiModel = staticPoiLayerInstance.businessLogic.poiModel
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
                        title: mapObjectDetailsPanel.updateText + " " + modelData.label + "?"
                        visible: false
                        parent: root

                        onSaveClicked: function (details) {
                            const dataToSave = JSON.parse(JSON.stringify(modelData))
                            dataToSave.label = details.label

                            console.log("UPDATE SHAPE:", JSON.stringify(dataToSave))
                            ShapeController.updateShapeFromQml(dataToSave)

                            const shapeModel = annotationLayerInstance.businessLogic.annotationModel
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

                    PoiPopupDataLoader {
                        id: rectanglePoiPopupDataLoader
                        targetPoiPopup: rectanglePoiPopup
                    }

                    PoiPopupDataLoader {
                        id: ellipsePoiPopupDataLoader
                        targetPoiPopup: ellipsePoiPopup
                    }

                    PoiPopupDataLoader {
                        id: polygonPoiPopupDataLoader
                        targetPoiPopup: polygonPoiPopup
                    }

                    ConfirmModal {
                        id: confirmModal

                        title: mapObjectDetailsPanel.removeObjectTitleText
                        description: mapObjectDetailsPanel.removeObjectDescText + " " + modelData.label + "?"
                        confirmBtnText: mapObjectDetailsPanel.removeButtonText

                        onConfirm: {
                            if (LayerManager.focusedLayerName() === "AnnotationMapLayer") {
                                ShapeController.deleteShapeFromQml(modelData.id)

                                const shapeModel = annotationLayerInstance.businessLogic.annotationModel
                                for (let is = 0; is < shapeModel.rowCount(); is++) {
                                    const shape = shapeModel.at(is)
                                    if (shape.id === modelData.id) {
                                        shapeModel.removeItemAt(is)
                                        break
                                    }
                                }

                                annotationLayerInstance.businessLogic.syncSelectedObject(modelData, true)
                            } else {
                                PoiController.deletePoiFromQml(modelData.id)

                                const poiModel = staticPoiLayerInstance.businessLogic.poiModel
                                for (let ip = 0; ip < poiModel.rowCount(); ip++) {
                                    const poi = poiModel.at(ip)
                                    if (poi.id === modelData.id) {
                                        poiModel.removeItemAt(ip)
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
                            if (poi.details && poi.details.metadata && poi.details.metadata.note) {
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

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            mapObjectDetailsPanel.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }

    Component.onCompleted: {
        console.log("✅ MapObjectDetailsPanel loaded")
        // Auto-expand if there are selected objects
        if (selectedObjects && selectedObjects.length > 0) {
            detailsPanelExpanded = true
        }
    }

    Connections {
        target: LayerManager
        function onSelectedObjectsChanged() {
            console.log("🔁 MapObjectDetailsPanel - Selected objects updated:", LayerManager.selectedObjects?.length || 0)
            selectedObjects = LayerManager.selectedObjects

            // Auto-expand when objects are selected
            if (selectedObjects && selectedObjects.length > 0) {
                detailsPanelExpanded = true
            }
        }
    }
}
