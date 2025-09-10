import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8
import Qt5Compat.GraphicalEffects

import raise.singleton.layermanager 1.0

Item {
    id: layersList
    width: parent.width
    height: parent.height
    clip: true

    property var layers: LayerManager.layerList
    property var selectedObjects: LayerManager.selectedObjects

    signal requestSidepanelOpen

    // Automatic retranslation properties
    property string layersSelectorText: qsTr("Layers Selector")

    // Auto-retranslate when language changes
    function retranslateUi() {
        layersSelectorText = qsTr("Layers Selector")
    }

    ColumnLayout {
        id: layerColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // LAYERS SELECTOR SECTION
        Text {
            text: layersList.layersSelectorText
            font.pixelSize: 20
            font.bold: true
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            height: 1
            color: "#444"
            Layout.fillWidth: true
        }

        // Layers List
        Repeater {
            model: layers

            delegate: Rectangle {
                width: parent.width
                height: 60
                radius: 10
                color: "#101e2c"
                border.color: "#2d3b50"
                border.width: 1
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: "#3a506b"
                        border.color: "#999"
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter

                        // Contenuto dinamico in base al nome del layer
                        Item {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height

                            // Emoji per navi
                            Text {
                                visible: modelData.layerName === "Doc Space Tracks"
                                         || modelData.layerName === "AIS Tracks"
                                            || modelData.layerName === "Tracce Doc Space"
                                            || modelData.layerName === "Tracce AIS"
                                text: "🚢"
                                font.pixelSize: 20
                                anchors.centerIn: parent
                            }

                            // SVG Shapes icon
                            Image {
                                id: geometricalShapeIcon
                                visible: modelData.layerName === "Geometrical Shapes" || modelData.layerName === "Forme Geometriche"
                                source: "qrc:/components/ui/assets/shapes.svg"
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                            }

                            // SVG POI icon
                            Image {
                                id: poiIcon
                                visible: modelData.layerName === "Points of Interest" || modelData.layerName === "Punti di Interesse"
                                source: "qrc:/components/ui/assets/poi-area.svg"
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                fillMode: Image.PreserveAspectFit
                            }

                            ColorOverlay {
                                anchors.fill: geometricalShapeIcon
                                visible: modelData.layerName === "Geometrical Shapes" || modelData.layerName === "Forme Geometriche"
                                source: geometricalShapeIcon
                                color: "white"
                            }

                            ColorOverlay {
                                anchors.fill: poiIcon
                                visible: modelData.layerName === "Points of Interest" || modelData.layerName === "Punti di Interesse"
                                source: poiIcon
                                color: "white"
                            }
                        }
                    }

                    Button {
                        text: modelData.layerName
                        Layout.fillWidth: true
                        height: 36

                        background: Rectangle {
                            color: modelData.onFocus ? "#2e4e70" : "#1c2a38"
                            radius: 6
                            border.color: "#3a506b"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: modelData.layerName
                            color: "white"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            anchors.fill: parent
                        }

                        onClicked: {
                            console.log("Layer selected:", modelData.layerName)
                            modelData.onFocus = !modelData.onFocus
                            LayerManager.setFocusLayer(modelData.layerName)
                        }
                    }

                    ToolButton {
                        width: 36
                        height: 36
                        onClicked: modelData.isVisible = !modelData.isVisible

                        background: Rectangle {
                            color: modelData.isVisible ? "#2e4e70" : "#1c2a38"
                            radius: 6
                        }

                        contentItem: Image {
                            source: modelData.isVisible ? "assets/eye.svg" : "assets/eye-off.svg"
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Switch {
                        checked: modelData.isEnabled
                        onToggled: modelData.isEnabled = checked
                        palette.highlight: "#2e4e70"
                        palette.base: "#333"
                    }
                }
            }
        }

        MapObjectDetailsPanel {
            id: mapObjectDetailsPanel
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        console.log("✅ LayersList loaded. layerList:", layers)
    }

    Connections {
        target: LayerManager
        function onLayerListChanged() {
            console.log("🔁 layerList updated. New value:",
                        LayerManager.layerList)
            layers = LayerManager.layerList
        }
    }

    Connections {
        target: LayerManager
        function onSelectedObjectsChanged() {
            console.log("🔁 Oggetti selezionati aggiornati:\n" + JSON.stringify(
                            LayerManager.selectedObjects, null, 2))
            selectedObjects = LayerManager.selectedObjects

            // Auto-expand when objects are selected and request sidepanel open
            if (selectedObjects && selectedObjects.length > 0) {
                requestSidepanelOpen()
            }
        }
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            layersList.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
