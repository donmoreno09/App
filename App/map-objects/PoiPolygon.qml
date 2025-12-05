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
        property var _startCoords: [] // coordinates at drag start
        property geoCoordinate _anchorCoord: QtPositioning.coordinate()
        property point _lastScenePos: Qt.point(0, 0)

        function applyMoveDelta() {
            if (!moveDrag.active || !_startCoords || _startCoords.length === 0 || !_anchorCoord.isValid)
                return

            const scenePos = moveDrag.centroid.scenePosition
            const pointerPx = MapController.map.mapFromItem(null, scenePos.x, scenePos.y)
            const anchorPx  = MapController.map.fromCoordinate(_anchorCoord, false)
            const dx = pointerPx.x - anchorPx.x
            const dy = pointerPx.y - anchorPx.y
            if (dx === 0 && dy === 0) return

            let changed = false
            for (let i = 0; i < _startCoords.length; i++) {
                const startCoord = _startCoords[i]
                if (!startCoord || !startCoord.isValid) continue

                const startPx = MapController.map.fromCoordinate(startCoord, false)
                const point = Qt.point(startPx.x + dx, startPx.y + dy)
                const coord = MapController.map.toCoordinate(point, false)
                if (coord.isValid) {
                    PoiModel.setCoordinate(modelIndex, i, coord)
                    changed = true
                }
            }

            if (changed) MapModeRegistry.editPolygonMode.coordinatesChanged()
        }

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
                polygon._startCoords = []
                for (let i = 0; i < coordinates.length; i++) {
                    const c = coordinates[i]
                    polygon._startCoords.push(QtPositioning.coordinate(c.latitude, c.longitude))
                }
                const pressScene = moveDrag.centroid.scenePressPosition
                polygon._lastScenePos = pressScene
                const pressPx = MapController.map.mapFromItem(null, pressScene.x, pressScene.y)
                polygon._anchorCoord = MapController.map.toCoordinate(pressPx, false)
            } else {
                polygon._startCoords = []
                polygon._anchorCoord = QtPositioning.coordinate()
                polygon._lastScenePos = Qt.point(0, 0)
            }

            onActiveTranslationChanged: {
                const scenePos = centroid.scenePosition
                if (scenePos.x === polygon._lastScenePos.x && scenePos.y === polygon._lastScenePos.y)
                    return
                polygon._lastScenePos = scenePos
                polygon.applyMoveDelta()
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
