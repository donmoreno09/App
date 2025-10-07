import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

BaseEditor {
    objectName: "PointEditor"

    id: editor

    signal pointCreated(var point)

    function resetPreview() {
        pointMarker.coordinate = QtPositioning.coordinate(0, 0)
        pointMarker.visible = false
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onClicked: function (mouse) {
            const coordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))

            pointMarker.coordinate = coordinate
            pointMarker.visible = true

            pointCreated({ coordinate })
        }
    }

    MapQuickItem {
        id: pointMarker
        visible: false
        coordinate: QtPositioning.coordinate(0, 0)
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2
        sourceItem: Rectangle {
            width: 12
            height: 12
            color: "white"
            radius: width / 2
            border.color: "red"
            border.width: 2
        }
    }
}
