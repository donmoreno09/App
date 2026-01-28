import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import "qrc:/App/Features/MapModes/modes/ellipse/EllipseGeometry.js" as EllipseGeom

MapItemGroup {
    id: root
    z: Theme.elevation.z100

    // External bindings
    property bool isEditing: false
    property bool tapEnabled: false
    property bool showHighlight: true
    property bool showLabel: true
    property color fillColor: "#22448888"
    property color fillColorHover: "#22448888"
    property color strokeColor: "green"
    property color highlightColor: "white"
    property real strokeWidth: 2
    property color labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    property color labelBorderColor: Theme.colors.white
    property color labelTextColor: Theme.colors.white
    property real labelBorderWidth: Theme.borders.b1
    property string labelText: ""

    // The map instance used for coordinate conversions. Must be provided by callers.
    property var map: null

    // Geometry
    property geoCoordinate center: QtPositioning.coordinate()
    property real radiusA: 0      // longitude half-axis (E/W)
    property real radiusB: 0      // latitude half-axis (N/S)
    readonly property bool hasEllipse: EllipseGeom.hasEllipse(center, radiusA, radiusB)

    signal tapped()
    signal ellipseChanged(geoCoordinate center, real radiusA, real radiusB)
    signal editingFinished()

    property var _path: []
    function _syncPath() {
        _path = EllipseGeom.ellipsePath(center, radiusA, radiusB, QtPositioning, 96)
    }

    onCenterChanged: _syncPath()
    onRadiusAChanged: _syncPath()
    onRadiusBChanged: _syncPath()
    Component.onCompleted: _syncPath()

    // Scratch state for move drag
    property geoCoordinate _startCenter: QtPositioning.coordinate()
    property geoCoordinate _anchorCoord: QtPositioning.coordinate()
    property point _startCenterPx: Qt.point(0, 0)

    property bool isDraggingHandler: false
    readonly property bool isMovingEllipse: moveDrag.active
    readonly property bool isBodyPressed: moveTap.pressed

    property bool isHovered: false
    property bool hoverEnabled: false
    property bool labelOnHover: false
    property real strokeWidthHover: strokeWidth
    property bool disableHoverStroke: false

    readonly property bool hoverActive: root.isHovered && !root.isEditing
    readonly property bool labelVisible: {
        if (!root.showLabel || !root.hasEllipse || root.labelText === "")
            return false

        if (root.labelOnHover)
            return root.hoverActive

        return true
    }
    readonly property real effectiveStrokeWidth: {
        if (root.disableHoverStroke && !root.isEditing)
            return 0

        if (root.hoverActive && !root.disableHoverStroke)
            return strokeWidthHover

        return strokeWidth
    }

    MapPolygon {
        id: ellipse
        path: root._path
        color: (root.hoverEnabled && root.hoverActive) ? root.fillColorHover : root.fillColor
        border.color: root.strokeColor
        border.width: root.effectiveStrokeWidth
        z: root.z
        visible: root.hasEllipse

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
            enabled: root.isEditing && root.hasEllipse && !root.isDraggingHandler
            acceptedButtons: Qt.LeftButton
            minimumPointCount: 1
            maximumPointCount: 1
            cursorShape: Qt.SizeAllCursor

            onActiveChanged: if (active) {
                const mapItem = root.map
                if (!mapItem)
                    return

                root._startCenter = root.center
                root._anchorCoord = root.center
                root._startCenterPx = mapItem.fromCoordinate(root.center, false)
            } else {
                root._startCenter = QtPositioning.coordinate()
                root._anchorCoord = QtPositioning.coordinate()
                root.editingFinished()
            }

            onActiveTranslationChanged: {
                const mapItem = root.map
                if (!mapItem || !root._anchorCoord.isValid || !root._startCenter.isValid)
                    return

                const p = Qt.point(root._startCenterPx.x + activeTranslation.x,
                                   root._startCenterPx.y + activeTranslation.y)
                const pointerCoord = mapItem.toCoordinate(p, false)
                const newCenter = EllipseGeom.translateCenter(root._startCenter, root._anchorCoord, pointerCoord, QtPositioning)
                if (!newCenter || !newCenter.isValid)
                    return

                root.ellipseChanged(newCenter, root.radiusA, root.radiusB)
            }
        }

        HoverHandler {
            acceptedDevices: PointerDevice.Mouse
            enabled: root.hoverEnabled
            onHoveredChanged: root.isHovered = root.hoverEnabled && hovered
        }
    }

    MapPolygon {
        id: highlight
        path: root._path
        color: "transparent"
        border.color: root.highlightColor
        border.width: ellipse.border.width + 4
        z: ellipse.z - 1
        visible: root.isEditing && root.showHighlight && root.hasEllipse
    }

    component EdgeHandle: MapQuickItem {
        id: h
        required property int kind // 0: N, 1: E, 2: S, 3: W

        coordinate: (
            kind === 0 ? QtPositioning.coordinate(root.center.latitude + root.radiusB, root.center.longitude) :
            kind === 1 ? QtPositioning.coordinate(root.center.latitude, EllipseGeom.normLon(root.center.longitude + root.radiusA)) :
            kind === 2 ? QtPositioning.coordinate(root.center.latitude - root.radiusB, root.center.longitude) :
                         QtPositioning.coordinate(root.center.latitude, EllipseGeom.normLon(root.center.longitude - root.radiusA))
        )

        anchorPoint: Qt.point(8, 8)
        sourceItem: Rectangle { width:16; height:16; radius:8; color:"white"; border.color: root.strokeColor; border.width: 2 }
        visible: root.isEditing && root.hasEllipse
        z: ellipse.z + 1

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds
        }

        DragHandler {
            target: null
            acceptedButtons: Qt.LeftButton
            grabPermissions: PointerHandler.CanTakeOverFromAnything

            onActiveChanged: {
                root.isDraggingHandler = active
                if (!active)
                    root.editingFinished()
            }

            onTranslationChanged: {
                const mapItem = root.map
                if (!mapItem)
                    return

                const p = h.mapToItem(mapItem, centroid.position.x, centroid.position.y)
                const c = mapItem.toCoordinate(p, false)
                if (!c.isValid)
                    return

                const next = EllipseGeom.applyHandleMove(h.kind, c, root.center, root.radiusA, root.radiusB)
                root.ellipseChanged(next.center, next.radiusA, next.radiusB)
            }
        }
    }

    EdgeHandle { id: northHandle; kind: 0 }
    EdgeHandle { id: eastHandle;  kind: 1 }
    EdgeHandle { id: southHandle; kind: 2 }
    EdgeHandle { id: westHandle;  kind: 3 }

    Rectangle {
        anchors.centerIn: ellipse
        width: text.width + Theme.spacing.s3
        height: text.height + Theme.spacing.s1
        radius: Theme.radius.sm
        color: root.labelFillColor
        border.color: root.labelBorderColor
        border.width: root.isEditing ? root.labelBorderWidth : Theme.borders.b0
        z: ellipse.z + 2
        visible: root.labelVisible

        Text {
            id: text
            anchors.centerIn: parent
            text: root.labelText
            font.pixelSize: Theme.typography.fontSize150
            color: root.labelTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
}
