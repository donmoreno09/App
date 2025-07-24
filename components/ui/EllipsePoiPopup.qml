import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0

Rectangle {
    id: popup
    property string title: "Insert Ellipse POI"
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal ellipseChanged(real centerLat, real centerLon, real radiusLat, real radiusLon)

    width: 340
    height: Math.min(600, 36 + popupContent.implicitHeight + 12)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    radius: 6
    border.color: "#dddddd"
    border.width: 2

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
        centerLatField.text = ""
        centerLonField.text = ""
        radiusLatField.text = ""
        radiusLonField.text = ""
    }

    function setEllipseCoordinates(centerLat, centerLon, radiusLat, radiusLon) {
        centerLatField.text = centerLat.toFixed(6)
        centerLonField.text = centerLon.toFixed(6)
        radiusLatField.text = radiusLat.toFixed(6)
        radiusLonField.text = radiusLon.toFixed(6)
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

            // === Ellipse Coordinates ===
            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true

                Label {
                    text: "Ellipse Parameters"
                    color: "black"
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 4
                    Layout.fillWidth: true

                    Label {
                        text: "Center Latitude"
                        color: "black"
                        Layout.preferredWidth: 120
                    }
                    TextField {
                        id: centerLatField
                        placeholderText: "0.000000"
                        font.pixelSize: 14
                        color: "black"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -90.0
                            top: 90.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 2
                            border.color: "#888888"
                        }
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: "Center Longitude"
                        color: "black"
                    }
                    TextField {
                        id: centerLonField
                        placeholderText: "0.000000"
                        font.pixelSize: 14
                        color: "black"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: -180.0
                            top: 180.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 2
                            border.color: "#888888"
                        }
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: "Latitude Radius"
                        color: "black"
                    }
                    TextField {
                        id: radiusLatField
                        placeholderText: "0.000000"
                        font.pixelSize: 14
                        color: "black"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: 0.0
                            top: 90.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 2
                            border.color: "#888888"
                        }
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: "Longitude Radius"
                        color: "black"
                    }
                    TextField {
                        id: radiusLonField
                        placeholderText: "0.000000"
                        font.pixelSize: 14
                        color: "black"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: 0.0
                            top: 180.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 2
                            border.color: "#888888"
                        }
                        onEditingFinished: validateEllipse()
                    }
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
                    enabled: !!labelField.text &&
                            !!centerLatField.text &&
                            !!centerLonField.text &&
                            !!radiusLatField.text &&
                            !!radiusLonField.text
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
                            // Per ellisse POI serve center + radius
                            center: QtPositioning.coordinate(
                                parseFloat(centerLatField.text),
                                parseFloat(centerLonField.text)
                            ),
                            radiusLat: parseFloat(radiusLatField.text),
                            radiusLon: parseFloat(radiusLonField.text)
                        }

                        console.log("Ellipse POI Save Details:", JSON.stringify({
                            category: category ? category.name : "null",
                            type: type ? type.value : "null",
                            healthStatus: healthStatus ? healthStatus.value : "null",
                            operationalState: operationalState ? operationalState.value : "null",
                            label: details.label,
                            note: details.note,
                            center: [details.center.latitude, details.center.longitude],
                            radiusLat: details.radiusLat,
                            radiusLon: details.radiusLon
                        }))

                        saveClicked(details)
                        popup.clearForm()
                        popup.close()
                    }
                }
            }
        }
    }

    function validateEllipse() {
        let centerLat = parseFloat(centerLatField.text)
        let centerLon = parseFloat(centerLonField.text)
        let radiusLat = parseFloat(radiusLatField.text)
        let radiusLon = parseFloat(radiusLonField.text)

        if (!isNaN(centerLat) && !isNaN(centerLon) && !isNaN(radiusLat) && !isNaN(radiusLon)) {
            ellipseChanged(centerLat, centerLon, radiusLat, radiusLon)
        }
    }
}
