import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI
import "qrc:/App/Features/MapModes/commands/EllipseCommands.js" as EllipseCommands

UI.EditableEllipse {
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

    // Track drag start state for undo/redo
    property var dragStartCenter: null
    property real dragStartRadiusA: 0
    property real dragStartRadiusB: 0
    property bool wasMovingEllipse: false

    isEditing: MapModeController.alertZone && id === MapModeController.alertZone.id
    map: MapController.map

    center: model.coordinate
    radiusA: model.radiusA
    radiusB: model.radiusB

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

        model.coordinate = c
        MapModeRegistry.editEllipseMode.coordChanged()
        model.radiusA = a
        MapModeRegistry.editEllipseMode.majorAxisChanged()
        model.radiusB = b
        MapModeRegistry.editEllipseMode.minorAxisChanged()
    }

    onIsMovingEllipseChanged: {
        if (isMovingEllipse) {
            wasMovingEllipse = true
        }
    }

    onEditingFinished: {
        console.log("[AlertZoneEllipse] onEditingFinished called, dragStartCenter:", dragStartCenter)
        if (!dragStartCenter) return

        const newCenter = QtPositioning.coordinate(model.coordinate.latitude, model.coordinate.longitude)
        const newRadiusA = model.radiusA
        const newRadiusB = model.radiusB

        console.log("[AlertZoneEllipse] Creating command:",
            "oldCenter:", dragStartCenter.latitude, dragStartCenter.longitude,
            "newCenter:", newCenter.latitude, newCenter.longitude,
            "oldRadiusA:", dragStartRadiusA, "newRadiusA:", newRadiusA,
            "oldRadiusB:", dragStartRadiusB, "newRadiusB:", newRadiusB,
            "wasMoving:", wasMovingEllipse)

        // Determine which command to create based on what operation was performed
        var cmd
        if (wasMovingEllipse) {
            cmd = new EllipseCommands.TranslateEllipseCommand(
                MapModeController.alertZone,
                dragStartCenter,
                dragStartRadiusA,
                dragStartRadiusB,
                newCenter,
                newRadiusA,
                newRadiusB
            )
        } else {
            cmd = new EllipseCommands.UpdateEllipseRadiusCommand(
                MapModeController.alertZone,
                dragStartCenter,
                dragStartRadiusA,
                dragStartRadiusB,
                newCenter,
                newRadiusA,
                newRadiusB
            )
        }

        console.log("[AlertZoneEllipse] Executing command:", cmd.getDescription())
        CommandManager.executeCommand(cmd)

        // Reset tracking state
        dragStartCenter = null
        dragStartRadiusA = 0
        dragStartRadiusB = 0
        wasMovingEllipse = false
    }
}
