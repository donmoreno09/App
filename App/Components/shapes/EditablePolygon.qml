import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import "qrc:/App/Features/MapModes/modes/polygon/PolygonGeometry.js" as PolyGeom

MapItemGroup {
    id: root
    z: Theme.elevation.z100

    // External bindings
    property bool isEditing: false
    property bool tapEnabled: false
    property bool showHighlight: true
    property bool showLabel: true
    property bool closed: true
    property color fillColor: "#22448888"
    property color strokeColor: "green"
    property color highlightColor: "white"
    property real strokeWidth: 2
    property color labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    property color labelBorderColor: Theme.colors.white
    property color labelTextColor: Theme.colors.white
    property real labelBorderWidth: Theme.borders.b1
    property string labelText: ""
    property color previewStrokeColor: "orange"
    property real previewStrokeWidth: 2

    // The map instance used for coordinate conversions. Must be provided by callers.
    property var map: null
    property var handleModel: null // used for when creating adding points; might be used later in the future when editing a polygon then supports adding a point

    // Geometry
    property var path: []
    readonly property bool hasPolygon: PolyGeom.hasPolygon(_path) && closed
    readonly property bool hasPath: _path.length > 0

    signal tapped()
    signal pathEdited(var path)
    signal firstPointTapped()

    property bool isDraggingHandle: false
    readonly property bool isMovingPolygon: moveDrag.active
    readonly property bool isBodyPressed: moveTap.pressed

    property var _path: []
    property var _startCoords: []
    property geoCoordinate _anchorCoord: QtPositioning.coordinate()
    property point _lastScenePos: Qt.point(0, 0)

    function _syncPath() {
        _path = PolyGeom.clonePath(path, QtPositioning)
    }

    onPathChanged: _syncPath()
    Component.onCompleted: _syncPath()

    MapPolyline {
        id: preview
        visible: root.isEditing && !root.closed && root.hasPath
        line.width: root.previewStrokeWidth
        line.color: root.previewStrokeColor
        z: root.z + 1
        path: root._path
    }

    MapPolygon {
        id: polygon
        visible: root.closed && root.hasPath
        path: root._path
        color: root.fillColor
        border.color: root.strokeColor
        border.width: root.strokeWidth
        z: root.z

        // Prevent tap propagating below
        TapHandler {
            id: moveTap
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        TapHandler {
            enabled: root.tapEnabled
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: root.tapped()
        }

        DragHandler {
            id: moveDrag
            target: null
            enabled: root.isEditing && root.closed && root.hasPolygon && !root.isDraggingHandle
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                const mapItem = root.map
                if (!mapItem)
                    return

                // snapshot the starting geometry
                root._startCoords = PolyGeom.clonePath(root._path, QtPositioning)

                // pointer position at press time, in scene coords
                const pressScene = moveDrag.centroid.scenePressPosition
                root._lastScenePos = pressScene

                // convert that scene position into a geo “anchor” coordinate
                const pressPx = mapItem.mapFromItem(null, pressScene.x, pressScene.y)
                root._anchorCoord = mapItem.toCoordinate(pressPx, false)
            } else {
                root._startCoords = []
                root._anchorCoord = QtPositioning.coordinate()
                root._lastScenePos = Qt.point(0, 0)
            }

            onActiveTranslationChanged: {
                const mapItem = root.map
                if (!mapItem || !root._anchorCoord.isValid ||
                        !root._startCoords || root._startCoords.length === 0)
                    return

                const scenePos = centroid.scenePosition
                if (scenePos.x === root._lastScenePos.x &&
                        scenePos.y === root._lastScenePos.y)
                    return
                root._lastScenePos = scenePos

                // current pointer geo coordinate
                const pointerPx = mapItem.mapFromItem(null, scenePos.x, scenePos.y)
                const pointerCoord = mapItem.toCoordinate(pointerPx, false)
                if (!pointerCoord.isValid)
                    return

                // geo delta (similar to the rectangle)
                let dLat = pointerCoord.latitude  - root._anchorCoord.latitude
                let dLon = pointerCoord.longitude - root._anchorCoord.longitude

                // dateline wrapping
                if (dLon > 180)
                    dLon -= 360
                else if (dLon < -180)
                    dLon += 360

                const next = []
                for (let i = 0; i < root._startCoords.length; ++i) {
                    const c = root._startCoords[i]
                    if (!c || !c.isValid)
                        continue

                    const newLat = PolyGeom.clampLat(c.latitude + dLat)
                    const newLon = PolyGeom.normLon(c.longitude + dLon)
                    next.push(QtPositioning.coordinate(newLat, newLon))
                }

                if (next.length === 0)
                    return

                root._path = next
                root.pathEdited(PolyGeom.clonePath(next, QtPositioning))
            }
        }
    }

    // subtle white halo behind committed border
    MapPolygon {
        visible: polygon.visible && root.isEditing && root.showHighlight
        path: polygon.path
        color: "transparent"
        border.color: root.highlightColor
        border.width: polygon.border.width + 4
        z: polygon.z - 1
    }

    MapItemView {
        z: (root.closed ? polygon.z : preview.z) + 1
        model: root.handleModel !== null ? root.handleModel : root._path.length

        delegate: MapQuickItem {
            id: handle

            required property int index

            property geoCoordinate _coordinate: (
                root._path.length > index
                        && root._path[index]
                        && root._path[index].isValid
            ) ? root._path[index] : QtPositioning.coordinate()

            coordinate: _coordinate
            anchorPoint: Qt.point(8, 8)
            sourceItem: Rectangle {
                width: 16
                height: 16
                radius: 8
                color: "white"
                border.color: root.strokeColor
                border.width: 2
            }
            visible: root.isEditing && root.hasPath
            z: polygon.z + 1

            TapHandler {
                acceptedButtons: Qt.LeftButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: {
                    if (!root.closed && handle.index === 0 && root._path.length >= 3)
                        root.firstPointTapped()
                }
            }

            DragHandler {
                target: null
                acceptedButtons: Qt.LeftButton
                grabPermissions: PointerHandler.CanTakeOverFromAnything

                onTranslationChanged: {
                    if (!root.map)
                        return

                    const p = handle.mapToItem(root.map, centroid.position.x, centroid.position.y)
                    const c = root.map.toCoordinate(p, false)
                    if (!c.isValid)
                        return

                    const next = PolyGeom.clonePath(root._path, QtPositioning)
                    next[handle.index] = c
                    root._path = next
                    root.pathEdited(next)
                }

                onActiveChanged: root.isDraggingHandle = active
            }
        }
    }

    Rectangle {
        anchors.centerIn: polygon
        visible: root.showLabel && root.hasPolygon && root.labelText !== ""
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: root.labelFillColor
        border.color: root.labelBorderColor
        border.width: root.isEditing ? root.labelBorderWidth : Theme.borders.b0
        z: polygon.z + 2

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
