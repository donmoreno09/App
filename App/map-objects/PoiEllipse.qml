// PoiEllipse.qml
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

    // ---- helpers ----
    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) } // spec range
    function normLon(v)    { let x=v; while (x<-180) x+=360; while (x>180) x-=360; return x }
    function lonDelta(a,b) { // shortest |b-a| on sphere in degrees
        let d = b - a
        while (d > 180) d -= 360
        while (d < -180) d += 360
        return Math.abs(d)
    }

    function setCenter(lat, lon) {
        const la = (lat === undefined || lat === null) ? coordinate.latitude  : clampLat(Number(lat))
        const lo = (lon === undefined || lon === null) ? coordinate.longitude : normLon(Number(lon))
        model.coordinate = QtPositioning.coordinate(la, lo)
        MapModeRegistry.editEllipseMode.coordChanged()
    }

    function setRadii(a, b) {
        // a = longitude half-axis (E/W), b = latitude half-axis (N/S)
        model.radiusA = Math.max(0, Number(a))
        MapModeRegistry.editEllipseMode.majorAxisChanged()
        model.radiusB = Math.max(0, Number(b))
        MapModeRegistry.editEllipseMode.minorAxisChanged()
    }

    // Parametric ellipse to polygon (geo path)
    function ellipsePath(segments = 96) {
        if (!coordinate.isValid || radiusA <= 0 || radiusB <= 0) return []
        const arr = []
        const la0 = coordinate.latitude
        const lo0 = coordinate.longitude
        for (let i = 0; i <= segments; ++i) {
            const t = (i / segments) * Math.PI * 2
            const la = clampLat(la0 + radiusB * Math.sin(t))   // latitude uses B
            const lo = normLon(lo0 + radiusA * Math.cos(t))    // longitude uses A
            arr.push(QtPositioning.coordinate(la, lo))
        }
        return arr
    }

    // ---- committed ellipse body ----
    MapPolygon {
        id: ellipse
        path: root.ellipsePath()
        color: "#22448888"
        border.color: "green"
        border.width: 2
        z: root.z

        // Scratch state for drag
        property point _centerPx: Qt.point(0,0)

        TapHandler {
            enabled: !isEditing && !MapModeController.isCreating
            gesturePolicy: TapHandler.ReleaseWithinBounds
            acceptedButtons: Qt.LeftButton
            onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))
        }

        // Move whole ellipse (when editing)
        TapHandler { id: moveTap; acceptedButtons: Qt.LeftButton }

        DragHandler {
            id: moveDrag
            target: null
            enabled: isEditing && !isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                ellipse._centerPx = MapController.map.fromCoordinate(coordinate, false)
            }

            onActiveTranslationChanged: {
                const p = Qt.point(ellipse._centerPx.x + activeTranslation.x,
                                   ellipse._centerPx.y + activeTranslation.y)
                const c = MapController.map.toCoordinate(p, false)
                if (!c.isValid) return
                model.coordinate = QtPositioning.coordinate(clampLat(c.latitude), normLon(c.longitude))
                MapModeRegistry.editEllipseMode.coordChanged()
            }
        }
    }

    // subtle white halo behind committed border
    MapPolygon {
        id: highlight
        path: root.ellipsePath(96)
        color: "transparent"
        border.color: "white"
        border.width: ellipse.border.width + 4
        z: ellipse.z - 1
        visible: isEditing
    }

    // ---- handles (N, E, S, W) ----
    component EdgeHandle: MapQuickItem {
        id: h
        required property int kind // 0: N, 1: E, 2: S, 3: W

        coordinate: (
            kind === 0 ? QtPositioning.coordinate(model.coordinate.latitude + model.radiusB, model.coordinate.longitude) :
            kind === 1 ? QtPositioning.coordinate(model.coordinate.latitude, normLon(model.coordinate.longitude + model.radiusA)) :
            kind === 2 ? QtPositioning.coordinate(model.coordinate.latitude - model.radiusB, model.coordinate.longitude) :
                         QtPositioning.coordinate(model.coordinate.latitude, normLon(model.coordinate.longitude - model.radiusA))
        )

        anchorPoint: Qt.point(8, 8)
        sourceItem: Rectangle { width:16; height:16; radius:8; color:"white"; border.color:"green" }
        visible: isEditing
        z: ellipse.z + 1

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
                if (!c.isValid) return

                if (h.kind === 0 || h.kind === 2) {
                    // N/S -> adjust latitude radius (B)
                    model.radiusB = Math.max(0, Math.abs(c.latitude - model.coordinate.latitude))
                    MapModeRegistry.editEllipseMode.minorAxisChanged()
                } else {
                    // E/W -> adjust longitude radius (A)
                    model.radiusA = Math.max(0, lonDelta(model.coordinate.longitude, c.longitude))
                    MapModeRegistry.editEllipseMode.majorAxisChanged()
                }
            }
        }
    }

    EdgeHandle { id: northHandle; kind: 0 }
    EdgeHandle { id: eastHandle;  kind: 1 }
    EdgeHandle { id: southHandle; kind: 2 }
    EdgeHandle { id: westHandle;  kind: 3 }

    // ---- center label ----
    Rectangle {
        anchors.centerIn: ellipse
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: Theme.colors.hexWithAlpha("#539E07", 0.6)
        border.color: Theme.colors.white
        border.width: isEditing ? Theme.borders.b1 : Theme.borders.b0
        z: ellipse.z + 2
        visible: coordinate.isValid && radiusA > 0 && radiusB > 0

        Text {
            id: text
            anchors.centerIn: parent
            text: label
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.white
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
}
