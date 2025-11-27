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

    readonly property bool isEditing: MapModeController.alertZone && id === MapModeController.alertZone.id

    // Input state
    property bool isDraggingHandler: false

    readonly property color zoneColor: {
        console.log("AlertZone", label, "active:", active, "severity:", severity)
        if (!active) return "#888888"
        switch(severity) {
            case "high": return "#FF0000"
            case "medium": return "#FF6600"
            case "low":
            default: return "#FFCC00"
        }
    }

    function clampLat(v)   { return Math.max(-90, Math.min(90, v)) }
    function normLon(v) {
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

    MapRectangle {
        id: committedRect
        topLeft: model.topLeft
        bottomRight: model.bottomRight
        color: Qt.rgba(root.zoneColor.r, root.zoneColor.g, root.zoneColor.b, 0.13)
        border.color: root.zoneColor
        border.width: 3
        z: root.z

        property point _startTLpx: Qt.point(0, 0)
        property point _startBRpx: Qt.point(0, 0)

        TapHandler {
            enabled: !isEditing && !MapModeController.isCreating
            gesturePolicy: TapHandler.ReleaseWithinBounds
            acceptedButtons: Qt.LeftButton
            onTapped: MapModeController.editAlertZone(AlertZoneModel.getEditableAlertZone(index))
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
                committedRect._startTLpx = MapController.map.fromCoordinate(topLeft, false)
                committedRect._startBRpx = MapController.map.fromCoordinate(bottomRight, false)
            }

            onActiveTranslationChanged: {
                const dx = activeTranslation.x, dy = activeTranslation.y
                const tlPx = Qt.point(committedRect._startTLpx.x + dx, committedRect._startTLpx.y + dy)
                const brPx = Qt.point(committedRect._startBRpx.x + dx, committedRect._startBRpx.y + dy)
                model.topLeft     = MapController.map.toCoordinate(tlPx, false)
                MapModeRegistry.editRectangleMode.topLeftChanged()
                model.bottomRight = MapController.map.toCoordinate(brPx, false)
                MapModeRegistry.editRectangleMode.bottomRightChanged()
                normalizeCorners()
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
        sourceItem: Rectangle { width:16; height:16; radius:8; color:"white"; border.color: root.zoneColor; border.width: 2 }
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

                    normalizeCorners()

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
        color: Theme.colors.hexWithAlpha(root.zoneColor, 0.8)
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
