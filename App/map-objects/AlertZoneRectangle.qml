import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/RectangleCommands.js" as RectangleCommands

UI.EditableRectangle {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.alertZone && id === MapModeController.alertZone.id
    map: MapController.map

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

    // Track drag start state for undo/redo
    property var dragStartTopLeft: null
    property var dragStartBottomRight: null
    property bool wasMovingRectangle: false

    topLeft: model.topLeft
    bottomRight: model.bottomRight

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

    onCornersChanged: function(tl, br) {
        // Capture start state on first change
        if (!dragStartTopLeft) {
            dragStartTopLeft = QtPositioning.coordinate(model.topLeft.latitude, model.topLeft.longitude)
            dragStartBottomRight = QtPositioning.coordinate(model.bottomRight.latitude, model.bottomRight.longitude)
        }

        model.topLeft = tl
        MapModeRegistry.editRectangleMode.topLeftChanged()
        model.bottomRight = br
        MapModeRegistry.editRectangleMode.bottomRightChanged()
    }

    onIsMovingRectangleChanged: {
        if (isMovingRectangle) {
            wasMovingRectangle = true
        }
    }

    onEditingFinished: {
        if (!dragStartTopLeft) return

        const newTopLeft = QtPositioning.coordinate(model.topLeft.latitude, model.topLeft.longitude)
        const newBottomRight = QtPositioning.coordinate(model.bottomRight.latitude, model.bottomRight.longitude)

        // Determine which command to create based on what operation was performed
        var cmd
        if (wasMovingRectangle) {
            cmd = new RectangleCommands.TranslateRectangleCommand(
                MapModeController.alertZone,
                dragStartTopLeft,
                dragStartBottomRight,
                newTopLeft,
                newBottomRight
            )
        } else {
            cmd = new RectangleCommands.UpdateRectangleCornerCommand(
                MapModeController.alertZone,
                dragStartTopLeft,
                dragStartBottomRight,
                newTopLeft,
                newBottomRight
            )
        }

        CommandManager.executeCommand(cmd)

        // Reset tracking state
        dragStartTopLeft = null
        dragStartBottomRight = null
        wasMovingRectangle = false
    }
}
