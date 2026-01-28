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

    readonly property color zoneColor: {
        if (!active) return Theme.colors.alertZoneDisabled
        switch(severity) {
        case 2: return Theme.colors.alertZoneHigh
        case 1: return Theme.colors.alertZoneMedium
        case 0:
        default: return Theme.colors.alertZoneLow
        }
    }

    readonly property color zoneColorHover: {
        if (!active) return Theme.colors.alertZoneDisabledHover
        switch(severity) {
        case 2: return Theme.colors.alertZoneHighHover
        case 1: return Theme.colors.alertZoneMediumHover
        case 0:
        default: return Theme.colors.alertZoneLowHover
        }
    }

    property var dragStartPath: null

    isEditing: MapModeController.alertZone && id === MapModeController.alertZone.id
    map: MapController.map
    path: coordinates

    fillColor: root.zoneColor
    labelOnHover: true
    hoverEnabled: true
    disableHoverStroke: true
    fillColorHover: root.zoneColorHover
    strokeColor: root.zoneColorHover
    highlightColor: "white"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editAlertZone(AlertZoneModel.getEditableAlertZone(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha(root.zoneColorHover, 0.8)
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

        // Apply changes directly (immediate feedback)
        for (let i = 0; i < nextPath.length; ++i)
            AlertZoneModel.setCoordinate(modelIndex, i, nextPath[i])

        MapModeRegistry.editPolygonMode.coordinatesChanged()
    }

    // Commit command when editing ends
    Connections {
        target: root

        function onEditingFinished() {
            if (!dragStartPath) return;

            const newPath = [];
            for (let i = 0; i < coordinates.length; ++i) {
                newPath.push(coordinates[i]);
            }

            const cmd = new PolygonCommands.TranslatePolygonCommand(
                AlertZoneModel,
                id,
                dragStartPath,
                newPath
            );

            CommandManager.executeCommand(cmd);
            dragStartPath = null;
        }
    }
}
