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

    // Automatic retranslation properties
    property string modeText: qsTr("Mode")
    property string handText: qsTr("Hand")
    property string cursorText: qsTr("Cursor")
    property string drawText: qsTr("Draw")
    property string squareText: qsTr("Square")
    property string ellipseText: qsTr("Ellipse")
    property string polygonText: qsTr("Polygon")
    property string corridorText: qsTr("Corridor")
    property string focusLayerText: qsTr("Focus Layer")
    property string annotationText: qsTr("Annotation")
    property string trackText: qsTr("Track")
    property string poisText: qsTr("PoIs")
    property string visibilityText: qsTr("Visibility")
    property string tracksText: qsTr("Tracks")

    // Auto-retranslate when language changes
    function retranslateUi() {
        modeText = qsTr("Mode")
        handText = qsTr("Hand")
        cursorText = qsTr("Cursor")
        drawText = qsTr("Draw")
        squareText = qsTr("Square")
        ellipseText = qsTr("Ellipse")
        polygonText = qsTr("Polygon")
        corridorText = qsTr("Corridor")
        focusLayerText = qsTr("Focus Layer")
        annotationText = qsTr("Annotation")
        trackText = qsTr("Track")
        poisText = qsTr("PoIs")
        visibilityText = qsTr("Visibility")
        tracksText = qsTr("Tracks")
    }

    ColumnLayout {
        spacing: 16

        // Mode section
        ColumnLayout {
            spacing: 8
            Label {
                text: toolbar.modeText
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: toolbar.handText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#005288"; radius: 6 }
                onClicked: InteractionModeManager.currentMode = InteractionModeManager.Hand

            }

            Button {
                text: toolbar.cursorText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#005288"; radius: 6 }
                onClicked: InteractionModeManager.currentMode = InteractionModeManager.Cursor
            }
            Button {
                id: drawButton
                text: toolbar.drawText
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
                        text: toolbar.squareText
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Square"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: toolbar.ellipseText
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Ellipse"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: toolbar.polygonText
                        Layout.fillWidth: true
                        onClicked: {
                            InteractionModeManager.currentDrawShape = "Polygon"
                            drawMenu.close()
                        }
                    }

                    Button {
                        text: toolbar.corridorText
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
                text: toolbar.focusLayerText
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: toolbar.annotationText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#003366"; radius: 6 }
                onClicked: LayerManager.setFocusLayer("AnnotationMapLayer")
            }

            Button {
                text: toolbar.trackText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#003366"; radius: 6 }
                onClicked: LayerManager.setFocusLayer("TrackMapLayer")
            }

            Button {
                text: toolbar.poisText
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
                text: toolbar.visibilityText
                font.bold: true
                font.pointSize: 11
                color: "#333"
            }

            Button {
                text: toolbar.annotationText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: annotationLayer.isVisible = !annotationLayer.isVisible
            }

            Button {
                text: toolbar.tracksText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: trackLayer.isVisible = !trackLayer.isVisible
            }

            Button {
                text: toolbar.poisText
                Layout.fillWidth: true
                font.pixelSize: 14
                padding: 8
                background: Rectangle { color: "#0074a6"; radius: 6 }
                onClicked: poiLayer.isVisible = !poiLayer.isVisible
            }
        }
    }

    // Layer references passed from outside
    property var annotationLayer
    property var trackLayer
    property var poiLayer

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            toolbar.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
