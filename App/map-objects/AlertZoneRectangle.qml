import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI

UI.EditableRectangle {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.alertZone && id === MapModeController.alertZone.id
    map: MapController.map

    readonly property color zoneColor: {
        console.log("AlertZone", label, "active:", active, "severity:", severity)
        if (!active) return "#888888"
        switch (severity) {
        case 2: return "#FF0000"
        case 1: return "#FF6600"
        case 0:
        default: return "#FFCC00"
        }
    }

    topLeft: model.topLeft
    bottomRight: model.bottomRight

    fillColor: Qt.rgba(zoneColor.r, zoneColor.g, zoneColor.b, 0.13)
    strokeColor: zoneColor
    highlightColor: "white"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editAlertZone(AlertZoneModel.getEditableAlertZone(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha(zoneColor, 0.8)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    onCornersChanged: function(tl, br) {
        model.topLeft = tl
        MapModeRegistry.editRectangleMode.topLeftChanged()
        model.bottomRight = br
        MapModeRegistry.editRectangleMode.bottomRightChanged()
    }
}
