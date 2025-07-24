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
    radius: 6
    border.color: "#dddddd"
    border.width: 2

    property var polygonCoordinates: []
    property var originalPolygonPath: [] // Mantieni il path originale con punto di chiusura
    property bool isUpdatingFromExternal: false // Flag per prevenire loop

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

        // CORREZIONE: NON includere il campo "index" nel modello
        for (let i = 0; i < displayCoordinates.length; i++) {
            coordinatesModel.append({
                // RIMUOVI COMPLETAMENTE: index: i + 1,
                latitude: displayCoordinates[i].latitude.toFixed(6),
                longitude: displayCoordinates[i].longitude.toFixed(6)
            })
        }

        polygonCoordinates = displayCoordinates

        Qt.callLater(function() {
            isUpdatingFromExternal = false
            console.log("=== setPolygonCoordinates completed, flag reset ===")
        })
    }


    function updateCoordinatesFromModel() {
        console.log("=== updateCoordinatesFromModel called ===")
        console.log("isUpdatingFromExternal:", isUpdatingFromExternal)

        // RIPRISTINA QUESTO CONTROLLO ESSENZIALE!
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

            // Validazione range più specifica
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

        if (newCoordinates.length >= 3) {
            console.log("=== UPDATING POLYGON ===")
            console.log("Old polygonCoordinates count:", polygonCoordinates.length)

            polygonCoordinates = newCoordinates

            // Crea il path chiuso per il disegno
            var closedPath = [...newCoordinates]
            closedPath.push(closedPath[0]) // Aggiungi il primo punto alla fine per chiudere

            console.log("New polygonCoordinates count:", polygonCoordinates.length)
            console.log("Closed path count:", closedPath.length)

            // IMPORTANTE: Segnala che stiamo per emettere un segnale dal popup
            console.log("=== EMITTING polygonChanged FROM POPUP ===")

            // Stampa le coordinate per debug
            for (let i = 0; i < closedPath.length; i++) {
                console.log(`Closed path[${i}]: ${closedPath[i].latitude}, ${closedPath[i].longitude}`)
            }

            polygonChanged(closedPath)
        } else {
            console.error("NOT ENOUGH valid coordinates for polygon:", newCoordinates.length)
        }
    }

    // Funzione helper per creare un path chiuso
    function createClosedPath(coordinates) {
        if (coordinates.length < 3) return coordinates

        var closedPath = [...coordinates]
        // Aggiungi il primo punto alla fine se non è già presente
        const firstPoint = closedPath[0]
        const lastPoint = closedPath[closedPath.length - 1]

        if (Math.abs(firstPoint.latitude - lastPoint.latitude) > 0.000001 ||
            Math.abs(firstPoint.longitude - lastPoint.longitude) > 0.000001) {
            closedPath.push(firstPoint)
        }

        return closedPath
    }

    // Funzione helper per validare input coordinate
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
            color: "black"
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
                    color: "black"
                }
                TextField {
                    id: labelField
                    placeholderText: "Enter label..."
                    font.pixelSize: 14
                    color: "black"
                    Layout.fillWidth: true
                    background: Rectangle {
                        radius: 2
                        border.color: "#888888"
                        color: "white"
                    }
                }
            }

            // === Category ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: "Category"
                    color: "black"
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
                    color: "black"
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
                    color: "black"
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
                    color: "black"
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

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Polygon Vertices"
                        color: "black"
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    StyledButton {
                        text: "Add Point"
                        font.pixelSize: 12
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 24
                        enabled: coordinatesModel.count < 50
                        onClicked: {
                            coordinatesModel.append({
                                // RIMUOVI COMPLETAMENTE: index: coordinatesModel.count + 1,
                                latitude: "0.000000",
                                longitude: "0.000000"
                            })
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    border.color: "#888888"
                    border.width: 1
                    radius: 2

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
                            color: index % 2 === 0 ? "#f5f5f5" : "white"
                            border.color: "#e0e0e0"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8

                                Label {
                                    text: "Point " + (index + 1) // CORREZIONE: usa index + 1 invece di model.index
                                    color: "black"
                                    Layout.preferredWidth: 50
                                    font.pixelSize: 12
                                }

                                TextField {
                                    id: latField
                                    text: model.latitude
                                    placeholderText: "Latitude"
                                    font.pixelSize: 12
                                    color: "black"
                                    Layout.fillWidth: true

                                    property bool isValidInput: true
                                    property string lastValidValue: model.latitude

                                    function validateInput(value) {
                                        const num = parseFloat(value)
                                        return !isNaN(num) && num >= -90.0 && num <= 90.0
                                    }

                                    background: Rectangle {
                                        radius: 2
                                        border.color: latField.isValidInput ? "#cccccc" : "#ff6b6b"
                                        border.width: latField.isValidInput ? 1 : 2
                                        color: "white"
                                    }

                                    onTextChanged: {
                                        isValidInput = validateInput(text)
                                    }

                                    onEditingFinished: {
                                        console.log("=== LATITUDE EDITING FINISHED ===")
                                        console.log("Field text:", text, "Model value:", model.latitude, "Valid:", isValidInput)
                                        console.log("Delegate index:", index, "of", coordinatesModel.count, "total items")

                                        // VERIFICA CHE L'INDEX SIA VALIDO
                                        if (index < 0 || index >= coordinatesModel.count) {
                                            console.error("INDEX OUT OF RANGE! index:", index, "count:", coordinatesModel.count)
                                            return
                                        }

                                        if (isValidInput && text !== model.latitude) {
                                            console.log("UPDATING latitude from", model.latitude, "to", text)

                                            // Verifica che l'item esista prima di aggiornarlo
                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                console.error("Item at index", index, "does not exist!")
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "latitude", text)
                                            lastValidValue = text

                                            // Aggiorna il model immediatamente
                                            updateCoordinatesFromModel()
                                        } else if (!isValidInput) {
                                            console.log("INVALID latitude, reverting to:", lastValidValue)
                                            text = lastValidValue
                                            isValidInput = true
                                        } else {
                                            console.log("No change needed - same value")
                                        }
                                    }

                                    Component.onCompleted: {
                                        if (model && model.latitude) {
                                            lastValidValue = model.latitude
                                        }
                                    }
                                }

                                TextField {
                                    id: lonField
                                    text: model.longitude
                                    placeholderText: "Longitude"
                                    font.pixelSize: 12
                                    color: "black"
                                    Layout.fillWidth: true

                                    property bool isValidInput: true
                                    property string lastValidValue: model.longitude

                                    function validateInput(value) {
                                        const num = parseFloat(value)
                                        return !isNaN(num) && num >= -180.0 && num <= 180.0
                                    }

                                    background: Rectangle {
                                        radius: 2
                                        border.color: lonField.isValidInput ? "#cccccc" : "#ff6b6b"
                                        border.width: lonField.isValidInput ? 1 : 2
                                        color: "white"
                                    }

                                    onTextChanged: {
                                        isValidInput = validateInput(text)
                                    }

                                    onEditingFinished: {
                                        console.log("=== LONGITUDE EDITING FINISHED ===")
                                        console.log("Field text:", text, "Model value:", model.longitude, "Valid:", isValidInput)
                                        console.log("Delegate index:", index, "of", coordinatesModel.count, "total items")

                                        // VERIFICA CHE L'INDEX SIA VALIDO
                                        if (index < 0 || index >= coordinatesModel.count) {
                                            console.error("INDEX OUT OF RANGE! index:", index, "count:", coordinatesModel.count)
                                            return
                                        }

                                        if (isValidInput && text !== model.longitude) {
                                            console.log("UPDATING longitude from", model.longitude, "to", text)

                                            // Verifica che l'item esista prima di aggiornarlo
                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                console.error("Item at index", index, "does not exist!")
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "longitude", text)
                                            lastValidValue = text

                                            // Aggiorna il model immediatamente
                                            updateCoordinatesFromModel()
                                        } else if (!isValidInput) {
                                            console.log("INVALID longitude, reverting to:", lastValidValue)
                                            text = lastValidValue
                                            isValidInput = true
                                        } else {
                                            console.log("No change needed - same value")
                                        }
                                    }

                                    Component.onCompleted: {
                                        if (model && model.longitude) {
                                            lastValidValue = model.longitude
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
                                        // RIMUOVI la rinumerazione degli indici - non è necessaria
                                        updateCoordinatesFromModel()
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    text: {
                        const count = coordinatesModel.count
                        if (count < 3) {
                            return `Points: ${count} (${3 - count} more needed to form a polygon)`
                        } else {
                            return `Points: ${count} (valid polygon)`
                        }
                    }
                    color: coordinatesModel.count >= 3 ? "#22c55e" : "#ef4444"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            // === Note ===
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Label {
                    text: "Note"
                    color: "black"
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
                        color: "black"
                        wrapMode: TextEdit.Wrap
                        padding: 4
                        background: Rectangle {
                            radius: 2
                            border.color: "#888888"
                            color: "white"
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
                    enabled: !!labelField.text && coordinatesModel.count >= 3
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
                            // Per il server, usa le coordinate modificate invece di originalPolygonPath
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
