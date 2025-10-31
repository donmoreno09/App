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

    // Input state
    property bool  dragging: drag.active
    property point dragStart: drag.centroid.pressPosition
    property point dragEnd: drag.centroid.position
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
    }

    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) } // spec range
    function normLon(v) { // wrap to [-180,180]
        let x = v; while (x < -180) x += 360; while (x > 180) x -= 360; return x
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
            topLeft = tl
            bottomRight = br
        }
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

        onTranslationChanged: {
            topLeft = MapController.map.toCoordinate(Qt.point(Math.min(dragStart.x, dragEnd.x),
                                                              Math.min(dragStart.y, dragEnd.y)))
            bottomRight = MapController.map.toCoordinate(Qt.point(Math.max(dragStart.x, dragEnd.x),
                                                                  Math.max(dragStart.y, dragEnd.y)))
            root.normalizeCorners()
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
        visible: !root.dragging
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
