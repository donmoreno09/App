import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.MapModes 1.0
import App.Features.MapModes 1.0 as Commands
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/PointCommands.js" as PointCommands

UI.EditablePoint {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    coordinate: model.coordinate
    iconSource: "qrc:/App/assets/icons/poi.svg"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    // Track drag start state for undo/redo
    property var dragStartCoord: null

    onIsDraggingChanged: {
        if (!isEditing) return

        if (isDragging) {
            // Capture start state when drag begins
            if (model.coordinate.isValid) {
                dragStartCoord = QtPositioning.coordinate(
                    model.coordinate.latitude,
                    model.coordinate.longitude
                )
                console.log("[PoiPoint] Drag started, captured coord:",
                    dragStartCoord.latitude, dragStartCoord.longitude)
            }
        } else {
            // Drag ended, create command if we have start state
            if (dragStartCoord && model.coordinate.isValid) {
                const newCoord = QtPositioning.coordinate(
                    model.coordinate.latitude,
                    model.coordinate.longitude
                )

                console.log("[PoiPoint] Drag ended, creating command:",
                    "old:", dragStartCoord.latitude, dragStartCoord.longitude,
                    "new:", newCoord.latitude, newCoord.longitude)

                const cmd = new PointCommands.TranslatePointCommand(
                    MapModeController.poi,
                    dragStartCoord,
                    newCoord
                )
                Commands.CommandManager.executeCommand(cmd)

                dragStartCoord = null
            }
        }
    }

    onPointChanged: function(c) {
        model.coordinate = c
        MapModeRegistry.editPointMode.coordChanged()
    }
}
