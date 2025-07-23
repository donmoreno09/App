import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0

Rectangle {
    id: popup

    property var title
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

    width: 320
    height: 36 + popupContent.implicitHeight + 12
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
        topLeftLat.text = ""
        topLeftLon.text = ""
        bottomRightLat.text = ""
        bottomRightLon.text = ""
    }

    function setCoordinates(topLat, topLon, bottomLat, bottomLon) {
        topLeftLat.text = topLat.toFixed(6)
        topLeftLon.text = topLon.toFixed(6)
        bottomRightLat.text = bottomLat.toFixed(6)
        bottomRightLon.text = bottomLon.toFixed(6)
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
            text: "Insert Area POI"
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
            onActiveChanged: mouseArea.cursorShape = active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.OpenHandCursor
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
        }
    }

    ColumnLayout {
        id: popupContent
        spacing: 12
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12

        // === Label ===
        ColumnLayout {
            spacing: 2
            Label { text: "Label"; color: "black" }
            TextField {
                id: labelField
                placeholderText: "Enter label..."
                Layout.fillWidth: true
                background: Rectangle { radius: 2; border.color: "#888888" }
            }
        }

        // === Category ===
        ColumnLayout {
            spacing: 2
            Label { text: "Category"; color: "black" }
            StyledComboBox {
                id: categoryComboBox
                model: []
                Layout.fillWidth: true
            }
        }

        // === Type ===
        ColumnLayout {
            spacing: 2
            Label { text: "Type"; color: "black" }
            StyledComboBox {
                id: typeComboBox
                model: []
                Layout.fillWidth: true
            }
        }

        // === Health Status ===
        ColumnLayout {
            spacing: 2
            Label { text: "Health Status"; color: "black" }
            StyledComboBox {
                id: healthStatusComboBox
                model: PoiOptionsController.healthStatuses
                textRole: "value"
                Layout.fillWidth: true
            }
        }

        // === Operational State ===
        ColumnLayout {
            spacing: 2
            Label { text: "Operational State"; color: "black" }
            StyledComboBox {
                id: operationalStateComboBox
                model: PoiOptionsController.operationalStates
                textRole: "value"
                Layout.fillWidth: true
            }
        }

        // === Coordinate inputs ===
        GridLayout {
            columns: 2
            columnSpacing: 6
            rowSpacing: 4
            Layout.fillWidth: true

            Label { text: "Top Left Latitude" }
            TextField {
                id: topLeftLat
                validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Top Left Longitude" }
            TextField {
                id: topLeftLon
                validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Bottom Right Latitude" }
            TextField {
                id: bottomRightLat
                validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Bottom Right Longitude" }
            TextField {
                id: bottomRightLon
                validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
                onEditingFinished: validateRectangle()
            }
        }

        // === Note ===
        ColumnLayout {
            spacing: 2
            Label { text: "Note"; color: "black" }
            ScrollView {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
                TextArea {
                    id: noteField
                    placeholderText: "Enter a note..."
                    wrapMode: TextEdit.Wrap
                    background: Rectangle { radius: 2; border.color: "#888888" }
                }
            }
        }

        // === Buttons ===
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignRight

            StyledButton {
                text: "Cancel"
                onClicked: {
                    popup.clearForm()
                    popup.close()
                }
            }

            StyledButton {
                text: "Save"
                enabled: !!labelField.text && !!topLeftLat.text && !!topLeftLon.text && !!bottomRightLat.text && !!bottomRightLon.text
                onClicked: {
                    const categories = PoiOptionsController.types
                    const category = categories.find((c) => c.name === categoryComboBox.currentText)
                    const type = category.values.find((v) => v.value === typeComboBox.currentText)
                    const healthStatus = PoiOptionsController.healthStatuses[healthStatusComboBox.currentIndex]
                    const operationalState = PoiOptionsController.operationalStates[operationalStateComboBox.currentIndex]

                    saveClicked({
                        id: null,
                        category,
                        type,
                        healthStatus,
                        operationalState,
                        label: labelField.text,
                        note: noteField.text,
                        topLeft: QtPositioning.coordinate(parseFloat(topLeftLat.text), parseFloat(topLeftLon.text)),
                        bottomRight: QtPositioning.coordinate(parseFloat(bottomRightLat.text), parseFloat(bottomRightLon.text))
                    })

                    popup.clearForm()
                    popup.close()
                }
            }
        }
    }

    function validateRectangle() {
        let lat1 = parseFloat(topLeftLat.text)
        let lon1 = parseFloat(topLeftLon.text)
        let lat2 = parseFloat(bottomRightLat.text)
        let lon2 = parseFloat(bottomRightLon.text)

        if (!isNaN(lat1) && !isNaN(lon1) && !isNaN(lat2) && !isNaN(lon2)) {
            rectangleChanged(lat1, lon1, lat2, lon2)
        }
    }
}
