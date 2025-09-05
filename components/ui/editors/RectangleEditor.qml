import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.interactionmanager 1.0

BaseEditor {
    objectName: "RectangleEditor"

    id: editor

    property bool dragging: false
    property point dragStart: Qt.point(0,0)
    property point dragEnd  : Qt.point(0,0)
    property var topLeft: QtPositioning.coordinate(0, 0)
    property var bottomRight: QtPositioning.coordinate(0, 0)

    signal rectangleCreated(var rectangle)

    function resetPreview() {
        topLeft = QtPositioning.coordinate(0, 0)
        bottomRight = QtPositioning.coordinate(0, 0)
    }

    width: parent.width
    height: parent.height
    z: 1000

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true

        onPressed: function (mouse) {
            dragging = true
            dragStart = Qt.point(mouse.x, mouse.y)
            dragEnd = dragStart
        }

        onPositionChanged: function (mouse) {
            if (dragging) dragEnd = Qt.point(mouse.x, mouse.y)
        }

        onReleased: {
            dragging = false
            topLeft = map.toCoordinate(Qt.point(Math.min(dragStart.x, dragEnd.x), Math.min(dragStart.y, dragEnd.y)))
            bottomRight = map.toCoordinate(Qt.point(Math.max(dragStart.x, dragEnd.x), Math.max(dragStart.y, dragEnd.y)))

            if (topLeft === bottomRight) return

            rectangleCreated({
                topLeft,
                bottomRight,
            })
        }
    }

    Rectangle {
        visible: dragging
        x: Math.min(dragStart.x, dragEnd.x)
        y: Math.min(dragStart.y, dragEnd.y)
        width : Math.abs(dragEnd.x - dragStart.x)
        height: Math.abs(dragEnd.y - dragStart.y)
        color: "#4488cc88"
        border.color: "red"
        border.width: 2
        z: 1100
    }

    MapRectangle {
        color: "#4488cc88"
        border.color: "blue"
        border.width: 2
        topLeft: editor.topLeft
        bottomRight: editor.bottomRight
    }
}
