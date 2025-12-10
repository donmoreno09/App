import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Language 1.0

UI.RectangleFormBase {
    id: rectForm

    modeTarget: MapModeController.activeMode
    isEditing: MapModeController.isEditing

    topLeftLatLabel: `${TranslationManager.revision}` && qsTr("Top Left Latitude(*)")
    topLeftLonLabel: `${TranslationManager.revision}` && qsTr("Top Left Longitude(*)")
    bottomRightLatLabel: `${TranslationManager.revision}` && qsTr("Bottom Right Latitude(*)")
    bottomRightLonLabel: `${TranslationManager.revision}` && qsTr("Bottom Right Longitude(*)")

    validateFn: function() {
        if (MapModeController.isEditing) return true
        return MapModeRegistry.createRectangleMode.topLeft.isValid &&
               MapModeRegistry.createRectangleMode.bottomRight.isValid
    }

    readTopLeft: function() {
        return MapModeController.isEditing ? MapModeController.alertZone.topLeft
                                           : MapModeRegistry.createRectangleMode.topLeft
    }
    readBottomRight: function() {
        return MapModeController.isEditing ? MapModeController.alertZone.bottomRight
                                           : MapModeRegistry.createRectangleMode.bottomRight
    }

    writeTopLeftLat: function(value) {
        if (MapModeController.isEditing)
            MapModeController.alertZone.topLeft = QtPositioning.coordinate(value, MapModeController.alertZone.topLeft.longitude)
        else
            MapModeRegistry.createRectangleMode.setTopLeftLatitude(value)
    }
    writeTopLeftLon: function(value) {
        if (MapModeController.isEditing)
            MapModeController.alertZone.topLeft = QtPositioning.coordinate(MapModeController.alertZone.topLeft.latitude, value)
        else
            MapModeRegistry.createRectangleMode.setTopLeftLongitude(value)
    }

    writeBottomRightLat: function(value) {
        if (MapModeController.isEditing)
            MapModeController.alertZone.bottomRight = QtPositioning.coordinate(value, MapModeController.alertZone.bottomRight.longitude)
        else
            MapModeRegistry.createRectangleMode.setBottomRightLatitude(value)
    }
    writeBottomRightLon: function(value) {
        if (MapModeController.isEditing)
            MapModeController.alertZone.bottomRight = QtPositioning.coordinate(MapModeController.alertZone.bottomRight.latitude, value)
        else
            MapModeRegistry.createRectangleMode.setBottomRightLongitude(value)
    }
}
