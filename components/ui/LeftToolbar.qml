import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import raise.singleton.interactionmanager 1.0
import raise.singleton.layermanager 1.0

Frame {
    id: toolbar
    width: 120
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.leftMargin: 16
    anchors.topMargin: 16
    padding: 12
    background: Rectangle {
        color: "#f9f9f9"
        radius: 12
        border.color: "#bbbbbb"
        border.width: 1
    }

    ColumnLayout {
        spacing: 16

        // Modalità
        ColumnLayout {
            spacing: 8
            Label {
                text: "Modalità"
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: "Mano"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#005288"; radius: 6 }
                onClicked: InteractionModeManager.currentMode = InteractionModeManager.Hand

            }

            Button {
                text: "Cursore"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#005288"; radius: 6 }
                onClicked: InteractionModeManager.currentMode = InteractionModeManager.Cursor
            }
            Button {
                id: drawButton
                text: "Disegna"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#005288"; radius: 6 }

                onClicked: drawMenu.open()
            }

            Popup {
                id: drawMenu
                x: drawButton.width + 20
                y: drawButton.y
                width: 140
                modal: false
                focus: true
                opacity: 0.0
                scale: 0.9
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                enter: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 180; easing.type: Easing.OutBack }
                }

                exit: Transition {
                    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.InCubic }
                    NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 120; easing.type: Easing.InBack }
                }

                background: Rectangle {
                    color: "#ffffff"
                    border.color: "#aaaaaa"
                    border.width: 1
                    radius: 6
                    opacity: 1.0
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Button {
                        text: "Quadrato"
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Square"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: "Ellisse"
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Ellipse"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: "Poligono"
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Polygon"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: "Corridoio"
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Corridor"
                            drawMenu.close()
                        }
                    }
                }
            }

        }

        // Focus layer
        ColumnLayout {
            spacing: 16
            Label {
                text: "Focus Layer"
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: "Annotation"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#003366"; radius: 6 }
                onClicked: LayerManager.setFocusLayer("AnnotationMapLayer")
            }

            Button {
                text: "Track"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#003366"; radius: 6 }
                onClicked: LayerManager.setFocusLayer("TrackMapLayer")
            }

            Button {
                text: "PoIs"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#003366"; radius: 6 }
                onClicked: LayerManager.setFocusLayer("StaticPoiMapLayer")
            }
        }

        // Visibilità
        ColumnLayout {
            spacing: 16
            Label {
                text: "Visibilità"
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: "Annotation"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: annotationLayer.isVisible = !annotationLayer.isVisible
            }

            Button {
                text: "Tracks"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: trackLayer.isVisible = !trackLayer.isVisible
            }

            Button {
                text: "PoIs"
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: poiLayer.isVisible = !poiLayer.isVisible
            }
        }
    }

    // Layer references passate dall’esterno
    property var annotationLayer
    property var trackLayer
    property var poiLayer
}
