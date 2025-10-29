import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

PolygonMode {
    id: root

    ListModel { id: coordinatesModel }
    property bool closed: false
    property bool isDraggingHandle: false

    function coordinatesCount() {
        return coordinatesModel.count
    }

    function getCoordinate(index) {
        return coordinatesModel.get(index)
    }

    function setCoordinate(index, coord) {
        if (index < 0 || index >= coordinatesModel.count) return;

        if (root.closed) poly.path[index] = coord
        else polyPreview.path[index] = coord
        coordinatesModel.set(index, coord)
    }

    function buildGeometry() {
        if (coordinatesModel.count < 3) return {}

        const out = []
        for (let i = 0; i < coordinatesModel.count; i++) {
            const coord = coordinatesModel.get(i)
            out.push({ x: coord.longitude, y: coord.latitude })
        }
        out.push({ x: out[0].longitude, y: out[0].latitude })

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: out
        }
    }

    function resetPreview() {
        polyPreview.path = []
        poly.path = []
        coordinatesModel.clear()
        closed = false
        root.coordinatesChanged()
    }

    function _addCoordinate(coord: geoCoordinate) {
        // Path needs to be manually updated here because Qt doesn't update on set since ListModel uses JS objects
        coordinatesModel.append(coord)
        polyPreview.path = _polylinePath()
    }

    function _polylinePath() {
        const path = []
        for (let i = 0; i < coordinatesModel.count; i++)
            path.push(coordinatesModel.get(i))
        return path
    }

    function _polygonPath() {
        if (coordinatesModel.count < 3) return []

        const path = []
        for (let i = 0; i < coordinatesModel.count; i++)
            path.push(coordinatesModel.get(i))
        return path
    }

    function _tryClose() {
        if (closed || coordinatesModel.count < 3) return

        // Path needs to be manually updated here because Qt doesn't update on set since ListModel uses JS objects
        polyPreview.path = []
        poly.path = _polygonPath()
        closed = true
        root.coordinatesChanged()
    }

    TapHandler {
        id: addTap
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        enabled: !moveTap.pressed && !root.isDraggingHandler

        onTapped: function(event) {
            if (closed) {
                root.resetPreview()
            }

            const point = MapController.map.mapFromItem(root, event.position)
            const coord = MapController.map.toCoordinate(point, false)
            if (coord.isValid) _addCoordinate(coord)
            if (event.tapCount >= 2) _tryClose()
        }
    }

    MapPolyline {
        id: polyPreview
        visible: !root.closed && coordinatesModel.count > 0
        line.width: 2
        line.color: "orange"
        z: Theme.elevation.z100 + 1
        path: root._polylinePath()
    }

    MapPolygon {
        id: poly
        visible: root.closed
        path: root._polygonPath()
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: Theme.elevation.z100 + 1

        property var _startPx: [] // [{x,y} per vertex]

        TapHandler { id: moveTap; acceptedButtons: Qt.LeftButton }

        DragHandler {
            id: moveDrag
            target: null
            enabled: root.closed && !root.isDraggingHandle
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                poly._startPx = []
                for (let i = 0; i < coordinatesModel.count; i++)
                    poly._startPx.push(MapController.map.fromCoordinate(coordinatesModel.get(i), false))
            }

            onActiveTranslationChanged: {
                const dx = activeTranslation.x, dy = activeTranslation.y
                for (let i = 0; i < poly._startPx.length; i++) {
                    const point = Qt.point(poly._startPx[i].x + dx, poly._startPx[i].y + dy)
                    const coord = MapController.map.toCoordinate(point, false)
                    if (coord.isValid) {
                        // Since Qt doesn't signal that coordinatesModel has changed,
                        // we manually update the path. It could be because coordinatesModel
                        // uses a JavaScript object.
                        poly.path[i] = coord
                        coordinatesModel.set(i, coord)
                    }
                }
                root.coordinatesChanged()
            }
        }
    }

    // subtle white halo behind committed border
    MapPolygon {
        visible: poly.visible
        color: "transparent"
        border.color: "white"
        border.width: poly.border.width + 4
        z: poly.z - 1
    }

    MapItemView {
        z: (root.closed ? poly.z : polyPreview.z) + 1
        model: coordinatesModel
        delegate: MapQuickItem {
            id: handle

            required property real latitude
            required property real longitude
            required property int index

            coordinate: QtPositioning.coordinate(latitude, longitude)
            anchorPoint: Qt.point(8, 8)
            sourceItem: Rectangle { width: 16; height: 16; radius: 8; color: "white"; border.color: "green" }

            TapHandler {
                acceptedButtons: Qt.LeftButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: {
                    if (!root.closed && handle.index === 0 && coordinatesModel.count >= 3)
                        root._tryClose()
                }
            }

            DragHandler {
                target: null
                acceptedButtons: Qt.LeftButton
                grabPermissions: PointerHandler.CanTakeOverFromAnything

                onTranslationChanged: {
                    const point = handle.mapToItem(MapController.map, centroid.position.x, centroid.position.y)
                    const coord = MapController.map.toCoordinate(point, false)
                    if (coord.isValid) {
                        if (root.closed) poly.path[handle.index] = coord
                        else polyPreview.path[handle.index] = coord
                        coordinatesModel.set(handle.index, coord)
                        root.coordinatesChanged()
                    }
                }

                onActiveChanged: root.isDraggingHandle = active
            }
        }
    }
}
