import QtQuick 6.8

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 8
    property string icon: ""
    property bool active: false
    signal clicked()

    color: active ? "white" : "#f0f0f0"
    border.color: active ? "#aaaaaa" : "#dddddd"
    border.width: 1

    Text {
        text: root.icon
        font.pixelSize: 20
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
