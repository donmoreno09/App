import QtQuick 6.8
import QtQuick.Controls 6.8

Item {
    id: zoomBar
    width: 48
    height: 110

    signal zoomInRequested()
    signal zoomOutRequested()

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#0D1117"
        border.color: "#2E2E2E"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 6

            // Bottone "+"
            Button {
                width: 36
                height: 36
                padding: 0

                background: Rectangle {
                    anchors.fill: parent
                    color: "#21262D"
                    radius: 8
                    border.color: "#30363D"
                    border.width: 1
                }

                contentItem: Item {
                    anchors.fill: parent
                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                onClicked: zoomBar.zoomInRequested()
            }

            // Bottone "-"
            Button {
                width: 36
                height: 36
                padding: 0

                background: Rectangle {
                    anchors.fill: parent
                    color: "#21262D"
                    radius: 8
                    border.color: "#30363D"
                    border.width: 1
                }

                contentItem: Item {
                    anchors.fill: parent
                    Text {
                        text: "−"
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                onClicked: zoomBar.zoomOutRequested()
            }
        }
    }
}
