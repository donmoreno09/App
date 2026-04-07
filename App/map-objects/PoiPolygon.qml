import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Auth 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/PolygonCommands.js" as PolygonCommands

UI.EditablePolygon {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map
    path: coordinates

    property var dragStartPath: null

    fillColor: "#22448888"
    strokeColor: "green"
    highlightColor: "white"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
               && PermissionManager.revision && PermissionManager.hasPermission("poi.read")
    onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    onPathEdited: function(nextPath) {
        // Capture old state on first change
        if (!dragStartPath) {
            dragStartPath = [];
            for (let i = 0; i < coordinates.length; ++i) {
                dragStartPath.push(coordinates[i]);
            }
        }

        for (let j = 0; j < nextPath.length; ++j)
            PoiModel.setCoordinate(modelIndex, j, nextPath[j])

        MapModeRegistry.editPolygonMode.coordinatesChanged()
    }

    onEditingFinished: {
        if (!dragStartPath) return;

        const newPath = [];
        for (let i = 0; i < coordinates.length; ++i) {
            newPath.push(coordinates[i]);
        }

        const cmd = new PolygonCommands.TranslatePolygonCommand(
            PoiModel,
            id,
            dragStartPath,
            newPath
        );

        CommandManager.executeCommand(cmd);
        dragStartPath = null;
    }
}
