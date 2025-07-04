import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtPositioning 6.8

import raise.singleton.popupmanager 1.0

// I'm not using a Popup component since it cannot be
// targeted by DragHandler and I need to style its borders
// TODO: Extract these popups in a base popup component for reusability (as is the case with PoiPopup)
Rectangle {
    id: popup

    property var title
    property alias labelField: labelField

    signal opened()
    signal closed()
    signal saveClicked(var details)

    width: 300
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
            color: "black"
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
                enabled: !!labelField.text
                onClicked: {
                    const intId = annotationLayerInstance.businessLogic.annotationModel.rowCount()

                    saveClicked({
                        id: `SHAPE-${intId}`,
                        label: labelField.text,
                    })

                    popup.clearForm()
                    popup.close()
                }
            }
        }
    }
}
