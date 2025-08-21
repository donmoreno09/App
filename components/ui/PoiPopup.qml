import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0
import "../ui/top-toolbar/utils.js" as ToolbarUtils

Rectangle {
    id: popup

    property string title: popup.popupTitle
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
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
    color: "#f21f3154"
    border.color: "#333333"
    border.width: 1

    property bool coordinatesAreValid: false

    // Automatic retranslation properties
    property string popupTitle: qsTr("POI Details")
    property string labelText: qsTr("Label")
    property string labelPlaceholder: qsTr("Enter label...")
    property string categoryText: qsTr("Category")
    property string typeText: qsTr("Type")
    property string healthStatusText: qsTr("Health Status")
    property string operationalStateText: qsTr("Operational State")
    property string latitudeText: qsTr("Latitude")
    property string longitudeText: qsTr("Longitude")
    property string validCoordsText: qsTr("✓ Valid coordinates")
    property string invalidCoordsText: qsTr("⚠ Invalid coordinates (Lat: -90 to 90, Lon: -180 to 180)")
    property string noteText: qsTr("Note")
    property string notePlaceholder: qsTr("Enter a note...")
    property string cancelText: qsTr("Cancel")
    property string saveText: qsTr("Save")

    // Auto-retranslate when language changes
    function retranslateUi() {
        popupTitle = qsTr("POI Details")
        labelText = qsTr("Label")
        labelPlaceholder = qsTr("Enter label...")
        categoryText = qsTr("Category")
        typeText = qsTr("Type")
        healthStatusText = qsTr("Health Status")
        operationalStateText = qsTr("Operational State")
        latitudeText = qsTr("Latitude")
        longitudeText = qsTr("Longitude")
        validCoordsText = qsTr("✓ Valid coordinates")
        invalidCoordsText = qsTr("⚠ Invalid coordinates (Lat: -90 to 90, Lon: -180 to 180)")
        noteText = qsTr("Note")
        notePlaceholder = qsTr("Enter a note...")
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
        latitudeField.text = ""
        longitudeField.text = ""
        coordinatesAreValid = false
    }

    function setCoordinates(latitude, longitude) {
        latitudeField.text = latitude.toFixed(6)
        longitudeField.text = longitude.toFixed(6)
        checkCoordinatesValidity()
    }

    function checkCoordinatesValidity() {
        var lat = parseFloat(latitudeField.text)
        var lon = parseFloat(longitudeField.text)

        var numbersValid = !isNaN(lat) && !isNaN(lon)
        var rangesValid = numbersValid &&
                         lat >= -90 && lat <= 90 &&
                         lon >= -180 && lon <= 180

        coordinatesAreValid = rangesValid
        return coordinatesAreValid
    }

    Component.onCompleted: bringToFront()
    Component.onDestruction: PopupManager.unregister(popup)

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            popup.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }

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
            xAxis.enabled: true
            xAxis.minimum: 0
            xAxis.maximum: popup.parent.width  - popup.width
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
                    text: popup.labelText
                    color: "#ffffff"
                }

                TextField {
                    id: labelField
                    placeholderText: popup.labelPlaceholder
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
                width: parent.width
                spacing: 2

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
                width: parent.width
                spacing: 2

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
                width: parent.width
                spacing: 2

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
                width: parent.width
                spacing: 2

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

            RowLayout {
                width: parent.width
                spacing: 6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: popup.latitudeText
                        color: "#ffffff"
                    }

                    TextField {
                        id: latitudeField
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
                        text: popup.longitudeText
                        color: "#ffffff"
                    }

                    TextField {
                        id: longitudeField
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

            Label {
                visible: !!latitudeField.text || !!longitudeField.text
                text: {
                    if (coordinatesAreValid) {
                        return popup.validCoordsText
                    } else {
                        return popup.invalidCoordsText
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
                    text: popup.noteText
                    color: "#ffffff"
                }

                ScrollView {
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    TextArea {
                        id: noteField
                        placeholderText: popup.notePlaceholder
                        placeholderTextColor: "#888888"
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
                text: popup.cancelText
                font.pixelSize: 14
                onClicked: {
                    popup.clearForm()
                    popup.close()
                }
            }

            StyledButton {
                id: saveBtn
                text: popup.saveText
                font.pixelSize: 14
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
