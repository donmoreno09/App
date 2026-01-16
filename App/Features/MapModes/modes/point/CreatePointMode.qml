import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0

import "../.."
import App.Components 1.0 as UI
import App.Features.MapModes 1.0 as Commands
import "../../commands/PointCommands.js" as PointCommands

PointMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    // Properties
    property geoCoordinate coord: QtPositioning.coordinate()

    // Track drag start state for undo/redo
    property var dragStartCoord: null

    function buildGeometry() {
        return {
            shapeTypeId: MapModeController.PointType,
            coordinate: { x: coord.longitude, y: coord.latitude },
        }
    }

    function resetPreview() {
        coord = QtPositioning.coordinate()
        dragStartCoord = null
    }

    // ----- API for commands -----
    function setCoordinate(lat, lon) {
        coord = QtPositioning.coordinate(lat, lon)
        root.coordChanged()
    }

    // Input handlers
    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        enabled: !mapPoint.isDragging

        onTapped: function (event) {
            const point = map.mapFromItem(root, event.position)
            const newCoord = map.toCoordinate(point, false)

            // Capture old state before change
            const oldCoord = coord.isValid
                ? QtPositioning.coordinate(coord.latitude, coord.longitude)
                : QtPositioning.coordinate()

            // Apply change
            coord = newCoord

            // Create and execute command
            const cmd = new PointCommands.SetPointCoordinateCommand(
                root,
                oldCoord,
                QtPositioning.coordinate(newCoord.latitude, newCoord.longitude)
            )
            Commands.CommandManager.executeCommand(cmd)
        }
    }

    UI.EditablePoint {
        id: mapPoint
        coordinate: coord
        z: root.z + 1

        isEditing: true
        tapEnabled: false
        showLabel: false
        highlightOnEditing: false

        onIsDraggingChanged: {
            if (isDragging) {
                // Capture start state when drag begins
                if (coord.isValid) {
                    root.dragStartCoord = QtPositioning.coordinate(coord.latitude, coord.longitude)
                    console.log("[CreatePointMode] Drag started, captured coord:",
                        root.dragStartCoord.latitude, root.dragStartCoord.longitude)
                }
            } else {
                // Drag ended, create command if we have start state
                if (root.dragStartCoord && coord.isValid) {
                    const newCoord = QtPositioning.coordinate(coord.latitude, coord.longitude)

                    console.log("[CreatePointMode] Drag ended, creating command:",
                        "old:", root.dragStartCoord.latitude, root.dragStartCoord.longitude,
                        "new:", newCoord.latitude, newCoord.longitude)

                    const cmd = new PointCommands.SetPointCoordinateCommand(
                        root,
                        root.dragStartCoord,
                        newCoord
                    )
                    Commands.CommandManager.executeCommand(cmd)

                    root.dragStartCoord = null
                }
            }
        }

        onPointChanged: function(c) {
            coord = c
        }
    }
}
