import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

import "../../models/shapes.js" as ShapeModel
import "../../"

BaseShape {
    id: root

    property bool isDraggingHandle: false

    ListModel { id: pointModel }

    function updatePreviewPath(newPath) {
        pointModel.clear()

        for (let i = 0; i < newPath.length; i++) {
            // skip last point which is meant for closing the polygon
            if (i > 0 && newPath[0] === newPath[i]) {
                continue
            }

            const coord = newPath[i]
            pointModel.append(coord)
        }
    }

    Component.onCompleted: {
        Qt.callLater(function () {
            updatePreviewPath(ShapeModel.toQtCoordinates(modelData.geometry.coordinates, QtPositioning))
        })
    }

    MapPolygon {
        id: mapPolygon

        color: root.bgColor
        border.color: root.color
        border.width: 2
        path: ShapeModel.toQtCoordinates(modelData.geometry.coordinates, QtPositioning)

        ShapeTapHandler {}

        ShapeDragHandler {
            dragEnabled: !isDraggingHandle
            handleTranslationChange: function () {
                const newModelData = JSON.parse(JSON.stringify(modelData))
                newModelData.geometry.coordinates = ShapeModel.toBECoordinates(mapPolygon.path)
                root.syncModelData(newModelData)

                // Update dragging points coords
                for (let i = 0; i < mapPolygon.path.length; i++) {
                    pointModel.set(i, mapPolygon.path[i])
                }
            }

            onReleased: {
                updatePreviewPath(mapPolygon.path)
                root.modified()
            }
        }
    }

    MapPolygon {
        id: highlight
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id
        path: mapPolygon.path
        color: "transparent"
        border.color: "white"
        border.width: mapPolygon.border.width + 4
        z: mapPolygon.z - 1
    }

    MapPolygon {
        id: previewPoly
        visible: isDraggingHandle
        color: "#4488cc88"
        border.color: "blue"
        border.width: 2
        z: mapPolygon.z - 2
        path: {
            const path = []
            for (let i = 0; i < pointModel.count; i++) {
                path.push(pointModel.get(i))
            }
            return path
        }
    }

    MapItemView {
        model: pointModel
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id
        z: mapPolygon.z + 1

        delegate: MapQuickItem {
            id: handle
            coordinate: QtPositioning.coordinate(latitude, longitude)
            anchorPoint.x: width / 2
            anchorPoint.y: height / 2

            // visual circle
            sourceItem: Rectangle {
                width: 16
                height: 16
                radius: 8
                color: "white"
                border.color: root.color
                border.width: 2
                opacity: 0.8
            }

            DragHandler {
                onActiveChanged: {
                    isDraggingHandle = active

                    if (!isDraggingHandle) {
                        const path = []
                        for (let ip = 0; ip < pointModel.count; ip++) {
                            path.push(pointModel.get(ip))
                        }

                        mapPolygon.path = path
                        const coord = path[0]
                        path.push(QtPositioning.coordinate(coord.latitude, coord.longitude)) // close polygon

                        const newModelData = JSON.parse(JSON.stringify(root.getModelData()))
                        newModelData.geometry.coordinates = ShapeModel.toBECoordinates(path)
                        root.syncModelData(newModelData)

                        root.modified()
                    }
                }

                onTranslationChanged: {
                    const point = Qt.point(handle.x + anchorPoint.x, handle.y + anchorPoint.y)
                    const coord = map.toCoordinate(point)
                    previewPoly.path[index] = coord
                    pointModel.set(index, coord)
                }
            }
        }
    }

    Text {
        anchors.centerIn: mapPolygon
        text: modelData.label
        font.pixelSize: 12
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }
}
