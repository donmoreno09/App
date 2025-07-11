import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import raise.singleton.layermanager 1.0

Item {
    id: layersList
    width: parent.width
    height: parent.height
    clip: true

    property var layers: LayerManager.layerList

    ColumnLayout {
        id: layerColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Layers Selector"
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
                        color: "#ffcccb"
                        border.color: "#999"
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter
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

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: {
        console.log("✅ LayersList loaded. layerList:", layers)
    }

    Connections {
        target: LayerManager
        function onLayerListChanged() {
            console.log("🔁 layerList updated. New value:", LayerManager.layerList)
            layers = LayerManager.layerList
        }
    }
}
