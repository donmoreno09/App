import QtQuick 6.8

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 8
    property string icon: ""
    property bool active: false
    signal clicked()

    color: active ? "#404040" : "transparent"
    border.color: active ? "#666666" : "#444444"
    border.width: 1

    Text {
        text: root.icon
        font.pixelSize: 20
        anchors.centerIn: parent
        color: active ? "#FFFFFF" : "#CCCCCC"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        hoverEnabled: true
        onEntered: {
            if (!root.active) {
                parent.color = "#2a2a2a"
                parent.border.color = "#666666"
            }
        }
        onExited: {
            if (!root.active) {
                parent.color = "transparent"
                parent.border.color = "#444444"
            }
        }
    }
}
