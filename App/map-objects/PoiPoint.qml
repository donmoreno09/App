import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI

UI.EditablePoint {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)

    isEditing: MapModeController.poi && id === MapModeController.poi.id
    coordinate: model.coordinate
    iconSource: "qrc:/App/assets/icons/poi.svg"

    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))

    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    onPointChanged: function(c) {
        model.coordinate = c
        MapModeRegistry.editPointMode.coordChanged()
    }
}
