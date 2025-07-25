import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0

Rectangle {
    id: popup
    property string title: "Insert Rectangle POI"
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal rectangleChanged(real topLat, real topLon, real bottomLat, real bottomLon)

    width: 340
    height: Math.min(600, 36 + popupContent.implicitHeight + 12)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    radius: 12
    color: "#1F3154"
    border.color: "#333333"
    border.width: 1

    // Proprietà per validazione
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
        topLeftLat.text = ""
        topLeftLon.text = ""
        bottomRightLat.text = ""
        bottomRightLon.text = ""
        coordinatesAreValid = false
    }

    function setCoordinates(topLat, topLon, bottomLat, bottomLon) {
        topLeftLat.text = topLat.toFixed(6)
        topLeftLon.text = topLon.toFixed(6)
        bottomRightLat.text = bottomLat.toFixed(6)
        bottomRightLon.text = bottomLon.toFixed(6)
        checkCoordinatesValidity()
    }

    // Funzione per controllare se le coordinate formano un rettangolo valido
    function checkCoordinatesValidity() {
        var lat1 = parseFloat(topLeftLat.text)
        var lon1 = parseFloat(topLeftLon.text)
        var lat2 = parseFloat(bottomRightLat.text)
        var lon2 = parseFloat(bottomRightLon.text)

        // Prima verifica: tutti i numeri devono essere validi
        var numbersValid = !isNaN(lat1) && !isNaN(lon1) && !isNaN(lat2) && !isNaN(lon2)

        // Seconda verifica: devono essere nei range corretti
        var rangesValid = numbersValid &&
                         lat1 >= -90 && lat1 <= 90 &&
                         lat2 >= -90 && lat2 <= 90 &&
                         lon1 >= -180 && lon1 <= 180 &&
                         lon2 >= -180 && lon2 <= 180

        // Terza verifica: devono formare un rettangolo logico
        // TopLeft deve essere a nord-ovest di BottomRight
        var rectangleValid = rangesValid &&
                           lat1 > lat2 &&  // Top deve essere più a nord (latitudine maggiore)
                           lon1 < lon2     // Left deve essere più a ovest (longitudine minore)

        coordinatesAreValid = rectangleValid

        console.log("Coordinate validation:", {
            lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2,
            numbersValid: numbersValid,
            rangesValid: rangesValid,
            rectangleValid: rectangleValid,
            coordinatesAreValid: coordinatesAreValid
        })

        return coordinatesAreValid
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

            // === Coordinate inputs ===
            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true

                Label {
                    text: "Rectangle Coordinates"
                    color: "#ffffff"
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 4
                    Layout.fillWidth: true

                    Label {
                        text: "Top Left Latitude"
                        color: "#ffffff"
                        Layout.preferredWidth: 120
                    }
                    TextField {
                        id: topLeftLat
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -90.0
                            top: 90.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateRectangle()
                    }

                    Label {
                        text: "Top Left Longitude"
                        color: "#ffffff"
                    }
                    TextField {
                        id: topLeftLon
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -180.0
                            top: 180.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateRectangle()
                    }

                    Label {
                        text: "Bottom Right Latitude"
                        color: "#ffffff"
                    }
                    TextField {
                        id: bottomRightLat
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -90.0
                            top: 90.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateRectangle()
                    }

                    Label {
                        text: "Bottom Right Longitude"
                        color: "#ffffff"
                    }
                    TextField {
                        id: bottomRightLon
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -180.0
                            top: 180.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateRectangle()
                    }
                }

                // Messaggio di stato
                Label {
                    visible: !!topLeftLat.text || !!topLeftLon.text || !!bottomRightLat.text || !!bottomRightLon.text
                    text: {
                        if (coordinatesAreValid) {
                            return "✓ Valid rectangle coordinates"
                        } else {
                            return "⚠ Invalid coordinates "
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
                    // CONDIZIONE AGGIORNATA: deve avere label E coordinate valide
                    enabled: !!labelField.text && coordinatesAreValid
                    onClicked: {
                        // Ottieni le categorie area POI (primi 4)
                        const categories = PoiOptionsController.types.slice(0, 4)
                        const category = categories.find((c) => c.name === categoryComboBox.currentText)
                        const type = category ? category.values.find((v) => v.value === typeComboBox.currentText) : null
                        const healthStatus = PoiOptionsController.healthStatuses[healthStatusComboBox.currentIndex]
                        const operationalState = PoiOptionsController.operationalStates[operationalStateComboBox.currentIndex]

                        // Crea l'oggetto details con tutti i campi necessari
                        const details = {
                            id: null,
                            category: category,
                            type: type,
                            healthStatus: healthStatus,
                            operationalState: operationalState,
                            label: labelField.text,
                            note: noteField.text,
                            // Per area POI serve il rettangolo, non lat/lng singole
                            topLeft: QtPositioning.coordinate(
                                parseFloat(topLeftLat.text),
                                parseFloat(topLeftLon.text)
                            ),
                            bottomRight: QtPositioning.coordinate(
                                parseFloat(bottomRightLat.text),
                                parseFloat(bottomRightLon.text)
                            )
                        }

                        console.log("Area POI Save Details:", JSON.stringify({
                            category: category ? category.name : "null",
                            type: type ? type.value : "null",
                            healthStatus: healthStatus ? healthStatus.value : "null",
                            operationalState: operationalState ? operationalState.value : "null",
                            label: details.label,
                            note: details.note
                        }))

                        saveClicked(details)
                        popup.clearForm()
                        popup.close()
                    }
                }
            }
        }
    }

    function validateRectangle() {
        if (checkCoordinatesValidity()) {
            let lat1 = parseFloat(topLeftLat.text)
            let lon1 = parseFloat(topLeftLon.text)
            let lat2 = parseFloat(bottomRightLat.text)
            let lon2 = parseFloat(bottomRightLon.text)
            rectangleChanged(lat1, lon1, lat2, lon2)
        }
    }
}
