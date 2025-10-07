import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0

Rectangle {
    id: popup

    // Automatic retranslation properties
    property string titleText: qsTr("Insert Polygon POI")
    property string labelText: qsTr("Label")
    property string enterLabelText: qsTr("Enter label...")
    property string categoryText: qsTr("Category")
    property string typeText: qsTr("Type")
    property string healthStatusText: qsTr("Health Status")
    property string operationalStateText: qsTr("Operational State")
    property string polygonVerticesText: qsTr("Polygon Vertices")
    property string pointText: qsTr("Point")
    property string latitudeText: qsTr("Latitude")
    property string longitudeText: qsTr("Longitude")
    property string validPolygonText: qsTr("✓ Valid polygon")
    property string pointsText: qsTr("Points:")
    property string moreNeededText: qsTr("more needed to form a polygon")
    property string invalidCoordinatesText: qsTr("⚠ Invalid coordinates in polygon")
    property string noteText: qsTr("Note")
    property string enterNoteText: qsTr("Enter a note...")
    property string cancelText: qsTr("Cancel")
    property string saveText: qsTr("Save")

    // Auto-retranslate when language changes
    function retranslateUi() {
        titleText = qsTr("Insert Polygon POI")
        labelText = qsTr("Label")
        enterLabelText = qsTr("Enter label...")
        categoryText = qsTr("Category")
        typeText = qsTr("Type")
        healthStatusText = qsTr("Health Status")
        operationalStateText = qsTr("Operational State")
        polygonVerticesText = qsTr("Polygon Vertices")
        pointText = qsTr("Point")
        latitudeText = qsTr("Latitude")
        longitudeText = qsTr("Longitude")
        validPolygonText = qsTr("✓ Valid polygon")
        pointsText = qsTr("Points:")
        moreNeededText = qsTr("more needed to form a polygon")
        invalidCoordinatesText = qsTr("⚠ Invalid coordinates in polygon")
        noteText = qsTr("Note")
        enterNoteText = qsTr("Enter a note...")
        cancelText = qsTr("Cancel")
        saveText = qsTr("Save")
    }

    property string title: titleText
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField

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
    color: "#f21f3154"
    border.color: "#333333"
    border.width: 1

    property var polygonCoordinates: []
    property var originalPolygonPath: []
    property bool isUpdatingFromExternal: false
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
        if (isUpdatingFromExternal) {
            return
        }

        console.log("setPolygonCoordinates called with:", JSON.stringify(coordinates.map(c => ({lat: c.latitude, lon: c.longitude}))))

        isUpdatingFromExternal = true
        coordinatesModel.clear()

        originalPolygonPath = coordinates

        let displayCoordinates = []

        for (let i = 0; i < coordinates.length; i++) {
            let coord = coordinates[i]
            let lat, lon

            if (typeof coord.latitude !== 'undefined') {
                lat = coord.latitude
                lon = coord.longitude
            } else if (typeof coord.y !== 'undefined') {
                lat = coord.y
                lon = coord.x
            } else {
                continue
            }

            // Skip the last coordinate if it's identical to the first (closed polygon)
            if (i === coordinates.length - 1 && coordinates.length > 1) {
                const firstCoord = coordinates[0]
                let firstLat, firstLon

                if (typeof firstCoord.latitude !== 'undefined') {
                    firstLat = firstCoord.latitude
                    firstLon = firstCoord.longitude
                } else if (typeof firstCoord.y !== 'undefined') {
                    firstLat = firstCoord.y
                    firstLon = firstCoord.x
                }

                if (Math.abs(lat - firstLat) < 0.000001 && Math.abs(lon - firstLon) < 0.000001) {
                    console.log("Skipping duplicate closing coordinate")
                    continue
                }
            }

            displayCoordinates.push(QtPositioning.coordinate(lat, lon))
        }

        console.log("Display coordinates:", displayCoordinates.length)

        for (let j = 0; j < displayCoordinates.length; j++) {
            coordinatesModel.append({
                latitude: displayCoordinates[j].latitude.toFixed(6),
                longitude: displayCoordinates[j].longitude.toFixed(6)
            })
        }

        polygonCoordinates = displayCoordinates
        checkCoordinatesValidity()

        Qt.callLater(function() {
            isUpdatingFromExternal = false
            console.log("Coordinates model now has", coordinatesModel.count, "items")
        })
    }

    function checkCoordinatesValidity() {
        var validCount = 0
        var invalidPoints = []

        for (let i = 0; i < coordinatesModel.count; i++) {
            const item = coordinatesModel.get(i)
            const latStr = item.latitude
            const lonStr = item.longitude

            if (!latStr || latStr.trim() === "" || !lonStr || lonStr.trim() === "") {
                invalidPoints.push(i + 1)
                continue
            }

            const lat = parseFloat(latStr)
            const lon = parseFloat(lonStr)

            if (isNaN(lat) || isNaN(lon)) {
                invalidPoints.push(i + 1)
                continue
            }

            if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                invalidPoints.push(i + 1)
                continue
            }

            validCount++
        }

        coordinatesAreValid = validCount >= 3
        return coordinatesAreValid
    }

    function updateCoordinatesFromModel() {
        if (isUpdatingFromExternal) {
            return
        }

        var newCoordinates = []

        for (let i = 0; i < coordinatesModel.count; i++) {
            const item = coordinatesModel.get(i)
            const latStr = item.latitude
            const lonStr = item.longitude
            const lat = parseFloat(latStr)
            const lon = parseFloat(lonStr)

            if (isNaN(lat) || lat < -90 || lat > 90) {
                continue
            }
            if (isNaN(lon) || lon < -180 || lon > 180) {
                continue
            }

            newCoordinates.push(QtPositioning.coordinate(lat, lon))
        }

        polygonCoordinates = newCoordinates
        checkCoordinatesValidity()

        if (newCoordinates.length >= 3) {
            var closedPath = [...newCoordinates]
            closedPath.push(closedPath[0])
            polygonChanged(closedPath)
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

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: popup.labelText
                    color: "#ffffff"
                }
                TextField {
                    id: labelField
                    placeholderText: popup.enterLabelText
                    placeholderTextColor: "#888888"
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

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: popup.categoryText
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: categoryComboBox
                    model: []
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: popup.typeText
                    color: "#ffffff"
                }
                StyledComboBox {
                    id: typeComboBox
                    model: []
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: popup.healthStatusText
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

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Label {
                    text: popup.operationalStateText
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

            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true

                Label {
                    text: popup.polygonVerticesText
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
                                    text: popup.pointText + " " + (index + 1)
                                    color: "#ffffff"
                                    Layout.preferredWidth: 50
                                    font.pixelSize: 12
                                }

                                TextField {
                                    id: latField
                                    text: model.latitude
                                    placeholderText: popup.latitudeText
                                    placeholderTextColor: "#888888"
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    Layout.fillWidth: true

                                    background: Rectangle {
                                        radius: 4
                                        color: "#f21f3154"
                                        border.color: "#555555"
                                        border.width: 1
                                    }

                                    onEditingFinished: {
                                        if (index < 0 || index >= coordinatesModel.count) {
                                            return
                                        }

                                        if (text !== model.latitude) {
                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "latitude", text)
                                            updateCoordinatesFromModel()
                                        }
                                    }
                                }

                                TextField {
                                    id: lonField
                                    text: model.longitude
                                    placeholderText: popup.longitudeText
                                    placeholderTextColor: "#888888"
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    Layout.fillWidth: true

                                    background: Rectangle {
                                        radius: 4
                                        color: "#f21f3154"
                                        border.color: "#555555"
                                        border.width: 1
                                    }

                                    onEditingFinished: {
                                        if (index < 0 || index >= coordinatesModel.count) {
                                            return
                                        }

                                        if (text !== model.longitude) {
                                            const item = coordinatesModel.get(index)
                                            if (!item) {
                                                return
                                            }

                                            coordinatesModel.setProperty(index, "longitude", text)
                                            updateCoordinatesFromModel()
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

                Label {
                    text: {
                        const count = coordinatesModel.count
                        if (coordinatesAreValid) {
                            return `${popup.validPolygonText} (${count} ${popup.pointsText.toLowerCase()})`
                        } else if (count < 3) {
                            return `${popup.pointsText} ${count} (${3 - count} ${popup.moreNeededText})`
                        } else {
                            return popup.invalidCoordinatesText
                        }
                    }
                    color: coordinatesAreValid ? "#22c55e" : "#ef4444"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Label {
                    text: popup.noteText
                    color: "#ffffff"
                }
                ScrollView {
                    Layout.preferredHeight: 80
                    Layout.fillWidth: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    TextArea {
                        id: noteField
                        placeholderText: popup.enterNoteText
                        placeholderTextColor: "#888888"
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

            RowLayout {
                spacing: 6
                Layout.fillWidth: true
                Layout.topMargin: 12

                Item {
                    Layout.fillWidth: true
                }

                StyledButton {
                    text: popup.cancelText
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    onClicked: {
                        popup.clearForm()
                        popup.close()
                    }
                }

                StyledButton {
                    text: popup.saveText
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    enabled: !!labelField.text && coordinatesAreValid
                    onClicked: {
                        const categories = PoiOptionsController.types.slice(0, 4)
                        const category = categories.find((c) => c.name === categoryComboBox.currentText)
                        const type = category ? category.values.find((v) => v.value === typeComboBox.currentText) : null
                        const healthStatus = PoiOptionsController.healthStatuses[healthStatusComboBox.currentIndex]
                        const operationalState = PoiOptionsController.operationalStates[operationalStateComboBox.currentIndex]

                        if (!category) {
                            return
                        }
                        if (!type) {
                            return
                        }

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

                        saveClicked(details)
                        popup.clearForm()
                        popup.close()
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
            popup.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
