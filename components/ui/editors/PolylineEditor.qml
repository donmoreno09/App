import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.interactionmanager 1.0

BaseEditor {
    objectName: "PolylineEditor"

    property int draggingHandleIndex: -1

    signal polylineCreated(var polyline)

    function resetPreview() {
        previewLine.visible = false
        previewLine.path = []
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
        id: previewDrawingLine
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

    MapPolyline {
        id: previewLine
        visible: false
        line.width: 2
        line.color: "blue"
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
                onActiveChanged: {
                    draggingHandleIndex = active ? index : -1
                }

                onTranslationChanged: {
                    const point = Qt.point(marker.x + anchorPoint.x, marker.y + anchorPoint.y)
                    const coord = map.toCoordinate(point)
                    previewDrawingLine.path[index] = coord
                    pointModel.set(index, coord)
                }
            }

            TapHandler {
                onTapped: {
                    // if tapped last point, commit polyline
                    const lastPoint = pointModel.get(pointModel.count - 1)
                    if (lastPoint === pointModel.get(index)) {
                        const path = []
                        for (let i = pointModel.count - 1; i >= 0; i--) {
                            const coord = pointModel.get(i)
                            path.unshift(QtPositioning.coordinate(coord.latitude, coord.longitude))

                            // removing points manually since pointModel.clear() DOES NOT
                            // trigger a rerender, even with pointModel.sync()
                            pointModel.remove(i)
                        }

                        previewLine.path = path
                        previewLine.visible = true

                        polylineCreated({ path })
                    }
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
