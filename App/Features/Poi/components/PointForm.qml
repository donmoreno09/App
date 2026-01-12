import QtQuick 6.8
import QtPositioning 6.8

import App.Components 1.0 as UI
import App.Features.MapModes 1.0

UI.PointFormBase {
    isEditing: MapModeController.isEditing
    modeTarget: MapModeController.activeMode

    readCoord: function() {
        return MapModeController.isEditing
                ? MapModeController.poi.coordinate
                : MapModeRegistry.createPointMode.coord
    }

    writeLatitude: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.coordinate = QtPositioning.coordinate(value, MapModeController.poi.coordinate.longitude)
        else
            MapModeRegistry.createPointMode.coord.latitude = value
    }

    writeLongitude: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.coordinate = QtPositioning.coordinate(MapModeController.poi.coordinate.latitude, value)
        else
            MapModeRegistry.createPointMode.coord.longitude = value
    }
}
