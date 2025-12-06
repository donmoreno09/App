import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

MapItemGroup {
    id: root
    z: Theme.elevation.z100 + (isEditing) ? 100 : 0

    readonly property bool isEditing: MapModeController.poi && id === MapModeController.poi.id

    property bool isDraggingHandle: false

    MapPolygon {
        id: polygon
        path: coordinates
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: root.z
        property var _startPx: [] // [{x,y} per vertex]

        // Block input going through
        TapHandler { gesturePolicy: TapHandler.ReleaseWithinBounds }

        TapHandler {
            enabled: !isEditing && !MapModeController.isCreating
            acceptedButtons: Qt.LeftButton
            onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))
        }

        DragHandler {
            id: moveDrag
            target: null
            enabled: isEditing && !isDraggingHandle
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                polygon._startPx = []
                for (let i = 0; i < coordinates.length; i++)
                    polygon._startPx.push(MapController.map.fromCoordinate(coordinates[i], false))
            }

            onActiveTranslationChanged: {
                const dx = activeTranslation.x, dy = activeTranslation.y
                for (let i = 0; i < polygon._startPx.length; i++) {
                    const point = Qt.point(polygon._startPx[i].x + dx, polygon._startPx[i].y + dy)
                    const coord = MapController.map.toCoordinate(point, false)
                    if (coord.isValid) PoiModel.setCoordinate(modelIndex, i, coord)
                }
                MapModeRegistry.editPolygonMode.coordinatesChanged()
            }
        }
    }

    MapPolygon {
        visible: isEditing
        path: polygon.path
        color: "transparent"
        border.color: "white"
        border.width: polygon.border.width + 4
        z: polygon.z - 1
    }

    MapItemView {
        visible: isEditing
        z: polygon.z + 1
        model: coordinates.length
        delegate: MapQuickItem {
            id: handle

            required property int index
            property real latitude: coordinates[index].latitude
            property real longitude:  coordinates[index].longitude

            coordinate: QtPositioning.coordinate(latitude, longitude)
            anchorPoint: Qt.point(8, 8)
            sourceItem: Rectangle { width: 16; height: 16; radius: 8; color: "white"; border.color: "green" }

            TapHandler {
                acceptedButtons: Qt.LeftButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
            }

            DragHandler {
                target: null
                acceptedButtons: Qt.LeftButton
                grabPermissions: PointerHandler.CanTakeOverFromAnything

                onTranslationChanged: {
                    const point = handle.mapToItem(MapController.map, centroid.position.x, centroid.position.y)
                    const coord = MapController.map.toCoordinate(point, false)
                    if (coord.isValid) {
                        PoiModel.setCoordinate(modelIndex, handle.index, coord)
                        MapModeRegistry.editPolygonMode.coordinatesChanged()
                    }
                }

                onActiveChanged: root.isDraggingHandle = active
            }
        }
    }

    Rectangle {
        anchors.centerIn: polygon
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: Theme.colors.hexWithAlpha("#539E07", 0.6)
        border.color: Theme.colors.white
        border.width: isEditing ? Theme.borders.b1 : Theme.borders.b0
        z: polygon.z + 2

        Text {
            anchors.centerIn: parent
            id: text
            text: label
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.white
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
}
