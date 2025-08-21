import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0

Rectangle {
    id: popup
    property string title: popup.popupTitle
    property alias labelField: labelField
    property alias categoryComboBox: categoryComboBox
    property alias typeComboBox: typeComboBox
    property alias healthStatusComboBox: healthStatusComboBox
    property alias operationalStateComboBox: operationalStateComboBox
    property alias noteField: noteField
    property alias centerLat: centerLat
    property alias centerLon: centerLon
    property alias radiusLatField: radiusLatField
    property alias radiusLonField: radiusLonField

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal ellipseChanged(real centerLat, real centerLon, real radiusLat, real radiusLon)

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
    property string popupTitle: qsTr("Insert Ellipse POI")
    property string labelText: qsTr("Label")
    property string labelPlaceholder: qsTr("Enter label...")
    property string categoryText: qsTr("Category")
    property string typeText: qsTr("Type")
    property string healthStatusText: qsTr("Health Status")
    property string operationalStateText: qsTr("Operational State")
    property string ellipseParamsText: qsTr("Ellipse Parameters")
    property string centerLatText: qsTr("Center Latitude")
    property string centerLonText: qsTr("Center Longitude")
    property string radiusLatText: qsTr("Radius (Latitude)")
    property string radiusLonText: qsTr("Radius (Longitude)")
    property string validEllipseText: qsTr("✓ Valid ellipse parameters")
    property string invalidParamsText: qsTr("⚠ Invalid parameters")
    property string noteText: qsTr("Note")
    property string notePlaceholder: qsTr("Enter a note...")
    property string cancelText: qsTr("Cancel")
    property string saveText: qsTr("Save")

    // Auto-retranslate when language changes
    function retranslateUi() {
        popupTitle = qsTr("Insert Ellipse POI")
        labelText = qsTr("Label")
        labelPlaceholder = qsTr("Enter label...")
        categoryText = qsTr("Category")
        typeText = qsTr("Type")
        healthStatusText = qsTr("Health Status")
        operationalStateText = qsTr("Operational State")
        ellipseParamsText = qsTr("Ellipse Parameters")
        centerLatText = qsTr("Center Latitude")
        centerLonText = qsTr("Center Longitude")
        radiusLatText = qsTr("Radius (Latitude)")
        radiusLonText = qsTr("Radius (Longitude)")
        validEllipseText = qsTr("✓ Valid ellipse parameters")
        invalidParamsText = qsTr("⚠ Invalid parameters")
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
        centerLat.text = ""
        centerLon.text = ""
        radiusLatField.text = ""
        radiusLonField.text = ""
        coordinatesAreValid = false
    }

    function setEllipseCoordinates(centerLatitude, centerLongitude, radiusLat, radiusLon) {
        centerLat.text = centerLatitude.toFixed(6)
        centerLon.text = centerLongitude.toFixed(6)
        radiusLatField.text = radiusLat.toFixed(6)
        radiusLonField.text = radiusLon.toFixed(6)
        checkCoordinatesValidity()
    }

    function checkCoordinatesValidity() {
        var lat = parseFloat(centerLat.text)
        var lon = parseFloat(centerLon.text)
        var rLat = parseFloat(radiusLatField.text)
        var rLon = parseFloat(radiusLonField.text)

        var numbersValid = !isNaN(lat) && !isNaN(lon) && !isNaN(rLat) && !isNaN(rLon)
        var rangesValid = numbersValid &&
                         lat >= -90 && lat <= 90 &&
                         lon >= -180 && lon <= 180 &&
                         rLat > 0 && rLat <= 90 &&
                         rLon > 0 && rLon <= 180

        coordinatesAreValid = rangesValid
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
                    text: popup.ellipseParamsText
                    color: "#ffffff"
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 4
                    Layout.fillWidth: true

                    Label {
                        text: popup.centerLatText
                        color: "#ffffff"
                        Layout.preferredWidth: 120
                    }
                    TextField {
                        id: centerLat
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
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: popup.centerLonText
                        color: "#ffffff"
                    }
                    TextField {
                        id: centerLon
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
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: popup.radiusLatText
                        color: "#ffffff"
                    }
                    TextField {
                        id: radiusLatField
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: 0.000001
                            top: 90.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateEllipse()
                    }

                    Label {
                        text: popup.radiusLonText
                        color: "#ffffff"
                    }
                    TextField {
                        id: radiusLonField
                        placeholderText: "0.000000"
                        placeholderTextColor: "#888888"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.fillWidth: true
                        validator: DoubleValidator {
                            bottom: 0.000001
                            top: 180.0
                            decimals: 6
                        }
                        background: Rectangle {
                            radius: 6
                            color: "#2a2a2a"
                            border.color: "#444444"
                        }
                        onTextChanged: checkCoordinatesValidity()
                        onEditingFinished: validateEllipse()
                    }
                }

                Label {
                    visible: !!centerLat.text || !!centerLon.text || !!radiusLatField.text || !!radiusLonField.text
                    text: {
                        if (coordinatesAreValid) {
                            return popup.validEllipseText
                        } else {
                            return popup.invalidParamsText
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
                        placeholderText: popup.notePlaceholder
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
                            center: QtPositioning.coordinate(
                                parseFloat(centerLat.text),
                                parseFloat(centerLon.text)
                            ),
                            radiusLat: parseFloat(radiusLatField.text),
                            radiusLon: parseFloat(radiusLonField.text)
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

    function validateEllipse() {
        if (checkCoordinatesValidity()) {
            let lat = parseFloat(centerLat.text)
            let lon = parseFloat(centerLon.text)
            let rLat = parseFloat(radiusLatField.text)
            let rLon = parseFloat(radiusLonField.text)
            ellipseChanged(lat, lon, rLat, rLon)
        }
    }
}
