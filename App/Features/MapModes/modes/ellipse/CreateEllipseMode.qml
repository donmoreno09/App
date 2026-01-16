import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0

import "../.."
import "./EllipseGeometry.js" as EllipseGeom
import App.Components 1.0 as UI
import App.Features.MapModes 1.0 as Commands
import "../../commands/EllipseCommands.js" as EllipseCommands

EllipseMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    // Ellipse parameters (center + half-axes in degrees)
    property geoCoordinate coord: QtPositioning.coordinate()
    property real radiusA: 0      // longitude half-axis (E/W), shortest wrap
    property real radiusB: 0      // latitude half-axis (N/S)
    readonly property bool hasEllipse: EllipseGeom.hasEllipse(coord, radiusA, radiusB)

    // Listen to map events while drawing
    Connections {
        target: MapController.map

        function onBearingChanged() {
            // Keep the preview ellipse anchored when the map rotates mid-drag
            updatePreviewEllipse()
        }

        function onTiltChanged() {
            // Keep the preview ellipse anchored when the map tilts mid-drag
            updatePreviewEllipse()
        }
    }

    // Input state
    property bool  dragging: drag.active
    property point dragStart: drag.centroid.pressPosition
    property point dragEnd: drag.centroid.position
    property geoCoordinate dragStartCoord: QtPositioning.coordinate()

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
        root.coordChanged()
        radiusA = 0
        root.majorAxisChanged()
        radiusB = 0
        root.minorAxisChanged()
        dragStartCoord = QtPositioning.coordinate()
    }

    function setCenter(lat, lon) {
        const la = (lat === undefined || lat === null) ? coord.latitude  : EllipseGeom.clampLat(Number(lat))
        const lo = (lon === undefined || lon === null) ? coord.longitude : EllipseGeom.normLon(Number(lon))
        coord = QtPositioning.coordinate(la, lo)
        root.coordChanged()
    }

    function setCenterLatitude(lat)  { setCenter(lat, undefined) }
    function setCenterLongitude(lon) { setCenter(undefined, lon) }

    function setRadii(a, b) {
        if (a !== undefined && a !== null) {
            const nextA = Math.max(0, Number(a))
            if (nextA !== radiusA) {
                radiusA = nextA
                root.majorAxisChanged()
            }
        }
        if (b !== undefined && b !== null) {
            const nextB = Math.max(0, Number(b))
            if (nextB !== radiusB) {
                radiusB = nextB
                root.minorAxisChanged()
            }
        }
    }

    function setRadiusA(a) { setRadii(a, undefined) }
    function setRadiusB(b) { setRadii(undefined, b) }

    function updatePreviewEllipse() {
        if (!drag.active) return

        // Keep anchor stable when map rotates/tilts mid-drag.
        let c1 = dragStartCoord
        if (!c1.isValid) {
            const p1 = MapController.map.mapFromItem(root, dragStart.x, dragStart.y)
            c1 = MapController.map.toCoordinate(p1, false)
        }

        const p2 = MapController.map.mapFromItem(root, dragEnd.x, dragEnd.y)
        const c2 = MapController.map.toCoordinate(p2, false)
        if (!c1.isValid || !c2.isValid) return

        const ellipse = EllipseGeom.bboxToEllipse(c1, c2, QtPositioning)
        if (!ellipse) return

        coord = ellipse.center
        root.coordChanged()

        if (radiusA !== ellipse.radiusA) {
            radiusA = ellipse.radiusA
            root.majorAxisChanged()
        }
        if (radiusB !== ellipse.radiusB) {
            radiusB = ellipse.radiusB
            root.minorAxisChanged()
        }
    }

    // ----- Input: click to clear if not dragging/moving -----
    TapHandler {
        id: tap
        acceptedButtons: Qt.LeftButton
        onPressedChanged: if (!pressed
                && !drag.active
                && !committedEllipse.isMovingEllipse
                && !committedEllipse.isDraggingHandler
                && !committedEllipse.isBodyPressed)
            root.resetPreview()
    }

    // ----- Initial draw by dragging a bbox -----
    DragHandler {
        id: drag
        target: null
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.CrossCursor
        enabled: !committedEllipse.isDraggingHandler
                 && !committedEllipse.isMovingEllipse
                 && !committedEllipse.isBodyPressed

        onActiveChanged: if (active) {
            const p = MapController.map.mapFromItem(root, dragStart.x, dragStart.y)
            dragStartCoord = MapController.map.toCoordinate(p, false)
        } else {
            dragStartCoord = QtPositioning.coordinate()
        }

        onTranslationChanged: {
            updatePreviewEllipse()
        }
    }

    // ----- Preview while dragging -----
    MapPolygon {
        visible: root.dragging
        path: EllipseGeom.ellipsePath(root.coord, root.radiusA, root.radiusB, QtPositioning, 96)
        color: "#3388cc88"
        border.color: "orange"
        border.width: 2
        z: root.z + 1
    }

    // ----- Committed ellipse -----
    UI.EditableEllipse {
        id: committedEllipse
        visible: !root.dragging && root.hasEllipse
        z: root.z + 1

        isEditing: true
        map: MapController.map
        center: root.coord
        radiusA: root.radiusA
        radiusB: root.radiusB

        tapEnabled: false
        showLabel: false
        fillColor: "#22448888"
        strokeColor: "green"
        highlightColor: "white"

        // Track drag start state for undo/redo
        property var dragStartCenter: null
        property real dragStartRadiusA: 0
        property real dragStartRadiusB: 0

        onEllipseChanged: function(c, a, b) {
            console.log("[CreateEllipseMode] onEllipseChanged called, dragStartCenter already set:", dragStartCenter !== null)

            // Capture start state on first change
            if (!dragStartCenter) {
                console.log("[CreateEllipseMode] CAPTURING - current root.coord:", root.coord.latitude, root.coord.longitude)
                console.log("[CreateEllipseMode] CAPTURING - current root.radiusA:", root.radiusA, "radiusB:", root.radiusB)
                console.log("[CreateEllipseMode] CAPTURING - incoming c:", c.latitude, c.longitude, "a:", a, "b:", b)

                dragStartCenter = QtPositioning.coordinate(root.coord.latitude, root.coord.longitude)
                dragStartRadiusA = root.radiusA
                dragStartRadiusB = root.radiusB
                console.log("[CreateEllipseMode] Captured start state:",
                    "center:", dragStartCenter.latitude, dragStartCenter.longitude,
                    "radiusA:", dragStartRadiusA, "radiusB:", dragStartRadiusB)
            }

            // Update root's properties (not the local bound properties)
            root.coord = c
            root.coordChanged()

            if (root.radiusA !== a) {
                root.radiusA = a
                root.majorAxisChanged()
            }
            if (root.radiusB !== b) {
                root.radiusB = b
                root.minorAxisChanged()
            }
        }

        onEditingFinished: {
            console.log("[CreateEllipseMode] onEditingFinished, dragStartCenter:", dragStartCenter)
            if (!dragStartCenter) return

            const newCenter = QtPositioning.coordinate(root.coord.latitude, root.coord.longitude)
            const newRadiusA = root.radiusA
            const newRadiusB = root.radiusB

            console.log("[CreateEllipseMode] Creating command:",
                "oldCenter:", dragStartCenter.latitude, dragStartCenter.longitude,
                "newCenter:", newCenter.latitude, newCenter.longitude,
                "oldRadiusA:", dragStartRadiusA, "newRadiusA:", newRadiusA,
                "oldRadiusB:", dragStartRadiusB, "newRadiusB:", newRadiusB)

            const cmd = new EllipseCommands.TranslateEllipseCreationCommand(
                root,
                dragStartCenter,
                dragStartRadiusA,
                dragStartRadiusB,
                newCenter,
                newRadiusA,
                newRadiusB
            )

            Commands.CommandManager.executeCommand(cmd)

            // Reset tracking state
            dragStartCenter = null
            dragStartRadiusA = 0
            dragStartRadiusB = 0
        }
    }

    // subtle white halo behind committed border
}
