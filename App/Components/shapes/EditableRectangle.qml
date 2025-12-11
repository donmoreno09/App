import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import "qrc:/App/Features/MapModes/modes/rectangle/RectangleGeometry.js" as RectGeom

MapItemGroup {
    id: root
    z: Theme.elevation.z100

    // External bindings
    property bool isEditing: false
    property bool tapEnabled: false
    property bool showHighlight: true
    property bool showLabel: true
    property color fillColor: "#22448888"
    property color strokeColor: "green"
    property color highlightColor: "white"
    property color labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    property color labelBorderColor: Theme.colors.white
    property color labelTextColor: Theme.colors.white
    property real labelBorderWidth: Theme.borders.b1
    property string labelText: ""

    // The map instance used for coordinate conversions. Must be provided by callers.
    property var map: null

    // Input geometry (do not mutate directly; use _tl/_br)
    property geoCoordinate topLeft: QtPositioning.coordinate()
    property geoCoordinate bottomRight: QtPositioning.coordinate()

    signal tapped()
    signal cornersChanged(geoCoordinate topLeft, geoCoordinate bottomRight)

    // Internal working geometry
    property geoCoordinate _tl: QtPositioning.coordinate()
    property geoCoordinate _br: QtPositioning.coordinate()
    property bool isDraggingHandler: false
    readonly property bool isMovingRectangle: moveRect.active
    readonly property bool isBodyPressed: moveRectTap.pressed

    function _syncGeometry() {
        const norm = RectGeom.normalizeCorners(topLeft, bottomRight, QtPositioning)
        _tl = norm.topLeft
        _br = norm.bottomRight
    }

    onTopLeftChanged: _syncGeometry()
    onBottomRightChanged: _syncGeometry()
    Component.onCompleted: {
        _syncGeometry()
        _handles = [topLeftVertex, topRightVertex, bottomRightVertex, bottomLeftVertex]
    }

    MapRectangle {
        id: committedRect
        topLeft: root._tl
        bottomRight: root._br
        color: root.fillColor
        border.color: root.strokeColor
        border.width: 2
        z: root.z

        // Scratch state for drag
        property geoCoordinate _startTLCoord: QtPositioning.coordinate()
        property geoCoordinate _startBRCoord: QtPositioning.coordinate()
        property geoCoordinate _anchorCoord: QtPositioning.coordinate()
        property point _lastScenePos: Qt.point(0, 0)

        function applyMoveDelta() {
            if (!moveRect.active
                    || !_startTLCoord.isValid
                    || !_startBRCoord.isValid
                    || !_anchorCoord.isValid)
                return

            const mapItem = root.map
            if (!mapItem)
                return

            const scenePos = moveRect.centroid.scenePosition
            const pointerPx = mapItem.mapFromItem(null, scenePos.x, scenePos.y)
            const pointerCoord = mapItem.toCoordinate(pointerPx, false)
            if (!pointerCoord.isValid)
                return

            let dLat = pointerCoord.latitude  - _anchorCoord.latitude
            let dLon = pointerCoord.longitude - _anchorCoord.longitude

            if (dLon > 180)
                dLon -= 360
            else if (dLon < -180)
                dLon += 360

            const newTL = QtPositioning.coordinate(
                              RectGeom.clampLat(_startTLCoord.latitude  + dLat),
                              RectGeom.normLon (_startTLCoord.longitude + dLon))
            const newBR = QtPositioning.coordinate(
                              RectGeom.clampLat(_startBRCoord.latitude  + dLat),
                              RectGeom.normLon (_startBRCoord.longitude + dLon))

            const norm = RectGeom.normalizeCorners(newTL, newBR, QtPositioning)
            root._tl = norm.topLeft
            root._br = norm.bottomRight
            root.cornersChanged(root._tl, root._br)
        }

        // Prevent tap propagating below
        TapHandler {
            id: moveRectTap
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        TapHandler {
            enabled: root.tapEnabled
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: root.tapped()
        }

        DragHandler {
            id: moveRect
            target: null
            enabled: root.isEditing && !root.isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                const mapItem = root.map
                if (!mapItem)
                    return

                committedRect._startTLCoord = root._tl
                committedRect._startBRCoord = root._br

                const pressScene = moveRect.centroid.scenePressPosition
                committedRect._lastScenePos = pressScene

                const pressPx = mapItem.mapFromItem(null, pressScene.x, pressScene.y)
                committedRect._anchorCoord = mapItem.toCoordinate(pressPx, false)
            } else {
                committedRect._startTLCoord = QtPositioning.coordinate()
                committedRect._startBRCoord = QtPositioning.coordinate()
                committedRect._anchorCoord = QtPositioning.coordinate()
            }

            onActiveTranslationChanged: {
                const scenePos = centroid.scenePosition
                if (scenePos.x === committedRect._lastScenePos.x &&
                        scenePos.y === committedRect._lastScenePos.y) {
                    return
                }

                committedRect._lastScenePos = scenePos
                committedRect.applyMoveDelta()
            }
        }
    }

    MapRectangle {
        id: highlight
        visible: root.isEditing && root.showHighlight
        topLeft: root._tl
        bottomRight: root._br
        color: "transparent"
        border.color: root.highlightColor
        border.width: committedRect.border.width + 4
        z: committedRect.z - 1
    }

    property var _handles

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
            kind === 0 ? root._tl :
            kind === 1 ? QtPositioning.coordinate(root._tl.latitude, root._br.longitude) :
            kind === 2 ? root._br :
                         QtPositioning.coordinate(root._br.latitude, root._tl.longitude)
        )
        anchorPoint: Qt.point(8, 8)
        sourceItem: Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "white"
            border.color: root.strokeColor
        }
        visible: root.isEditing
        z: committedRect.z + 1

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        DragHandler {
            target: null
            acceptedButtons: Qt.LeftButton
            // Do NOT let this steal the drag from the body
            // and disable it while the body drag is active
            enabled: root.isEditing && !moveRect.active

            onActiveChanged: root.isDraggingHandler = active

            onTranslationChanged: {
                const mapItem = root.map
                if (!mapItem)
                    return

                const p = h.mapToItem(mapItem, centroid.position.x, centroid.position.y)
                const c = mapItem.toCoordinate(p, false)
                if (!c.isValid)
                    return

                const next = RectGeom.applyHandleMove(h.kind, c, root._tl, root._br, QtPositioning)
                root._tl = next.topLeft
                root._br = next.bottomRight
                root.cornersChanged(root._tl, root._br)

                const corners = [
                    { kind: 0, c: root._tl },
                    { kind: 1, c: QtPositioning.coordinate(root._tl.latitude, root._br.longitude) },
                    { kind: 2, c: root._br },
                    { kind: 3, c: QtPositioning.coordinate(root._br.latitude, root._tl.longitude) },
                ]
                let nearest = h.kind
                let best = Infinity
                for (let i = 0; i < corners.length; ++i) {
                    const px = mapItem.fromCoordinate(corners[i].c, false)
                    const dx = px.x - p.x, dy = px.y - p.y
                    const d2 = dx * dx + dy * dy
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

    Rectangle {
        anchors.centerIn: committedRect
        visible: root.showLabel && root.labelText !== ""
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: root.labelFillColor
        border.color: root.labelBorderColor
        border.width: root.isEditing ? root.labelBorderWidth : Theme.borders.b0
        z: committedRect.z + 2

        Text {
            anchors.centerIn: parent
            id: text
            text: root.labelText
            font.pixelSize: Theme.typography.fontSize150
            color: root.labelTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
}
