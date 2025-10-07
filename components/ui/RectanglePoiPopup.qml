import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0

Rectangle {
    id: popup
    property string title: popup.titleText
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField
    property alias topLeftLat: topLeftLat
    property alias topLeftLon: topLeftLon
    property alias bottomRightLat: bottomRightLat
    property alias bottomRightLon: bottomRightLon

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal rectangleChanged(real topLat, real topLon, real bottomLat, real bottomLon)

    width: 340
    height: Math.min(600, 36 + popupContent.implicitHeight + 12)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    radius: 12
    color: "#f21f3154"
    border.color: "#333333"
    border.width: 1

    property bool coordinatesAreValid: false

    // Automatic retranslation properties
    property string titleText: qsTr("Insert Rectangle POI")
    property string labelText: qsTr("Label")
    property string enterLabelText: qsTr("Enter label...")
    property string categoryText: qsTr("Category")
    property string typeText: qsTr("Type")
    property string healthStatusText: qsTr("Health Status")
    property string operationalStateText: qsTr("Operational State")
    property string rectangleCoordinatesText: qsTr("Rectangle Coordinates")
    property string topLeftLatitudeText: qsTr("Top Left Latitude")
    property string topLeftLongitudeText: qsTr("Top Left Longitude")
    property string bottomRightLatitudeText: qsTr("Bottom Right Latitude")
    property string bottomRightLongitudeText: qsTr("Bottom Right Longitude")
    property string validRectangleText: qsTr("✓ Valid rectangle coordinates")
    property string invalidCoordinatesText: qsTr("⚠ Invalid coordinates")
    property string noteText: qsTr("Note")
    property string enterNoteText: qsTr("Enter a note...")
    property string cancelText: qsTr("Cancel")
    property string saveText: qsTr("Save")

    // Auto-retranslate when language changes
    function retranslateUi() {
        titleText = qsTr("Insert Rectangle POI")
        labelText = qsTr("Label")
        enterLabelText = qsTr("Enter label...")
        categoryText = qsTr("Category")
        typeText = qsTr("Type")
        healthStatusText = qsTr("Health Status")
        operationalStateText = qsTr("Operational State")
        rectangleCoordinatesText = qsTr("Rectangle Coordinates")
        topLeftLatitudeText = qsTr("Top Left Latitude")
        topLeftLongitudeText = qsTr("Top Left Longitude")
        bottomRightLatitudeText = qsTr("Bottom Right Latitude")
        bottomRightLongitudeText = qsTr("Bottom Right Longitude")
        validRectangleText = qsTr("✓ Valid rectangle coordinates")
        invalidCoordinatesText = qsTr("⚠ Invalid coordinates")
        noteText = qsTr("Note")
        enterNoteText = qsTr("Enter a note...")
        cancelText = qsTr("Cancel")
        saveText = qsTr("Save")
    }

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

    function checkCoordinatesValidity() {
        var lat1 = parseFloat(topLeftLat.text)
        var lon1 = parseFloat(topLeftLon.text)
        var lat2 = parseFloat(bottomRightLat.text)
        var lon2 = parseFloat(bottomRightLon.text)

        var numbersValid = !isNaN(lat1) && !isNaN(lon1) && !isNaN(lat2) && !isNaN(lon2)
        var rangesValid = numbersValid &&
                         lat1 >= -90 && lat1 <= 90 &&
                         lat2 >= -90 && lat2 <= 90 &&
                         lon1 >= -180 && lon1 <= 180 &&
                         lon2 >= -180 && lon2 <= 180

        var rectangleValid = rangesValid &&
                           lat1 > lat2 &&
                           lon1 < lon2

        coordinatesAreValid = rectangleValid
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
                    text: popup.rectangleCoordinatesText
                    color: "#ffffff"
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 4
                    Layout.fillWidth: true

                    Label {
                        text: popup.topLeftLatitudeText
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
                        text: popup.topLeftLongitudeText
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
                        text: popup.bottomRightLatitudeText
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
                        text: popup.bottomRightLongitudeText
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

                Label {
                    visible: !!topLeftLat.text || !!topLeftLon.text || !!bottomRightLat.text || !!bottomRightLon.text
                    text: {
                        if (coordinatesAreValid) {
                            return popup.validRectangleText
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

                        const details = {
                            id: null,
                            category: category,
                            type: type,
                            healthStatus: healthStatus,
                            operationalState: operationalState,
                            label: labelField.text,
                            note: noteField.text,
                            topLeft: QtPositioning.coordinate(
                                parseFloat(topLeftLat.text),
                                parseFloat(topLeftLon.text)
                            ),
                            bottomRight: QtPositioning.coordinate(
                                parseFloat(bottomRightLat.text),
                                parseFloat(bottomRightLon.text)
                            )
                        }

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
