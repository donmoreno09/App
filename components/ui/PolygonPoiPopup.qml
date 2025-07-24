import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0

Rectangle {
    id: popup
    property string title: "Insert Polygon POI"
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField

    // IMPORTANTE: nascosto di default
    visible: false

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal polygonChanged(var coordinates)

    width: 380
    height: Math.min(700, 36 + popupContent.implicitHeight + 12)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    radius: 12
    color: "#1F3154"
    border.color: "#333333"
    border.width: 1

    property var polygonCoordinates: []
    property var originalPolygonPath: [] // Mantieni il path originale con punto di chiusura
    property bool isUpdatingFromExternal: false // Flag per prevenire loop
    property bool coordinatesAreValid: false

    function open() {
        popup.visible = true
        popup.opened()
    }

    function close() {
        popup.visible = false
        popup.closed()
    }

    function bringToFront() {
        PopupManager.bringToFront(popup)
    }

    function clearForm() {
        labelField.text = ""
        noteField.text = ""
        polygonCoordinates = []
        originalPolygonPath = []
        coordinatesModel.clear()
        coordinatesAreValid = false
    }

    function setPolygonCoordinates(coordinates) {
        console.log("=== setPolygonCoordinates called ===")
        console.log("Current isUpdatingFromExternal:", isUpdatingFromExternal)

        if (isUpdatingFromExternal) {
            console.log("PREVENTED LOOP in setPolygonCoordinates")
            return
        }

        console.log("setPolygonCoordinates called with", coordinates.length, "points")
        isUpdatingFromExternal = true
        coordinatesModel.clear()

        originalPolygonPath = coordinates

        let displayCoordinates = []
        for (let i = 0; i < coordinates.length; i++) {
            if (i === coordinates.length - 1 && coordinates.length > 1) {
                const firstPoint = coordinates[0]
                if (Math.abs(coordinates[i].latitude - firstPoint.latitude) < 0.000001 &&
                    Math.abs(coordinates[i].longitude - firstPoint.longitude) < 0.000001) {
                    console.log("Hiding closing point from UI (duplicate of first point)")
                    continue
                }
            }
            displayCoordinates.push(coordinates[i])
        }

        console.log("Original coordinates:", coordinates.length, "-> Display coordinates:", displayCoordinates.length)

        for (let i = 0; i < displayCoordinates.length; i++) {
            coordinatesModel.append({
                latitude: displayCoordinates[i].latitude.toFixed(6),
                longitude: displayCoordinates[i].longitude.toFixed(6)
            })
        }

        polygonCoordinates = displayCoordinates
        checkCoordinatesValidity()

        Qt.callLater(function() {
            isUpdatingFromExternal = false
            console.log("=== setPolygonCoordinates completed, flag reset ===")
        })
    }

    function checkCoordinatesValidity() {
        // Un poligono è valido se ha almeno 3 punti con coordinate valide
        var validCount = 0

        for (let i = 0; i < coordinatesModel.count; i++) {
            const item = coordinatesModel.get(i)
            const lat = parseFloat(item.latitude)
            const lon = parseFloat(item.longitude)

            if (!isNaN(lat) && !isNaN(lon) &&
                lat >= -90 && lat <= 90 &&
                lon >= -180 && lon <= 180) {
                validCount++
            }
        }

        coordinatesAreValid = validCount >= 3
        console.log("Polygon validation - valid points:", validCount, "isValid:", coordinatesAreValid)
        return coordinatesAreValid
    }

    function updateCoordinatesFromModel() {
        console.log("=== updateCoordinatesFromModel called ===")
        console.log("isUpdatingFromExternal:", isUpdatingFromExternal)

        if (isUpdatingFromExternal) {
            console.log("BLOCKED by isUpdatingFromExternal flag - preventing loop")
            return
        }

        var newCoordinates = []

        console.log("Processing", coordinatesModel.count, "coordinates from model")

        for (let i = 0; i < coordinatesModel.count; i++) {
            const item = coordinatesModel.get(i)
            const latStr = item.latitude
            const lonStr = item.longitude
            const lat = parseFloat(latStr)
            const lon = parseFloat(lonStr)

            console.log(`Point ${i}: lat="${latStr}" -> ${lat}, lon="${lonStr}" -> ${lon}`)

            if (isNaN(lat) || lat < -90 || lat > 90) {
                console.error("INVALID LATITUDE at index", i, ":", lat, "from string:", latStr)
                continue
            }
            if (isNaN(lon) || lon < -180 || lon > 180) {
                console.error("INVALID LONGITUDE at index", i, ":", lon, "from string:", lonStr)
                continue
            }

            newCoordinates.push(QtPositioning.coordinate(lat, lon))
        }

        console.log("Valid coordinates found:", newCoordinates.length, "of", coordinatesModel.count)

        polygonCoordinates = newCoordinates
        checkCoordinatesValidity()

        if (newCoordinates.length >= 3) {
            console.log("=== UPDATING POLYGON ===")

            var closedPath = [...newCoordinates]
            closedPath.push(closedPath[0])

            console.log("New polygonCoordinates count:", polygonCoordinates.length)
            console.log("Closed path count:", closedPath.length)

            console.log("=== EMITTING polygonChanged FROM POPUP ===")

            for (let i = 0; i < closedPath.length; i++) {
                console.log(`Closed path[${i}]: ${closedPath[i].latitude}, ${closedPath[i].longitude}`)
            }

            polygonChanged(closedPath)
        } else {
            console.error("NOT ENOUGH valid coordinates for polygon:", newCoordinates.length)
        }
    }

    function createClosedPath(coordinates) {
        if (coordinates.length < 3) return coordinates

        var closedPath = [...coordinates]
        const firstPoint = closedPath[0]
        const lastPoint = closedPath[closedPath.length - 1]

        if (Math.abs(firstPoint.latitude - lastPoint.latitude) > 0.000001 ||
            Math.abs(firstPoint.longitude - lastPoint.longitude) > 0.000001) {
            closedPath.push(firstPoint)
        }

        return closedPath
    }

    function isValidCoordinate(value, isLatitude) {
        const num = parseFloat(value)
        if (isNaN(num)) return false

        if (isLatitude) {
            return num >= -90.0 && num <= 90.0
        } else {
            return num >= -180.0 && num <= 180.0
        }
    }

    Component.onCompleted: bringToFront()
    Component.onDestruction: PopupManager.unregister(popup)

    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: bringToFront()
    }

    Rectangle {
        id: header
        height: 36
        width: parent.width
        color: "transparent"

        Text {
            text: popup.title
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            font.bold: true
            color: "#ffffff"
        }

        DragHandler {
            target: popup
            xAxis.enabled: true
            xAxis.minimum: 0
            xAxis.maximum: popup.parent.width - popup.width
            yAxis.enabled: true
            yAxis.minimum: 0
            yAxis.maximum: popup.parent.height - popup.height
            onActiveChanged: {
                if (active) mouseArea.cursorShape = Qt.ClosedHandCursor
                else mouseArea.cursorShape = Qt.OpenHandCursor
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.OpenHandCursor
            onPressed: {
                cursorShape = Qt.ClosedHandCursor
                popup.bringToFront()
            }
            onReleased: cursorShape = Qt.OpenHandCursor
        }
    }

    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        contentHeight: popupContent.implicitHeight

        ColumnLayout {
            id: popupContent
            spacing: 12
            width: popup.width - 24

            // === Label ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Label"
                    color: "#ffffff"
                }
                TextField {
                    id: labelField
                    placeholderText: "Enter label..."
                    font.pixelSize: 14
                    color: "#ffffff"
                    Layout.fillWidth: true
                    background: Rectangle {
                        radius: 6
                        color: "#2a2a2a"
                        border.color: "#444444"
                    }
                }
            }

            // === Category ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Category"
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: categoryComboBox
                    model: []
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            // === Type ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Type"
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: typeComboBox
                    model: []
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            // === Health Status ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Health Status"
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: healthStatusComboBox
                    model: PoiOptionsController.healthStatuses
                    textRole: "value"
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            // === Operational State ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Operational State"
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: operationalStateComboBox
                    model: PoiOptionsController.operationalStates
                    textRole: "value"
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            // === Polygon Coordinates ===
            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true

                Label {
                    text: "Polygon Vertices"
                    color: "#ffffff"
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "#2a2a2a"
                    border.color: "#444444"
                    border.width: 1
                    radius: 6

                    ListView {
                        id: coordinatesList
                        anchors.fill: parent
                        anchors.margins: 4
                        model: ListModel {
                            id: coordinatesModel
                        }

                        delegate: Rectangle {
                            width: coordinatesList.width
                            height: 40
                            color: index % 2 === 0 ? "#333333" : "#2a2a2a"
                            border.color: "#444444"
                            border.width: 1
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8

                                Label {
                                    text: "Point " + (index + 1)
                                    color: "#ffffff"
                                    Layout.preferredWidth: 50
                                    font.pixelSize: 12
                                }

                                TextField {
                                    id: latField
                                    text: model.latitude
                                    placeholderText: "Latitude"
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    Layout.fillWidth: true

                                    background: Rectangle {
                                        radius: 4
                                        color: "#1F3154"
                                        border.color: "#555555"
                                        border.width: 1
                                    }

                                    onEditingFinished: {
                                        console.log("=== LATITUDE EDITING FINISHED ===")
                                        console.log("Field text:", text, "Model value:", model.latitude)
                                        console.log("Delegate index:", index, "of", coordinatesModel.count, "total items")

                                        if (index < 0 || index >= coordinatesModel.count) {
                                            console.error("INDEX OUT OF RANGE! index:", index, "count:", coordinatesModel.count)
                                            return
                                        }

                                        if (text !== model.latitude) {
                                            console.log("UPDATING latitude from", model.latitude, "to", text)

                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                console.error("Item at index", index, "does not exist!")
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "latitude", text)
                                            updateCoordinatesFromModel()
                                        } else {
                                            console.log("No change needed - same value")
                                        }
                                    }
                                }

                                TextField {
                                    id: lonField
                                    text: model.longitude
                                    placeholderText: "Longitude"
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    Layout.fillWidth: true

                                    background: Rectangle {
                                        radius: 4
                                        color: "#1F3154"
                                        border.color: "#555555"
                                        border.width: 1
                                    }

                                    onEditingFinished: {
                                        console.log("=== LONGITUDE EDITING FINISHED ===")
                                        console.log("Field text:", text, "Model value:", model.longitude)
                                        console.log("Delegate index:", index, "of", coordinatesModel.count, "total items")

                                        if (index < 0 || index >= coordinatesModel.count) {
                                            console.error("INDEX OUT OF RANGE! index:", index, "count:", coordinatesModel.count)
                                            return
                                        }

                                        if (text !== model.longitude) {
                                            console.log("UPDATING longitude from", model.longitude, "to", text)

                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                console.error("Item at index", index, "does not exist!")
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "longitude", text)
                                            updateCoordinatesFromModel()
                                        } else {
                                            console.log("No change needed - same value")
                                        }
                                    }
                                }

                                StyledButton {
                                    text: "×"
                                    font.pixelSize: 12
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    enabled: coordinatesModel.count > 3
                                    onClicked: {
                                        coordinatesModel.remove(index)
                                        updateCoordinatesFromModel()
                                    }
                                }
                            }
                        }
                    }
                }

                // Status message
                Label {
                    text: {
                        const count = coordinatesModel.count
                        if (coordinatesAreValid) {
                            return `✓ Valid polygon (${count} points)`
                        } else if (count < 3) {
                            return `Points: ${count} (${3 - count} more needed to form a polygon)`
                        } else {
                            return `⚠ Invalid coordinates in polygon`
                        }
                    }
                    color: coordinatesAreValid ? "#22c55e" : "#ef4444"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            // === Note ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Label {
                    text: "Note"
                    color: "#ffffff"
                }
                ScrollView {
                    Layout.preferredHeight: 80
                    Layout.fillWidth: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    TextArea {
                        id: noteField
                        placeholderText: "Enter a note..."
                        font.pixelSize: 14
                        color: "#ffffff"
                        wrapMode: TextEdit.Wrap
                        padding: 4
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                    }
                }
            }

            // === Buttons ===
            RowLayout {
                spacing: 6
                Layout.fillWidth: true
                Layout.topMargin: 12

                // Spacer per spingere i bottoni a destra
                Item {
                    Layout.fillWidth: true
                }

                StyledButton {
                    text: "Cancel"
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    onClicked: {
                        popup.clearForm()
                        popup.close()
                    }
                }

                StyledButton {
                    text: "Save"
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    enabled: !!labelField.text && coordinatesAreValid
                    onClicked: {
                        // Ottieni le categorie area POI (primi 4)
                        const categories = PoiOptionsController.types.slice(0, 4)
                        const category = categories.find((c) => c.name === categoryComboBox.currentText)
                        const type = category ? category.values.find((v) => v.value === typeComboBox.currentText) : null
                        const healthStatus = PoiOptionsController.healthStatuses[healthStatusComboBox.currentIndex]
                        const operationalState = PoiOptionsController.operationalStates[operationalStateComboBox.currentIndex]

                        // Verifica che i dati essenziali siano disponibili
                        if (!category) {
                            console.error("Category not found for:", categoryComboBox.currentText)
                            return
                        }
                        if (!type) {
                            console.error("Type not found for:", typeComboBox.currentText)
                            return
                        }

                        // Crea l'oggetto details con tutti i campi necessari
                        const details = {
                            id: null,
                            category: category,
                            type: type,
                            healthStatus: healthStatus,
                            operationalState: operationalState,
                            label: labelField.text,
                            note: noteField.text,
                            coordinates: createClosedPath(polygonCoordinates)
                        }

                        console.log("Polygon POI Save Details:", JSON.stringify({
                            category: category ? category.name : "null",
                            categoryKey: category ? category.key : "null",
                            type: type ? type.value : "null",
                            typeKey: type ? type.key : "null",
                            healthStatus: healthStatus ? healthStatus.value : "null",
                            healthStatusKey: healthStatus ? healthStatus.key : "null",
                            operationalState: operationalState ? operationalState.value : "null",
                            operationalStateKey: operationalState ? operationalState.key : "null",
                            label: details.label,
                            note: details.note,
                            pointsCount: details.coordinates.length
                        }))

                        saveClicked(details)
                        popup.clearForm()
                        popup.close()
                    }
                }
            }
        }
    }
}
