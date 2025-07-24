import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8

import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0

import "../ui/top-toolbar/utils.js" as ToolbarUtils

// I'm not using a Popup component since it cannot be
// targeted by DragHandler and I need to style its borders
Rectangle {
    id: popup

    property var title
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboxBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField
    property alias latitudeField: latitudeField
    property alias longitudeField: longitudeField

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal coordinatesChanged(real latitude, real longitude)

    width: 300
    height: 36 + popupContent.implicitHeight + 12
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    radius: 12
    color: "#1F3154"
    border.color: "#333333"
    border.width: 1

    // Property for validation
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
        latitudeField.text = ""
        longitudeField.text = ""
        coordinatesAreValid = false
    }

    function setCoordinates(latitude, longitude) {
        latitudeField.text = latitude.toFixed(6)
        longitudeField.text = longitude.toFixed(6)
        checkCoordinatesValidity()
    }

    // Function to check if coordinates are valid
    function checkCoordinatesValidity() {
        var lat = parseFloat(latitudeField.text)
        var lon = parseFloat(longitudeField.text)

        // First check: all numbers must be valid
        var numbersValid = !isNaN(lat) && !isNaN(lon)

        // Second check: must be in correct ranges
        var rangesValid = numbersValid &&
                         lat >= -90 && lat <= 90 &&
                         lon >= -180 && lon <= 180

        coordinatesAreValid = rangesValid

        console.log("Point validation:", {
            lat: lat, lon: lon,
            numbersValid: numbersValid,
            rangesValid: rangesValid,
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
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 12
            anchors.leftMargin: 12
            font.bold: true
            color: "#ffffff"
        }

        DragHandler {
            target: popup

            // Enable and clamp horizontal movement
            xAxis.enabled: true
            xAxis.minimum: 0
            xAxis.maximum: popup.parent.width  - popup.width

            // Enable and clamp vertical movement
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

    ColumnLayout {
        id: popupContent
        spacing: 12
        anchors {
            top: header.bottom;
            left: parent.left;
            right: parent.right;
            topMargin: 0
            bottomMargin: 12
            leftMargin: 12
            rightMargin: 12
        }

        ColumnLayout {
            width: parent.width - 24
            spacing: 6

            ColumnLayout {
                width: parent.width
                spacing: 2

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

            ColumnLayout {
                width: parent.width
                spacing: 2

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

            ColumnLayout {
                width: parent.width
                spacing: 2

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

            ColumnLayout {
                width: parent.width
                spacing: 2

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

            ColumnLayout {
                width: parent.width
                spacing: 2

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

            // Coordinate fields
            RowLayout {
                width: parent.width
                spacing: 6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: "Latitude"
                        color: "#ffffff"
                    }

                    TextField {
                        id: latitudeField
                        placeholderText: "0.000000"
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
                        onEditingFinished: {
                            checkCoordinatesValidity()
                            var lat = parseFloat(latitudeField.text)
                            var lng = parseFloat(longitudeField.text)
                            if (!isNaN(lat) && !isNaN(lng)) {
                                popup.coordinatesChanged(lat, lng)
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: "Longitude"
                        color: "#ffffff"
                    }

                    TextField {
                        id: longitudeField
                        placeholderText: "0.000000"
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
                        onEditingFinished: {
                            checkCoordinatesValidity()
                            var lat = parseFloat(latitudeField.text)
                            var lng = parseFloat(longitudeField.text)
                            if (!isNaN(lat) && !isNaN(lng)) {
                                popup.coordinatesChanged(lat, lng)
                            }
                        }
                    }
                }
            }

            // Status message
            Label {
                visible: !!latitudeField.text || !!longitudeField.text
                text: {
                    if (coordinatesAreValid) {
                        return "✓ Valid coordinates"
                    } else {
                        return "⚠ Invalid coordinates (Lat: -90 to 90, Lon: -180 to 180)"
                    }
                }
                color: coordinatesAreValid ? "#22c55e" : "#ef4444"
                font.pixelSize: 12
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                width: parent.width
                spacing: 2
                Layout.preferredHeight: 80

                Label {
                    text: "Note"
                    color: "#ffffff"
                }

                ScrollView {
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    TextArea {
                        id: noteField
                        placeholderText: "Enter a note..."
                        font.pixelSize: 14
                        color: "#ffffff"
                        padding: 0
                        topPadding: 4
                        bottomPadding: 4

                        background: Rectangle {
                            height: parent.height
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                    }
                }
            }
        }

        RowLayout {
            id: footer
            spacing: 6
            Layout.alignment: Qt.AlignRight

            StyledButton {
                text: "Cancel"
                font.pixelSize: 14
                onClicked: {
                    popup.clearForm()
                    popup.close()
                }
            }

            StyledButton {
                id: saveBtn
                text: "Save"
                font.pixelSize: 14
                // UPDATED CONDITION: must have label AND valid coordinates
                enabled: !!labelField.text && coordinatesAreValid
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
                        latitude: parseFloat(latitudeField.text),
                        longitude: parseFloat(longitudeField.text)
                    })

                    popup.clearForm()
                    popup.close()
                }
            }
        }
    }
}
