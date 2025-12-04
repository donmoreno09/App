import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

RectangleMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    // Final (committed) rectangle
    property geoCoordinate topLeft: QtPositioning.coordinate()
    property geoCoordinate bottomRight: QtPositioning.coordinate()

    // Listen to map events while drawing
    Connections {
        target: MapController.map

        function onBearingChanged() {
            // Keep the preview rectangle anchored when the map rotates mid-drag
            updatePreviewRectangle()
        }

        function onTiltChanged() {
            // Keep the preview rectangle anchored when the map tilts mid-drag
            updatePreviewRectangle()
        }
    }

    // Input state
    property bool  dragging: drag.active
    property point dragStart: drag.centroid.pressPosition
    property point dragEnd: drag.centroid.position
    property geoCoordinate dragStartCoord: QtPositioning.coordinate()
    property bool isDraggingHandler: false

    function buildGeometry() {
        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: root.rectToPoints({ topLeft, bottomRight }),
        }
    }

    function resetPreview() {
        topLeft = QtPositioning.coordinate()
        bottomRight = QtPositioning.coordinate()
        dragStartCoord = QtPositioning.coordinate()
    }

    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) } // spec range
    function normLon(v) { // wrap to [-180,180]
        let x = v; while (x < -180) x += 360; while (x > 180) x -= 360; return x
    }

    function areValidCoords() {
        return topLeft.isValid && bottomRight.isValid
    }

    function setTopLeft(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? topLeft.latitude  : clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? topLeft.longitude : normLon(Number(lon))
        topLeft = QtPositioning.coordinate(lat1, lon1)
        normalizeCorners()
    }
    function setBottomRight(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? bottomRight.latitude  : clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? bottomRight.longitude : normLon(Number(lon))
        bottomRight = QtPositioning.coordinate(lat1, lon1)
        normalizeCorners()
    }

    function setTopLeftLatitude(lat)         { setTopLeft(lat,  undefined) }
    function setTopLeftLongitude(lon)        { setTopLeft(undefined, lon) }
    function setBottomRightLatitude(lat)     { setBottomRight(lat,  undefined) }
    function setBottomRightLongitude(lon)    { setBottomRight(undefined, lon) }

    function maxCheckNaN(a: real, b: real): real {
        if (isNaN(a)) return b
        if (isNaN(b)) return a
        return Math.max(a, b)
    }

    function minCheckNaN(a: real, b: real): real {
        if (isNaN(a)) return b
        if (isNaN(b)) return a
        return Math.min(a, b)
    }

    function normalizeCorners() {
        // Keep NW -> SE ordering
        const n = maxCheckNaN(topLeft.latitude, bottomRight.latitude)
        const s = minCheckNaN(topLeft.latitude, bottomRight.latitude)
        const w = minCheckNaN(topLeft.longitude, bottomRight.longitude)
        const e = maxCheckNaN(topLeft.longitude, bottomRight.longitude)
        const tl = QtPositioning.coordinate(n, w)
        const br = QtPositioning.coordinate(s, e)

        if (tl.latitude !== topLeft.latitude || tl.longitude !== topLeft.longitude) {
            topLeft = tl
        }

        if (br.latitude !== bottomRight.latitude || br.longitude !== bottomRight.longitude) {
            bottomRight = br
        }
    }

    function updatePreviewRectangle() {
        if (!drag.active) return

        // Use the stored start coordinate so re-orienting the map won't move the anchor point.
        let c1 = dragStartCoord
        if (!c1.isValid) {
            const p1 = MapController.map.mapFromItem(root, dragStart.x, dragStart.y)
            c1 = MapController.map.toCoordinate(p1, false)
        }

        const p2 = MapController.map.mapFromItem(root, dragEnd.x, dragEnd.y)
        const c2 = MapController.map.toCoordinate(p2, false)
        if (!c1.isValid || !c2.isValid) return

        const n = Math.max(c1.latitude, c2.latitude)
        const s = Math.min(c1.latitude, c2.latitude)
        const w = Math.min(c1.longitude, c2.longitude)
        const e = Math.max(c1.longitude, c2.longitude)

        topLeft = QtPositioning.coordinate(n, w)
        bottomRight = QtPositioning.coordinate(s, e)
    }

    // Input handlers
    TapHandler {
        id: tap
        acceptedButtons: Qt.LeftButton
        onPressedChanged: if (!pressed && !drag.active && !moveRect.active) root.resetPreview()
    }

    DragHandler {
        id: drag
        target: null
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.CrossCursor
        enabled: !moveRectTap.pressed && !isDraggingHandler

        onActiveChanged: if (active) {
            const p = MapController.map.mapFromItem(root, dragStart.x, dragStart.y)
            dragStartCoord = MapController.map.toCoordinate(p, false)
        } else {
            dragStartCoord = QtPositioning.coordinate()
        }

        onTranslationChanged: {
            updatePreviewRectangle()
        }
    }

    // Preview rectangle (geo-accurate)
    MapRectangle {
        visible: root.dragging
        topLeft: root.topLeft
        bottomRight: root.bottomRight
        color: "#3388cc88"
        border.color: "orange"
        border.width: 2
        z: root.z + 1
    }

    // Committed rectangle
    MapRectangle {
        id: committedRect
        visible: !root.dragging && root.areValidCoords()
        topLeft: root.topLeft
        bottomRight: root.bottomRight
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: root.z + 1

        // Scratch state for drag
        property point _startTLpx: Qt.point(0, 0)
        property point _startBRpx: Qt.point(0, 0)

        // Prevent tap propagating below
        TapHandler { id: moveRectTap; acceptedButtons: Qt.LeftButton; gesturePolicy: TapHandler.ReleaseWithinBounds }

        DragHandler {
            id: moveRect
            target: null
            enabled: !isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                committedRect._startTLpx = MapController.map.fromCoordinate(root.topLeft, false)
                committedRect._startBRpx = MapController.map.fromCoordinate(root.bottomRight, false)
            }

            onActiveTranslationChanged: {
                const dx = activeTranslation.x, dy = activeTranslation.y
                const tlPx = Qt.point(committedRect._startTLpx.x + dx, committedRect._startTLpx.y + dy)
                const brPx = Qt.point(committedRect._startBRpx.x + dx, committedRect._startBRpx.y + dy)
                root.topLeft     = MapController.map.toCoordinate(tlPx, false)
                root.bottomRight = MapController.map.toCoordinate(brPx, false)
                root.normalizeCorners()
            }
        }
    }

    MapRectangle {
        id: highlight
        visible: !root.dragging
        topLeft: root.topLeft
        bottomRight: root.bottomRight
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
        visible: !root.dragging
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

                    if (h.kind === 0) topLeft = c
                    else if (h.kind === 1) {
                        topLeft = QtPositioning.coordinate(c.latitude, topLeft.longitude)
                        bottomRight = QtPositioning.coordinate(bottomRight.latitude, c.longitude)
                    }
                    else if (h.kind === 2) bottomRight = c
                    else {
                        bottomRight = QtPositioning.coordinate(c.latitude, bottomRight.longitude)
                        topLeft = QtPositioning.coordinate(topLeft.latitude, c.longitude)
                    }

                    root.normalizeCorners() // keep TL=NW, BR=SE

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
                    root._swapKinds(h, nearest)
            }
        }
    }

    VertexHandle { id: topLeftVertex; kind: 0 }
    VertexHandle { id: topRightVertex; kind: 1 }
    VertexHandle { id: bottomRightVertex; kind: 2 }
    VertexHandle { id: bottomLeftVertex; kind: 3 }
}
