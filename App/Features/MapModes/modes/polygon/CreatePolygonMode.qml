import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0

import "../.."
import "./PolygonGeometry.js" as PolyGeom
import App.Components 1.0 as UI
import App.Features.MapModes 1.0 as Commands
import "../../commands/PolygonCommands.js" as PolygonCommands


PolygonMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    ListModel { id: coordinatesModel }
    property bool closed: false
    readonly property bool isDraggingHandle: committedPolygon.isDraggingHandle
    property var polygonPath: []

    function coordinatesCount() {
        return coordinatesModel.count
    }

    function getCoordinate(index) {
        return coordinatesModel.get(index)
    }

    function setCoordinate(index, coord) {
        if (index < 0 || index >= coordinatesModel.count) return

        coordinatesModel.set(index, coord)
        _syncPathFromModel()
    }

    function removeCoordinate(index) {
        if (index < 0 || index >= coordinatesModel.count) return

        coordinatesModel.remove(index)
        _syncPathFromModel()
    }

    function buildGeometry() {
        const coords = PolyGeom.pathToCoordinates(polygonPath)
        if (coords.length < 4) return {}

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: coords
        }
    }

    function resetPreview() {
        coordinatesModel.clear()
        polygonPath = []
        closed = false
        root.coordinatesChanged()
    }

    function _syncPathFromModel() {
        polygonPath = PolyGeom.modelToPath(coordinatesModel, QtPositioning)
    }

    function _addCoordinate(coord) {
        coordinatesModel.append(coord)
        _syncPathFromModel()
    }

    function _tryClose() {
        if (closed || coordinatesModel.count < 3) return

        closed = true
        root.coordinatesChanged()
    }

    TapHandler {
        id: addTap
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        enabled: !committedPolygon.isBodyPressed && !root.isDraggingHandle && !committedPolygon.isMovingPolygon

        onTapped: function(event) {
            console.log("[CreatePolygonMode] Tap detected, closed:", closed, "tapCount:", event.tapCount)

            if (closed) {
                console.log("[CreatePolygonMode] Polygon is closed, resetting...")
                root.resetPreview()
                Commands.CommandManager.clear()
                return // ADD THIS RETURN!
            }

            const point = MapController.map.mapFromItem(root, event.position)
            const coord = MapController.map.toCoordinate(point, false)

            console.log("[CreatePolygonMode] Coordinate:", coord.latitude, coord.longitude)

            if (coord.isValid) {
                console.log("[CreatePolygonMode] Creating AddPolygonVertexCommand...")
                const cmd = new PolygonCommands.AddPolygonVertexCommand(root, coord)
                Commands.CommandManager.executeCommand(cmd)
                console.log("[CreatePolygonMode] Command executed. Stack size:", Commands.CommandManager.commandStack.length)
            }

            if (event.tapCount >= 2) {
                console.log("[CreatePolygonMode] Double-click detected, closing polygon...")
                const closeCmd = new PolygonCommands.ClosePolygonCommand(root)
                Commands.CommandManager.executeCommand(closeCmd)
                console.log("[CreatePolygonMode] Close command executed. Stack size:", Commands.CommandManager.commandStack.length)
            }
        }
    }

    UI.EditablePolygon {
        id: committedPolygon
        visible: root.polygonPath.length > 0
        z: root.z + 1

        isEditing: true
        closed: root.closed
        map: MapController.map
        path: root.polygonPath
        handleModel: coordinatesModel

        tapEnabled: false
        showLabel: false
        fillColor: "#22448888"
        strokeColor: "green"
        highlightColor: "white"
        previewStrokeColor: "orange"

        property var dragStartPath: null

        onPathEdited: function(nextPath) {
            // Capture old state on first change (drag start)
            if (!dragStartPath) {
                dragStartPath = PolyGeom.clonePath(root.polygonPath, QtPositioning)
            }

            // Apply changes directly (immediate feedback)
            PolyGeom.applyPathToModel(coordinatesModel, nextPath, QtPositioning)
            polygonPath = PolyGeom.clonePath(nextPath, QtPositioning)
            root.coordinatesChanged()
        }


        onIsMovingPolygonChanged: {
            if (isMovingPolygon) {
                // Drag started - capture initial state
                dragStartPath = PolyGeom.clonePath(root.polygonPath, QtPositioning)
            } else if (dragStartPath) {
                // Drag ended - commit command
                const cmd = new PolygonCommands.TranslatePolygonCreationCommand(
                    root,
                    dragStartPath,
                    PolyGeom.clonePath(root.polygonPath, QtPositioning)
                )
                Commands.CommandManager.executeCommand(cmd)
                dragStartPath = null
            }
        }

        onFirstPointTapped: {
            const closeCmd = new PolygonCommands.ClosePolygonCommand(root)
            Commands.CommandManager.executeCommand(closeCmd)
        }
    }
}
