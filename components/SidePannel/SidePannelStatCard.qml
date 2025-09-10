import QtQuick 6.8

Row {
    id: root
    spacing: 10
    property string icon: ""
    property string title: ""
    property string value: ""

    Rectangle {
        width: 50
        height: 50
        radius: 8
        color: Qt.rgba(1, 1, 1, 0.1)
        border.color: "#444"
        border.width: 1

        Text {
            text: root.icon
            font.pixelSize: 24
            anchors.centerIn: parent
            color: "white"
        }
    }

    Column {
        spacing: 2
        width: root.width - 60

        Text {
            text: root.title
            font.pixelSize: 14
            color: "#aaaaaa"
            font.weight: Font.Medium
        }

        Text {
            text: root.value
            font.pixelSize: 18
            font.bold: true
            color: "white"
        }
    }
}
