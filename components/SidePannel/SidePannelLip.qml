import QtQuick 6.8
import QtQuick.Shapes 6.8
import QtQuick.Controls 6.8

Shape {
    id: root
    width: 30
    height: 60

    property alias text: handleText.text
    signal clicked()

    ShapePath {
        fillColor: "#f21f3154"
        strokeColor: "#30363D"
        strokeWidth: 1
        startX: 0; startY: 0

        PathArc {
            x: 0; y: root.height
            radiusX: root.width
            radiusY: root.width
            useLargeArc: true
            direction: PathArc.Clockwise
        }
        PathLine { x: 0; y: 0 }
    }

    Text {
        id: handleText
        text: "→"
        font.pixelSize: 20
        font.bold: true
        color: "white"
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
