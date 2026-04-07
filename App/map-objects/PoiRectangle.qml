import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Auth 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/RectangleCommands.js" as RectangleCommands

UI.EditableRectangle {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map

    // Track drag start state for undo/redo
    property var dragStartTopLeft: null
    property var dragStartBottomRight: null
    property bool wasMovingRectangle: false

    topLeft: model.topLeft
    bottomRight: model.bottomRight

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
                MapModeController.poi,
                dragStartTopLeft,
                dragStartBottomRight,
                newTopLeft,
                newBottomRight
            )
        } else {
            cmd = new RectangleCommands.UpdateRectangleCornerCommand(
                MapModeController.poi,
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
