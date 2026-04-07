import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Auth 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/EllipseCommands.js" as EllipseCommands

UI.EditableEllipse {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)
    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map

    property var dragStartCenter: null
    property real dragStartRadiusA: 0
    property real dragStartRadiusB: 0
    property bool wasMovingEllipse: false

    center: model.coordinate
    radiusA: model.radiusA
    radiusB: model.radiusB
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

    onEllipseChanged: function(c, a, b) {
        // Capture start state on first change
        if (!dragStartCenter) {
            dragStartCenter = QtPositioning.coordinate(model.coordinate.latitude, model.coordinate.longitude)
            dragStartRadiusA = model.radiusA
            dragStartRadiusB = model.radiusB
            console.log("[AlertZoneEllipse] Captured start state:",
                "center:", dragStartCenter.latitude, dragStartCenter.longitude,
                "radiusA:", dragStartRadiusA, "radiusB:", dragStartRadiusB)
        }

        updateGeometry(c, a, b)

        model.coordinate = c
        model.radiusA = a
        model.radiusB = b

        if (!isMovingEllipse && !isDraggingHandler) {
            MapModeRegistry.editEllipseMode.coordChanged()
            MapModeRegistry.editEllipseMode.majorAxisChanged()
            MapModeRegistry.editEllipseMode.minorAxisChanged()
        }
    }

    onIsMovingEllipseChanged: {
        if (isMovingEllipse) {
            wasMovingEllipse = true
        }
    }

    onEditingFinished: {
        if (!dragStartCenter) return

        const newCenter = QtPositioning.coordinate(model.coordinate.latitude, model.coordinate.longitude)
        const newRadiusA = model.radiusA
        const newRadiusB = model.radiusB

        // Determine which command to create based on what operation was performed
        var cmd
        if (wasMovingEllipse) {
            cmd = new EllipseCommands.TranslateEllipseCommand(
                MapModeController.poi,
                dragStartCenter,
                dragStartRadiusA,
                dragStartRadiusB,
                newCenter,
                newRadiusA,
                newRadiusB
            )
        } else {
            cmd = new EllipseCommands.UpdateEllipseRadiusCommand(
                MapModeController.poi,
                dragStartCenter,
                dragStartRadiusA,
                dragStartRadiusB,
                newCenter,
                newRadiusA,
                newRadiusB
            )
        }

        CommandManager.executeCommand(cmd)

        // Reset tracking state
        dragStartCenter = null
        dragStartRadiusA = 0
        dragStartRadiusB = 0
        wasMovingEllipse = false
    }
}
