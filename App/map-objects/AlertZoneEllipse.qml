import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI

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
        model.coordinate = c
        MapModeRegistry.editEllipseMode.coordChanged()
        model.radiusA = a
        MapModeRegistry.editEllipseMode.majorAxisChanged()
        model.radiusB = b
        MapModeRegistry.editEllipseMode.minorAxisChanged()
    }
}
