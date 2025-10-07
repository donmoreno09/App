import QtQuick 6.8
import QtQuick.Shapes 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.interactionmanager 1.0

BaseEditor {
    objectName: "EllipseEditor"
    id: editor

    property bool dragging: false
    property point dragStart: Qt.point(0,0)
    property point dragEnd: Qt.point(0,0)

    property var center: QtPositioning.coordinate(0,0)
    property real radiusLat: 0
    property real radiusLon: 0
    property real previewRadiusX: 0
    property real previewRadiusY: 0

    signal ellipseCreated(var ellipse)

    function calculatePreviewRadii() {
        const previewPoint = map.fromCoordinate(QtPositioning.coordinate(center.latitude + radiusLat, center.longitude + radiusLon), false)
        const centerPoint = map.fromCoordinate(center, false)
        previewRadiusX = Math.abs(previewPoint.x - centerPoint.x)
        previewRadiusY = Math.abs(previewPoint.y - centerPoint.y)
    }

    Connections {
        target: map

        function onZoomLevelChanged() {
            calculatePreviewRadii()
        }
    }

    function resetPreview() {
        center     = QtPositioning.coordinate(0,0)
        radiusLat  = 0
        radiusLon  = 0
        previewRadiusX = 0
        previewRadiusY = 0
    }

    width: parent.width; height: parent.height; z: 1000

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true

        onPressed: function (mouse) {
            dragging  = true
            dragStart = Qt.point(mouse.x, mouse.y)
            dragEnd   = dragStart
        }

        onPositionChanged: function (mouse) {
            if (dragging) dragEnd = Qt.point(mouse.x, mouse.y)
        }

        onReleased: {
            dragging = false

            const tl = map.toCoordinate(Qt.point(
                Math.min(dragStart.x, dragEnd.x),
                Math.min(dragStart.y, dragEnd.y)
            ))
            const br = map.toCoordinate(Qt.point(
                Math.max(dragStart.x, dragEnd.x),
                Math.max(dragStart.y, dragEnd.y)
            ))

            if (tl === br) return

            center = QtPositioning.coordinate(
                (tl.latitude  + br.latitude ) / 2,
                (tl.longitude + br.longitude) / 2
            )
            radiusLat = Math.abs(br.latitude  - tl.latitude ) / 2
            radiusLon = Math.abs(br.longitude - tl.longitude) / 2
            calculatePreviewRadii()

            ellipseCreated({
                center,
                radiusLat,
                radiusLon
            })
        }
    }

    Shape {
        visible: dragging
        z: 1100

        ShapePath {
            strokeWidth: 2
            strokeColor: "red"
            fillColor: "#4488cc88"

            startX: Math.max(dragStart.x, dragEnd.x)
            startY: Math.min(dragStart.y, dragEnd.y) + Math.abs(dragEnd.y - dragStart.y) / 2

            PathArc {
                x: Math.min(dragStart.x, dragEnd.x)
                y: Math.min(dragStart.y, dragEnd.y) + Math.abs(dragEnd.y - dragStart.y) / 2
                radiusX: Math.abs(dragEnd.x - dragStart.x) / 2
                radiusY: Math.abs(dragEnd.y - dragStart.y) / 2
            }

            PathArc {
                x: Math.max(dragStart.x, dragEnd.x)
                y: Math.min(dragStart.y, dragEnd.y) + Math.abs(dragEnd.y - dragStart.y) / 2
                radiusX: Math.abs(dragEnd.x - dragStart.x) / 2
                radiusY: Math.abs(dragEnd.y - dragStart.y) / 2
            }
        }
    }

    MapQuickItem {
        coordinate: center
        anchorPoint.x: previewRadiusX
        anchorPoint.y: previewRadiusY
        z: 1100

        sourceItem: Shape {
            ShapePath {
                strokeWidth: 2
                strokeColor: "blue"
                fillColor: "#4488cc88"

                startX: previewRadiusX * 2
                startY: previewRadiusY

                PathArc {
                    x: 0
                    y: previewRadiusY
                    radiusX: previewRadiusX
                    radiusY: previewRadiusY
                }
                PathArc {
                    x: previewRadiusX * 2
                    y: previewRadiusY
                    radiusX: previewRadiusX
                    radiusY: previewRadiusY
                }
            }
        }
    }
}
