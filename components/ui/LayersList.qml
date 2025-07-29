import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import raise.singleton.layermanager 1.0
import raise.singleton.controllers 1.0

Item {
    id: layersList
    width: parent.width
    height: parent.height
    clip: true

    property var layers: LayerManager.layerList
    property var selectedObjects: LayerManager.selectedObjects
    property bool detailsPanelExpanded: false

    signal requestSidepanelOpen()

    ColumnLayout {
        id: layerColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // LAYERS SELECTOR SECTION
        Text {
            text: "Layers Selector"
            font.pixelSize: 20
            font.bold: true
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            height: 1
            color: "#444"
            Layout.fillWidth: true
        }

        // Layers List
        Repeater {
            model: layers

            delegate: Rectangle {
                width: parent.width
                height: 60
                radius: 10
                color: "#101e2c"
                border.color: "#2d3b50"
                border.width: 1
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: "#ffcccb"
                        border.color: "#999"
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Button {
                        text: modelData.layerName
                        Layout.fillWidth: true
                        height: 36

                        background: Rectangle {
                            color: modelData.onFocus ? "#2e4e70" : "#1c2a38"
                            radius: 6
                            border.color: "#3a506b"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: modelData.layerName
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            anchors.fill: parent
                        }

                        onClicked: {
                            console.log("Layer selected:", modelData.layerName)
                            modelData.onFocus = !modelData.onFocus
                            LayerManager.setFocusLayer(modelData.layerName)
                        }
                    }

                    ToolButton {
                        width: 36
                        height: 36
                        onClicked: modelData.isVisible = !modelData.isVisible

                        background: Rectangle {
                            color: modelData.isVisible ? "#2e4e70" : "#1c2a38"
                            radius: 6
                        }

                        contentItem: Image {
                            source: modelData.isVisible ? "assets/eye.svg" : "assets/eye-off.svg"
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Switch {
                        checked: modelData.isEnabled
                        onToggled: modelData.isEnabled = checked
                        palette.highlight: "#2e4e70"
                        palette.base: "#333"
                    }
                }
            }
        }

        // SELECTED ASSETS SECTION
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: detailsPanelExpanded
            Layout.minimumHeight: 40
            height: detailsPanelExpanded ? 0 : 40
            color: "#101e2c"
            border.color: "#2d3b50"
            border.width: 1
            radius: 10
            visible: selectedObjects && selectedObjects.length > 0

            // Behavior on height {
            //     NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            // }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // Header with expand/collapse button
                RowLayout {
                    Layout.fillWidth: true
                    height: 30

                    Text {
                        text: "Selected Assets (" + (selectedObjects ? selectedObjects.length : 0) + ")"
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
                            color: "#1c2a38"
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
                                    text: "Label: " + JSON.stringify(modelData.label)
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
                                        text: "Edit"

                                        onClicked: {

                                            console.log("=== POPUP DEBUG ===")
                                                console.log("poiPopup exists:", !!poiPopup)
                                                console.log("ellipsePoiPopup exists:", !!ellipsePoiPopup)
                                                console.log("rectanglePoiPopup exists:", !!rectanglePoiPopup)
                                                console.log("polygonPoiPopup exists:", !!polygonPoiPopup)

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

                                                    // Per Rectangle
                                                    if (modelData.geometry.coordinates && modelData.geometry.coordinates.length === 4) {
                                                        const coords = modelData.geometry.coordinates
                                                        rectanglePoiPopup.topLeftLat.text = coords[0].y.toFixed(6)
                                                        rectanglePoiPopup.topLeftLon.text = coords[0].x.toFixed(6)
                                                        rectanglePoiPopup.bottomRightLat.text = coords[2].y.toFixed(6)
                                                        rectanglePoiPopup.bottomRightLon.text = coords[2].x.toFixed(6)
                                                    }

                                                    // Per Polygon
                                                    if (modelData.geometry.coordinates) {
                                                        const coordinates = modelData.geometry.coordinates.map(coord =>
                                                            QtPositioning.coordinate(coord.y, coord.x)
                                                        )
                                                        polygonPoiPopup.setPolygonCoordinates(coordinates)
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

                                                    if (modelData.geometry.coordinates.length === 5) {
                                                        rectanglePoiPopup.open()
                                                     } else {
                                                         polygonPoiPopup.open()
                                                     }
                                                } else {
                                                    poiPopup.open()
                                                }
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

                            // Popup components for each item
                            PoiPopup {
                                id: poiPopup
                                title: `Update ${modelData.label}?`
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

                            RectanglePoiPopup {
                                id: rectanglePoiPopup
                                title: `Update ${modelData.label}?`
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
                                        // Adatta questa logica in base a come sono strutturati i tuoi dati rectangle
                                        dataToSave.geometry.topLeft = {
                                            x: Number(details.topLeft.longitude),
                                            y: Number(details.topLeft.latitude)
                                        }
                                        dataToSave.geometry.bottomRight = {
                                            x: Number(details.bottomRight.longitude),
                                            y: Number(details.bottomRight.latitude)
                                        }
                                    }

                                    console.log("UPDATE RECTANGLE POI:", JSON.stringify(dataToSave))
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

                            EllipsePoiPopup {
                                id: ellipsePoiPopup
                                title: `Update ${modelData.label}?`
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

                            PolygonPoiPopup {
                                id: polygonPoiPopup
                                title: `Update ${modelData.label}?`
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
                                    const dataToSave = JSON.parse(JSON.stringify(modelData))
                                    dataToSave.label = details.label

                                    console.log("UPDATE SHAPE:", JSON.stringify(dataToSave))
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
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: {
        console.log("✅ LayersList loaded. layerList:", layers)
        // Auto-expand if there are selected objects
        if (selectedObjects && selectedObjects.length > 0) {
            detailsPanelExpanded = true
        }
    }

    Connections {
        target: LayerManager
        function onLayerListChanged() {
            console.log("🔁 layerList updated. New value:", LayerManager.layerList)
            layers = LayerManager.layerList
        }
    }

    Connections {
        target: LayerManager
        function onSelectedObjectsChanged() {
            console.log("🔁 Oggetti selezionati aggiornati:\n" + JSON.stringify(LayerManager.selectedObjects, null, 2))
            selectedObjects = LayerManager.selectedObjects

            // Auto-expand when objects are selected
            if (selectedObjects && selectedObjects.length > 0) {
                detailsPanelExpanded = true
                requestSidepanelOpen()
            }
        }
    }
}
