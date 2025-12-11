import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0

UI.EllipseFormBase {
    id: form

    modeTarget: MapModeController.activeMode
    isEditing: MapModeController.isEditing

    validateFn: function() {
        if (MapModeController.isEditing) return true
        return MapModeRegistry.createEllipseMode.coord.isValid &&
                MapModeRegistry.createEllipseMode.radiusA > 0 &&
                MapModeRegistry.createEllipseMode.radiusB > 0
    }

    readCenter: function() {
        return MapModeController.isEditing ? MapModeController.poi.coordinate
                                           : MapModeRegistry.createEllipseMode.coord
    }
    readRadiusA: function() {
        return MapModeController.isEditing ? MapModeController.poi.radiusA
                                           : MapModeRegistry.createEllipseMode.radiusA
    }
    readRadiusB: function() {
        return MapModeController.isEditing ? MapModeController.poi.radiusB
                                           : MapModeRegistry.createEllipseMode.radiusB
    }

    writeCenterLat: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.coordinate = QtPositioning.coordinate(value, MapModeController.poi.coordinate.longitude)
        else
            MapModeRegistry.createEllipseMode.setCenterLatitude(value)
    }
    writeCenterLon: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.coordinate = QtPositioning.coordinate(MapModeController.poi.coordinate.latitude, value)
        else
            MapModeRegistry.createEllipseMode.setCenterLongitude(value)
    }

    writeRadiusA: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.radiusA = Math.max(0, value)
        else
            MapModeRegistry.createEllipseMode.setRadiusA(value)
    }
    writeRadiusB: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.radiusB = Math.max(0, value)
        else
            MapModeRegistry.createEllipseMode.setRadiusB(value)
    }
}
