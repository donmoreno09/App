import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

EllipseMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    // Ellipse parameters (center + half-axes in degrees)
    property geoCoordinate coord: QtPositioning.coordinate()
    property real radiusA: 0      // longitude half-axis (E/W), shortest wrap
    property real radiusB: 0      // latitude half-axis (N/S)
    readonly property bool hasEllipse: coord.isValid && radiusA > 0 && radiusB > 0

    // Input state
    property bool  dragging: drag.active
    property point dragStart: drag.centroid.pressPosition
    property point dragEnd: drag.centroid.position
    property bool  isDraggingHandler: false

    // ----- API -----
    function buildGeometry() {
        return {
            shapeTypeId: MapModeController.EllipseType,
            coordinate: { x: root.coord.longitude, y: root.coord.latitude },
            radiusA: root.radiusA,
            radiusB: root.radiusB,
        }
    }

    function resetPreview() {
        coord   = QtPositioning.coordinate()
        radiusA = 0
        root.majorAxisChanged()
        radiusB = 0
        root.minorAxisChanged()
    }

    // ----- Helpers -----
    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) }
    function normLon(v)    { let x=v; while (x<-180) x+=360; while (x>180) x-=360; return x }
    function lonDelta(a,b) { // shortest |b-a| on sphere in degrees
        let d = b - a
        while (d > 180) d -= 360
        while (d < -180) d += 360
        return Math.abs(d)
    }

    function setCenter(lat, lon) {
        const la = (lat === undefined || lat === null) ? coord.latitude  : clampLat(Number(lat))
        const lo = (lon === undefined || lon === null) ? coord.longitude : normLon(Number(lon))
        coord = QtPositioning.coordinate(la, lo)
    }

    function setRadii(a, b) {
        // a = longitude half-axis, b = latitude half-axis
        radiusA = Math.max(0, Number(a))
        root.majorAxisChanged()
        radiusB = Math.max(0, Number(b))
        root.minorAxisChanged()
    }

    // Parametric ellipse to polygon (geo path)
    function ellipsePath(segments = 72) {
        if (!coord.isValid || radiusA <= 0 || radiusB <= 0) return []
        const arr = []
        const la0 = coord.latitude
        const lo0 = coord.longitude
        for (let i = 0; i <= segments; ++i) {
            const t = (i / segments) * Math.PI * 2
            const la = la0 + radiusB * Math.sin(t)  // latitude uses radiusB
            const loOff = radiusA * Math.cos(t)     // longitude uses radiusA
            const lo = normLon(lo0 + loOff)
            arr.push(QtPositioning.coordinate(clampLat(la), lo))
        }
        return arr
    }

    // ----- Input: click to clear if not dragging/moving -----
    TapHandler {
        id: tap
        acceptedButtons: Qt.LeftButton
        onPressedChanged: if (!pressed && !drag.active && !moveTap.pressed && !moveDrag.active) root.resetPreview()
    }

    // ----- Initial draw by dragging a bbox -----
    DragHandler {
        id: drag
        target: null
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.CrossCursor
        enabled: !moveTap.pressed && !isDraggingHandler

        onTranslationChanged: {
            const tl = MapController.map.toCoordinate(Qt.point(Math.min(dragStart.x, dragEnd.x),
                                                               Math.min(dragStart.y, dragEnd.y)))
            const br = MapController.map.toCoordinate(Qt.point(Math.max(dragStart.x, dragEnd.x),
                                                               Math.max(dragStart.y, dragEnd.y)))
            if (!tl.isValid || !br.isValid) return

            // center = bbox center
            const cLat = (tl.latitude  + br.latitude ) / 2
            const cLon = (tl.longitude + br.longitude) / 2
            coord = QtPositioning.coordinate(clampLat(cLat), normLon(cLon))

            // radii = half of bbox size
            radiusA = lonDelta(tl.longitude, br.longitude) / 2  // A = longitude
            root.majorAxisChanged()
            radiusB = Math.abs(br.latitude  - tl.latitude ) / 2  // B = latitude
            root.minorAxisChanged()
        }
    }

    // ----- Preview while dragging -----
    MapPolygon {
        visible: root.dragging
        path: root.ellipsePath(96)
        color: "#3388cc88"
        border.color: "orange"
        border.width: 2
        z: root.z + 1
    }

    // ----- Committed ellipse -----
    MapPolygon {
        id: committedEllipse
        visible: !root.dragging && hasEllipse
        path: root.ellipsePath(96)
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: root.z + 1

        // Move whole ellipse
        property point _centerPx: Qt.point(0,0)

        // Prevent tap propagating below
        TapHandler { id: moveTap; acceptedButtons: Qt.LeftButton; gesturePolicy: TapHandler.ReleaseWithinBounds }

        DragHandler {
            id: moveDrag
            target: null
            enabled: !isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                committedEllipse._centerPx = MapController.map.fromCoordinate(root.coord, false)
            }

            onActiveTranslationChanged: {
                const p = Qt.point(committedEllipse._centerPx.x + activeTranslation.x,
                                   committedEllipse._centerPx.y + activeTranslation.y)
                const c = MapController.map.toCoordinate(p, false)
                if (c.isValid) root.coord = QtPositioning.coordinate(clampLat(c.latitude), normLon(c.longitude))
            }
        }
    }

    // subtle white halo behind committed border
    MapPolygon {
        visible: !root.dragging
        path: root.ellipsePath(96)
        color: "transparent"
        border.color: "white"
        border.width: committedEllipse.border.width + 4
        z: committedEllipse.z - 1
    }

    // ----- Vertex handles (N, E, S, W) -----
    component EdgeHandle: MapQuickItem {
        id: h
        required property int kind // 0: N, 1: E, 2: S, 3: W

        coordinate: (
            kind === 0 ? QtPositioning.coordinate(root.coord.latitude + root.radiusB, root.coord.longitude) :
            kind === 1 ? QtPositioning.coordinate(root.coord.latitude, normLon(root.coord.longitude + root.radiusA)) :
            kind === 2 ? QtPositioning.coordinate(root.coord.latitude - root.radiusB, root.coord.longitude) :
                         QtPositioning.coordinate(root.coord.latitude, normLon(root.coord.longitude - root.radiusA))
        )

        anchorPoint: Qt.point(8, 8)
        sourceItem: Rectangle { width:16; height:16; radius:8; color:"white"; border.color:"green" }
        visible: !root.dragging
        z: committedEllipse.z + 1

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onPressedChanged: root.isDraggingHandler = pressed
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        DragHandler {
            target: null
            acceptedButtons: Qt.LeftButton
            grabPermissions: PointerHandler.CanTakeOverFromAnything

            onTranslationChanged: {
                const p = h.mapToItem(MapController.map, centroid.position.x, centroid.position.y)
                const c = MapController.map.toCoordinate(p, false)
                if (!c.isValid) return

                if (h.kind === 0 || h.kind === 2) {
                    // N/S -> adjust latitude radius (B)
                    root.radiusB = Math.max(0, Math.abs(c.latitude - root.coord.latitude))
                    root.minorAxisChanged()
                } else {
                    // E/W -> adjust longitude radius (A)
                    root.radiusA = Math.max(0, lonDelta(root.coord.longitude, c.longitude))
                    root.majorAxisChanged()
                }
            }
        }
    }

    EdgeHandle { id: northHandle; kind: 0 }
    EdgeHandle { id: eastHandle;  kind: 1 }
    EdgeHandle { id: southHandle; kind: 2 }
    EdgeHandle { id: westHandle;  kind: 3 }
}
