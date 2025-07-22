import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

import "../../models/shapes.js" as ShapeModel
import "../../"

BaseShape {
    id: root

    property bool isChangingHandle: false

    ListModel { id: pointModel }

    function updatePreviewPath(newPath) {
        pointModel.clear()

        for (let i = 0; i < newPath.length; i++) {
            pointModel.append(newPath[i])
        }
    }

    Component.onCompleted: {
        Qt.callLater(function () {
            updatePreviewPath(ShapeModel.toQtCoordinates(modelData.geometry.coordinates, QtPositioning))
        })
    }

    MapPolyline {
        id: mapPolyline

        line.width: 2
        line.color: root.color
        path: ShapeModel.toQtCoordinates(modelData.geometry.coordinates, QtPositioning)

        ShapeTapHandler {}

        ShapeDragHandler {
            dragEnabled: !isChangingHandle
            handleTranslationChange: function () {
                const newModelData = JSON.parse(JSON.stringify(modelData))
                newModelData.geometry.coordinates = ShapeModel.toBECoordinates(mapPolyline.path)
                root.syncModelData(newModelData)

                // Update dragging points coords
                for (let i = 0; i < mapPolyline.path.length; i++) {
                    pointModel.set(i, mapPolyline.path[i])
                }
            }

            onReleased: {
                updatePreviewPath(mapPolyline.path)
                root.modified()
            }
        }
    }

    MapPolyline {
        id: highlight
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id
        path: mapPolyline.path
        line.width: mapPolyline.line.width + 2
        line.color: "white"
        z: mapPolyline.z - 1
    }

    MapPolyline {
        id: previewPoly
        visible: isChangingHandle
        line.width: mapPolyline.line.width
        line.color: "blue"
        z: mapPolyline.z - 2
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
        z: mapPolyline.z + 1

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
                    isChangingHandle = active

                    if (!isChangingHandle) {
                        const path = []
                        for (let ip = 0; ip < pointModel.count; ip++) {
                            path.push(pointModel.get(ip))
                        }

                        mapPolyline.path = path

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
        anchors.centerIn: mapPolyline
        text: modelData.label
        font.pixelSize: 12
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }
}
