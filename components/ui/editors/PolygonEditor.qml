import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.interactionmanager 1.0

BaseEditor {
    objectName: "PolygonEditor"

    id: editor

    property int draggingHandleIndex: -1

    signal polygonCreated(var polygon)

    function resetPreview() {
        previewPoly.path = []
    }

    anchors.fill: parent
    z: 1000

    ListModel { id: pointModel }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true

        onClicked: function (mouse) {
            if (draggingHandleIndex !== -1) {
                return
            }

            const coord = map.toCoordinate(Qt.point(mouse.x, mouse.y))
            pointModel.append(coord)
            mouse.accepted = false
        }
    }

    MapPolyline {
        id: previewLine
        line.width: 2
        line.color: "red"
        path: {
            const path = []
            for (let i = 0; i < pointModel.count; i++) {
                path.push(pointModel.get(i))
            }
            return path
        }
        visible: pointModel.count > 0
    }

    MapPolygon {
        id: previewPoly
        visible: false
        color: "#4488cc88"
        border.color: "blue"
        border.width: 2
    }

    MapItemView {
        model: pointModel
        delegate: MapQuickItem {
            id: marker
            coordinate: QtPositioning.coordinate(latitude, longitude)
            anchorPoint.x: 6
            anchorPoint.y: 6
            z: 100

            DragHandler {
                onGrabChanged: {
                    if (index === 0 && pointModel.count >= 3) {
                        const path = []
                        for (let i = pointModel.count - 1; i >= 0; i--) {
                            const coord = pointModel.get(i)
                            path.unshift(QtPositioning.coordinate(coord.latitude, coord.longitude))

                            // removing points manually since pointModel.clear() DOES NOT
                            // trigger a rerender, even with pointModel.sync()
                            pointModel.remove(i)
                        }

                        // close path
                        const coord = path[0]
                        path.push(QtPositioning.coordinate(coord.latitude, coord.longitude))

                        previewPoly.path = path
                        previewPoly.visible = true

                        polygonCreated({ path })
                    }
                }

                onActiveChanged: {
                    draggingHandleIndex = active ? index : -1
                }

                onTranslationChanged: {
                    const point = Qt.point(marker.x + anchorPoint.x, marker.y + anchorPoint.y)
                    const coord = map.toCoordinate(point)
                    previewLine.path[index] = coord
                    pointModel.set(index, coord)
                }
            }

            sourceItem: Rectangle {
                width: 12
                height: 12
                radius: 6
                color: "skyblue"
                border.color: "white"
                border.width: 1
                opacity: 0.9
            }
        }
    }
}
