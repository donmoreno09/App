import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0

UI.RectangleFormBase {
    id: rectForm

    modeTarget: MapModeController.activeMode
    isEditing: MapModeController.isEditing

    topLeftLatLabel: qsTr("Top Left Latitude(*)")
    topLeftLonLabel: qsTr("Top Left Longitude(*)")
    bottomRightLatLabel: qsTr("Bottom Right Latitude(*)")
    bottomRightLonLabel: qsTr("Bottom Right Longitude(*)")

    validateFn: function() {
        if (MapModeController.isEditing) return true
        return MapModeRegistry.createRectangleMode.topLeft.isValid &&
               MapModeRegistry.createRectangleMode.bottomRight.isValid
    }

    readTopLeft: function() {
        return MapModeController.isEditing ? MapModeController.poi.topLeft
                                           : MapModeRegistry.createRectangleMode.topLeft
    }
    readBottomRight: function() {
        return MapModeController.isEditing ? MapModeController.poi.bottomRight
                                           : MapModeRegistry.createRectangleMode.bottomRight
    }

    writeTopLeftLat: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.topLeft = QtPositioning.coordinate(value, MapModeController.poi.topLeft.longitude)
        else
            MapModeRegistry.createRectangleMode.setTopLeftLatitude(value)
    }
    writeTopLeftLon: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.topLeft = QtPositioning.coordinate(MapModeController.poi.topLeft.latitude, value)
        else
            MapModeRegistry.createRectangleMode.setTopLeftLongitude(value)
    }

    writeBottomRightLat: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.bottomRight = QtPositioning.coordinate(value, MapModeController.poi.bottomRight.longitude)
        else
            MapModeRegistry.createRectangleMode.setBottomRightLatitude(value)
    }
    writeBottomRightLon: function(value) {
        if (MapModeController.isEditing)
            MapModeController.poi.bottomRight = QtPositioning.coordinate(MapModeController.poi.bottomRight.latitude, value)
        else
            MapModeRegistry.createRectangleMode.setBottomRightLongitude(value)
    }
}
