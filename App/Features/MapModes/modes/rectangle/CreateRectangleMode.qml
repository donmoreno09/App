import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0

import "../.."
import "./RectangleGeometry.js" as RectGeom
import App.Components 1.0 as UI

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

    function areValidCoords() {
        return topLeft.isValid && bottomRight.isValid
    }

    function applyNormalized(tl, br) {
        const norm = RectGeom.normalizeCorners(tl, br, QtPositioning)
        topLeft = norm.topLeft
        bottomRight = norm.bottomRight
    }

    function setTopLeft(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? topLeft.latitude  : RectGeom.clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? topLeft.longitude : RectGeom.normLon(Number(lon))
        applyNormalized(QtPositioning.coordinate(lat1, lon1), bottomRight)
    }
    function setBottomRight(lat, lon) {
        const lat1 = (lat === undefined || lat === null) ? bottomRight.latitude  : RectGeom.clampLat(Number(lat))
        const lon1 = (lon === undefined || lon === null) ? bottomRight.longitude : RectGeom.normLon(Number(lon))
        applyNormalized(topLeft, QtPositioning.coordinate(lat1, lon1))
    }

    function setTopLeftLatitude(lat)         { setTopLeft(lat,  undefined) }
    function setTopLeftLongitude(lon)        { setTopLeft(undefined, lon) }
    function setBottomRightLatitude(lat)     { setBottomRight(lat,  undefined) }
    function setBottomRightLongitude(lon)    { setBottomRight(undefined, lon) }

    function normalizeCorners() {
        applyNormalized(topLeft, bottomRight)
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

        const norm = RectGeom.normalizeCorners(c1, c2, QtPositioning)
        topLeft = norm.topLeft
        bottomRight = norm.bottomRight
    }

    // Input handlers
    TapHandler {
        id: tap
        acceptedButtons: Qt.LeftButton
        onPressedChanged: if (!pressed
                && !drag.active
                && !committedRect.isMovingRectangle
                && !committedRect.isDraggingHandler
                && !committedRect.isBodyPressed)
            root.resetPreview()
    }

    DragHandler {
        id: drag
        target: null
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.CrossCursor
        enabled: !committedRect.isDraggingHandler
                 && !committedRect.isMovingRectangle
                 && !committedRect.isBodyPressed

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

    // Committed rectangle with shared editing behavior
    UI.EditableRectangle {
        id: committedRect
        visible: !root.dragging && root.areValidCoords()
        z: root.z + 1

        isEditing: true
        map: MapController.map
        topLeft: root.topLeft
        bottomRight: root.bottomRight

        tapEnabled: false
        showLabel: false
        fillColor: "#22448888"
        strokeColor: "green"
        highlightColor: "white"

        onCornersChanged: function(tl, br) {
            root.applyNormalized(tl, br)
        }
    }
}
