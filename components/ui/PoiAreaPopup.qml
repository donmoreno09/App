import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8
import raise.singleton.popupmanager 1.0

Rectangle {
    id: areaPopup

    width: 340
    height: implicitHeight
    radius: 6
    border.color: "#dddddd"
    border.width: 2
    color: "white"

    property alias labelField: labelField
    property alias noteField: noteField

    signal opened()
    signal closed()
    signal saveClicked(var details)
    signal rectangleChanged(real topLat, real topLon, real bottomLat, real bottomLon)

    function open() {
        areaPopup.visible = true
        areaPopup.opened()
    }

    function close() {
        areaPopup.visible = false
        areaPopup.closed()
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

    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: PopupManager.bringToFront(areaPopup)
    }

    ColumnLayout {
        id: layout
        spacing: 12
        anchors.margins: 12
        anchors.fill: parent

        Text {
            text: "Insert Manual Area POI"
            font.bold: true
            font.pointSize: 14
            color: "black"
        }

        TextField {
            id: labelField
            placeholderText: "Label"
            Layout.fillWidth: true
        }

        GridLayout {
            columns: 2
            columnSpacing: 6
            rowSpacing: 4
            Layout.fillWidth: true

            Label { text: "Top Left Lat" }
            TextField {
                id: topLeftLat
                validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Top Left Lon" }
            TextField {
                id: topLeftLon
                validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Bottom Right Lat" }
            TextField {
                id: bottomRightLat
                validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
                onEditingFinished: validateRectangle()
            }

            Label { text: "Bottom Right Lon" }
            TextField {
                id: bottomRightLon
                validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
                onEditingFinished: validateRectangle()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            TextArea {
                id: noteField
                placeholderText: "Note"
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            Button {
                text: "Cancel"
                onClicked: {
                    areaPopup.clearForm()
                    areaPopup.close()
                }
            }

            Button {
                text: "Save"
                enabled: labelField.text && topLeftLat.text && topLeftLon.text && bottomRightLat.text && bottomRightLon.text
                onClicked: {
                    saveClicked({
                        id: null,
                        label: labelField.text,
                        note: noteField.text,
                        topLeft: QtPositioning.coordinate(parseFloat(topLeftLat.text), parseFloat(topLeftLon.text)),
                        bottomRight: QtPositioning.coordinate(parseFloat(bottomRightLat.text), parseFloat(bottomRightLon.text))
                    })
                    areaPopup.clearForm()
                    areaPopup.close()
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

    Component.onCompleted: PopupManager.bringToFront(areaPopup)
}
