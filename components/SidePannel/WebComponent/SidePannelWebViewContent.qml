import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 30

        Text {
            text: "Ship Stowage"
            font.pixelSize: 20
            font.bold: true
            font.family: "Arial"
            color: "white"
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: buttonBackground
            width: 280
            height: 40
            radius: 8
            color: "#1565C0"
            border.color: "#404040"
            border.width: 1
            Layout.alignment: Qt.AlignHCenter

            layer.enabled: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    let component = Qt.createComponent("WebPageContainer.qml")
                    if (component.status === Component.Ready) {
                        let webView = component.createObject(root, {})
                        if (webView === null) {
                            console.error("Error creating WebView")
                        }
                    } else {
                        console.error("Error loading component:", component.errorString())
                    }
                }
                onEntered: buttonBackground.color = "#0D47A1"
                onExited: buttonBackground.color = "#1565C0"
            }

            Text {
                text: "Stowage - FourClicks"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
