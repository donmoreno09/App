// PoiEllipse.qml
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

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map

    center: model.coordinate
    radiusA: model.radiusA
    radiusB: model.radiusB

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

    onEllipseChanged: function(c, a, b) {
        model.coordinate = c
        MapModeRegistry.editEllipseMode.coordChanged()
        model.radiusA = a
        MapModeRegistry.editEllipseMode.majorAxisChanged()
        model.radiusB = b
        MapModeRegistry.editEllipseMode.minorAxisChanged()
    }
}
