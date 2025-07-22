import QtQuick 2.15
import QtQuick.Shapes 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.interactionmanager 1.0

import "../../models/shapes.js" as ShapeModel
import "../../"

BaseShape {
    id: root

    property var center: ShapeModel.toQtCoordinate(modelData.geometry.coordinate, QtPositioning)
    property real radiusLat: modelData.geometry.radiusB
    property real radiusLon: modelData.geometry.radiusA
    property real previewRadiusX: 0
    property real previewRadiusY: 0

    // shape modification preview
    property real modPreviewRX: 0
    property real modPreviewRY: 0
    property bool isChangingHandle: false

    ListModel {
        id: dragHandlersModel
    }

    function updateDragHandlers() {
        const coords = [
            QtPositioning.coordinate(center.latitude + radiusLat, center.longitude), // N
            QtPositioning.coordinate(center.latitude, center.longitude + radiusLon), // E
            QtPositioning.coordinate(center.latitude - radiusLat, center.longitude), // S
            QtPositioning.coordinate(center.latitude, center.longitude - radiusLon), // W
        ]

        for (let i = 0; i < coords.length; i++) {
            if (dragHandlersModel.get(i)) dragHandlersModel.set(i, coords[i])
            else dragHandlersModel.insert(i, coords[i])
        }
    }

    function calculatePreviewRadii() {
        const previewPoint = map.fromCoordinate(QtPositioning.coordinate(center.latitude + radiusLat, center.longitude + radiusLon), false)
        const centerPoint = map.fromCoordinate(center, false)
        previewRadiusX = Math.abs(previewPoint.x - centerPoint.x)
        previewRadiusY = Math.abs(previewPoint.y - centerPoint.y)
    }

    function calculateModPreviewRadii() {
        const previewPoint = map.fromCoordinate(QtPositioning.coordinate(center.latitude + radiusLat, center.longitude + radiusLon), false)
        const centerPoint = map.fromCoordinate(center, false)
        modPreviewRX = Math.abs(previewPoint.x - centerPoint.x)
        modPreviewRY = Math.abs(previewPoint.y - centerPoint.y)
    }

    Component.onCompleted: {
        Qt.callLater(function () {
            calculatePreviewRadii()
            updateDragHandlers()
        })
    }

    MapQuickItem {
        id: mapEllipse

        coordinate: center
        anchorPoint.x: previewRadiusX
        anchorPoint.y: previewRadiusY
        z: 1100

        sourceItem: Shape {
            // let dragging works inside the ellipse and
            // not it's "rectangle" bounding box
            containsMode: Shape.FillContains

            ShapePath {
                id: ellipsePath
                strokeWidth: 2
                strokeColor: root.color
                fillColor: root.bgColor

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

            ShapeTapHandler {}

            ShapeDragHandler {
                dragEnabled: !isChangingHandle
                property vector2d lastTranslation: Qt.vector2d(0, 0)

                // Manual drag handling than specifying a target object
                target: null

                onActiveChanged: {
                    if (active) lastTranslation = Qt.vector2d(0, 0)
                }

                handleTranslationChange: function () {
                    const dx = translation.x - lastTranslation.x
                    const dy = translation.y - lastTranslation.y
                    const screenPoint = map.fromCoordinate(root.center, false)

                    screenPoint.x += dx
                    screenPoint.y += dy

                    root.center = map.toCoordinate(screenPoint, false)

                    const newModelData = JSON.parse(JSON.stringify(modelData))
                    newModelData.geometry.coordinate = ShapeModel.toBECoordinate(root.center)
                    root.syncModelData(newModelData)

                    lastTranslation = Qt.vector2d(translation.x, translation.y)
                    updateDragHandlers()
                }

                onReleased: {
                    root.modified()
                }
            }
        }
    }

    MapQuickItem {
        id: highlight
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id

        coordinate: center
        anchorPoint.x: previewRadiusX
        anchorPoint.y: previewRadiusY
        z: mapEllipse.z - 1

        sourceItem: Shape {
            ShapePath {
                strokeWidth: ellipsePath.strokeWidth + 4
                strokeColor: "white"
                fillColor: "transparent"

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

    MapQuickItem {
        id: modPreviewEllipse
        visible: isChangingHandle

        coordinate: center
        anchorPoint.x: modPreviewRX
        anchorPoint.y: modPreviewRY
        z: mapEllipse.z - 2

        sourceItem: Shape {
            ShapePath {
                strokeWidth: ellipsePath.strokeWidth
                strokeColor: "blue"
                fillColor: "#4488cc88"

                startX: modPreviewRX * 2
                startY: modPreviewRY

                PathArc {
                    x: 0
                    y: modPreviewRY
                    radiusX: modPreviewRX
                    radiusY: modPreviewRY
                }

                PathArc {
                    x: modPreviewRX * 2
                    y: modPreviewRY
                    radiusX: modPreviewRX
                    radiusY: modPreviewRY
                }
            }
        }
    }

    MapItemView {
        model: dragHandlersModel
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id
        z: mapEllipse.z + 1

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
                xAxis.enabled: index == 1 || index == 3
                yAxis.enabled: index == 0 || index == 2

                onActiveChanged: {
                    isChangingHandle = active

                    if (isChangingHandle) {
                        calculateModPreviewRadii()
                    } else {
                        // update point model
                        root.radiusLat = dragHandlersModel.get(0).latitude - root.center.latitude
                        root.radiusLon = dragHandlersModel.get(1).longitude - root.center.longitude
                        calculatePreviewRadii()
                        root.updateDragHandlers()

                        // update shape data (remember that radiusA is longitude and radiusB is latitude)
                        const newModelData = JSON.parse(JSON.stringify(root.getModelData()))
                        newModelData.geometry.radiusA = root.radiusLon
                        newModelData.geometry.radiusB = root.radiusLat
                        root.syncModelData(newModelData)

                        root.modified()
                    }
                }

                onTranslationChanged: {
                    const centerScreen = map.fromCoordinate(root.center, false)
                    const handleScreen = Qt.point(
                        handle.x + handle.anchorPoint.x,
                        handle.y + handle.anchorPoint.y
                    )

                    const dx = handleScreen.x - centerScreen.x
                    const dy = handleScreen.y - centerScreen.y
                    const mirrorScreen = Qt.point(
                        centerScreen.x - dx,
                        centerScreen.y - dy
                    )

                    const handleCoord = map.toCoordinate(handleScreen, false)
                    const mirrorCoord = map.toCoordinate(mirrorScreen, false)
                    switch (index) {
                    case 0:  // North
                        dragHandlersModel.set(0, handleCoord)
                        dragHandlersModel.set(2, mirrorCoord)
                        root.modPreviewRY = Math.abs(dy)
                        break
                    case 2:  // South
                        dragHandlersModel.set(2, handleCoord)
                        dragHandlersModel.set(0, mirrorCoord)
                        root.modPreviewRY = Math.abs(dy)
                        break
                    case 1:  // East
                        dragHandlersModel.set(1, handleCoord)
                        dragHandlersModel.set(3, mirrorCoord)
                        root.modPreviewRX = Math.abs(dx)
                        break
                    case 3:  // West
                        dragHandlersModel.set(3, handleCoord)
                        dragHandlersModel.set(1, mirrorCoord)
                        root.modPreviewRX = Math.abs(dx)
                        break
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: mapEllipse
        text: modelData.label
        font.pixelSize: 12
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }

    Connections {
        target: map

        function onZoomLevelChanged() {
            root.calculatePreviewRadii()
        }
    }
}
