import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/PolygonCommands.js" as PolygonCommands

UI.EditablePolygon {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map
    path: coordinates

    fillColor: "#22448888"
    strokeColor: "green"
    highlightColor: "white"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    onPathEdited: function(nextPath) {
        for (let i = 0; i < nextPath.length; ++i)
            PoiModel.setCoordinate(modelIndex, i, nextPath[i])

        MapModeRegistry.editPolygonMode.coordinatesChanged()
    }

    onMidpointDragFinished: function(insertedIndex, originalMidpoint, finalVertex) {
            console.log("[PoiPolygon] Midpoint drag finished at index", insertedIndex)

            const cmd = new PolygonCommands.InsertPolygonVertexCommand(
                MapModeRegistry.editPolygonMode,
                insertedIndex,
                originalMidpoint,
                finalVertex
            )

            CommandManager.commandStack.push(cmd)
            CommandManager.redoStack = []
            CommandManager.canUndoChanged()
            CommandManager.canRedoChanged()
        }
}
