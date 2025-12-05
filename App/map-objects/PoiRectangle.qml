import QtQuick 6.8
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

    // Input state
    property bool isDraggingHandler: false

    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) } // spec range
    function normLon(v) { // wrap to [-180,180]
        let x = v; while (x < -180) x += 360; while (x > 180) x -= 360; return x
    }

    function setTopLeft(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? topLeft.latitude  : clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? topLeft.longitude : normLon(Number(lon))
        model.topLeft = QtPositioning.coordinate(lat1, lon1)
        MapModeRegistry.editRectangleMode.topLeftChanged()
        normalizeCorners()
    }
    function setBottomRight(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? bottomRight.latitude  : clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? bottomRight.longitude : normLon(Number(lon))
        model.bottomRight = QtPositioning.coordinate(lat1, lon1)
        MapModeRegistry.editRectangleMode.bottomRightChanged()
        normalizeCorners()
    }

    function normalizeCorners() {
        // Keep NW -> SE ordering
        const n = Math.max(topLeft.latitude, bottomRight.latitude)
        const s = Math.min(topLeft.latitude, bottomRight.latitude)
        const w = Math.min(topLeft.longitude, bottomRight.longitude)
        const e = Math.max(topLeft.longitude, bottomRight.longitude)
        const tl = QtPositioning.coordinate(n, w)
        const br = QtPositioning.coordinate(s, e)
        if (tl.latitude !== topLeft.latitude || tl.longitude !== topLeft.longitude
                || br.latitude !== bottomRight.latitude || br.longitude !== bottomRight.longitude) {
            model.topLeft = tl
            MapModeRegistry.editRectangleMode.topLeftChanged()
            model.bottomRight = br
            MapModeRegistry.editRectangleMode.bottomRightChanged()
        }
    }

    // Input handlers
    MapRectangle {
        id: committedRect
        topLeft: model.topLeft
        bottomRight: model.bottomRight
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: root.z

        // Scratch state for drag (scene-based, stable under rotation/tilt)
        property geoCoordinate _startTLCoord: QtPositioning.coordinate()
        property geoCoordinate _startBRCoord: QtPositioning.coordinate()
        property geoCoordinate _anchorCoord: QtPositioning.coordinate()
        property point _lastScenePos: Qt.point(0, 0)

        function applyMoveDelta() {
            if (!moveRect.active || !_startTLCoord.isValid || !_startBRCoord.isValid || !_anchorCoord.isValid)
                return

            // 1. Pointer in scene coordinates (real screen position)
            const scenePos = moveRect.centroid.scenePosition

            // 2. Convert scene -> map local
            const pointerPx = MapController.map.mapFromItem(null, scenePos.x, scenePos.y)

            // 3. Anchor geo -> map local
            const anchorPx = MapController.map.fromCoordinate(_anchorCoord, false)

            const dx = pointerPx.x - anchorPx.x
            const dy = pointerPx.y - anchorPx.y

            const startTLpx = MapController.map.fromCoordinate(_startTLCoord, false)
            const startBRpx = MapController.map.fromCoordinate(_startBRCoord, false)

            const tlPx = Qt.point(startTLpx.x + dx, startTLpx.y + dy)
            const brPx = Qt.point(startBRpx.x + dx, startBRpx.y + dy)

            const tlCoord = MapController.map.toCoordinate(tlPx, false)
            const brCoord = MapController.map.toCoordinate(brPx, false)
            if (!tlCoord.isValid || !brCoord.isValid)
                return

            model.topLeft = tlCoord
            MapModeRegistry.editRectangleMode.topLeftChanged()
            model.bottomRight = brCoord
            MapModeRegistry.editRectangleMode.bottomRightChanged()
            normalizeCorners()
        }

        // Block input going through
        TapHandler { gesturePolicy: TapHandler.ReleaseWithinBounds }

        TapHandler {
            enabled: !isEditing && !MapModeController.isCreating
            acceptedButtons: Qt.LeftButton
            onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))
        }

        DragHandler {
            id: moveRect
            target: null
            enabled: isEditing && !isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                // Store starting geo coords
                committedRect._startTLCoord = model.topLeft
                committedRect._startBRCoord = model.bottomRight

                // Anchor at press position in scene coords
                const pressScene = moveRect.centroid.scenePressPosition
                committedRect._lastScenePos = pressScene

                // scene -> map
                const pressPx = MapController.map.mapFromItem(null, pressScene.x, pressScene.y)
                committedRect._anchorCoord = MapController.map.toCoordinate(pressPx, false)
            } else {
                committedRect._startTLCoord = QtPositioning.coordinate()
                committedRect._startBRCoord = QtPositioning.coordinate()
                committedRect._anchorCoord = QtPositioning.coordinate()
            }

            onActiveTranslationChanged: {
                // Only react to *real* mouse movement in scene coords
                const scenePos = centroid.scenePosition
                if (scenePos.x === committedRect._lastScenePos.x &&
                    scenePos.y === committedRect._lastScenePos.y) {
                    return // map rotated/tilted but pointer didn't move
                }

                committedRect._lastScenePos = scenePos
                committedRect.applyMoveDelta()
            }
        }
    }

    MapRectangle {
        id: highlight
        visible: isEditing
        topLeft: model.topLeft
        bottomRight: model.bottomRight
        color: "transparent"
        border.color: "white"
        border.width: committedRect.border.width + 4
        z: committedRect.z - 1
    }

    property var _handles
    Component.onCompleted: _handles = [topLeftVertex, topRightVertex, bottomRightVertex, bottomLeftVertex]

    function _swapKinds(h, newKind) {
        if (h.kind === newKind) return

        for (let i = 0; i < _handles.length; ++i) {
            const other = _handles[i]
            if (other !== h && other.kind === newKind) {
                const t = other.kind
                other.kind = h.kind
                h.kind = newKind
                return
            }
        }

        // fallback (shouldn't happen): no owner found
        h.kind = newKind
    }

    component VertexHandle: MapQuickItem {
        id: h
        required property int kind // 0 TL, 1 TR, 2 BR, 3 BL
        coordinate: (
            kind === 0 ? topLeft :
            kind === 1 ? QtPositioning.coordinate(topLeft.latitude, bottomRight.longitude) :
            kind === 2 ? bottomRight :
                         QtPositioning.coordinate(bottomRight.latitude, topLeft.longitude)
        )
        anchorPoint: Qt.point(8, 8)
        sourceItem: Rectangle { width:16; height:16; radius:8; color:"white"; border.color:"green" }
        visible: isEditing
        z: committedRect.z + 1

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onPressedChanged: isDraggingHandler = pressed
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        DragHandler {
            target: null
            acceptedButtons: Qt.LeftButton
            grabPermissions: PointerHandler.CanTakeOverFromAnything

            onTranslationChanged: {
                const p = h.mapToItem(MapController.map, centroid.position.x, centroid.position.y)
                const c = MapController.map.toCoordinate(p, false)

                if (h.kind === 0) {
                    model.topLeft = c
                    MapModeRegistry.editRectangleMode.topLeftChanged()
                }
                else if (h.kind === 1) {
                    model.topLeft = QtPositioning.coordinate(c.latitude, topLeft.longitude)
                    MapModeRegistry.editRectangleMode.topLeftChanged()
                    model.bottomRight = QtPositioning.coordinate(bottomRight.latitude, c.longitude)
                    MapModeRegistry.editRectangleMode.bottomRightChanged()
                }
                else if (h.kind === 2) {
                    model.bottomRight = c
                    MapModeRegistry.editRectangleMode.bottomRightChanged()
                }
                else {
                    model.bottomRight = QtPositioning.coordinate(c.latitude, bottomRight.longitude)
                    MapModeRegistry.editRectangleMode.bottomRightChanged()
                    model.topLeft = QtPositioning.coordinate(topLeft.latitude, c.longitude)
                    MapModeRegistry.editRectangleMode.topLeftChanged()
                }

                normalizeCorners() // keep TL=NW, BR=SE

                // re-label by SWAPPING owners so kinds stay unique
                const corners = [
                    { kind: 0, c: topLeft },
                    { kind: 1, c: QtPositioning.coordinate(topLeft.latitude, bottomRight.longitude) },
                    { kind: 2, c: bottomRight },
                    { kind: 3, c: QtPositioning.coordinate(bottomRight.latitude, topLeft.longitude) },
                ]
                let nearest = h.kind, best = Infinity
                for (let i = 0; i < corners.length; ++i) {
                    const px = MapController.map.fromCoordinate(corners[i].c, false)
                    const dx = px.x - p.x, dy = px.y - p.y
                    const d2 = dx*dx + dy*dy
                    if (d2 < best) { best = d2; nearest = corners[i].kind }
                }
                _swapKinds(h, nearest)
            }
        }
    }

    VertexHandle { id: topLeftVertex; kind: 0 }
    VertexHandle { id: topRightVertex; kind: 1 }
    VertexHandle { id: bottomRightVertex; kind: 2 }
    VertexHandle { id: bottomLeftVertex; kind: 3 }

    Rectangle {
        anchors.centerIn: committedRect
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: Theme.colors.hexWithAlpha("#539E07", 0.6)
        border.color: Theme.colors.white
        border.width: isEditing ? Theme.borders.b1 : Theme.borders.b0
        z: committedRect.z + 2

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
