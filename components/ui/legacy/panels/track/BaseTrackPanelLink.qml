import QtQuick
import QtQuick.Shapes

Shape {

    id: baseTrackPanelLink
    property point panelAnchor: Qt.point(0, 0)
    property point markerAnchor: Qt.point(0, 0)
    property color color

    z: -1
    antialiasing: true
    opacity: 0.7

    onPanelAnchorChanged: {

    }

    onMarkerAnchorChanged: {

    }

    ShapePath {
        id: markerAnchorPoint
        strokeColor: baseTrackPanelLink.color
        strokeWidth: 1

        startX: baseTrackPanelLink.markerAnchor.x
        startY: baseTrackPanelLink.markerAnchor.y

        PathLine {
            x: baseTrackPanelLink.panelAnchor.x
            y: baseTrackPanelLink.panelAnchor.y
        }
    }
}
