import QtQuick 6.8

import App 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Language 1.0

UI.PolygonFormBase {
    isEditing: MapModeController.isEditing
    modeTarget: MapModeController.activeMode
    requireClosed: true
    emptyMessage: `${TranslationManager.revision}` && qsTr("No coordinates inserted. Click on the map to add points.")

    readCount: function() {
        return MapModeController.isEditing
                ? MapModeController.alertZone.coordinates.length
                : MapModeRegistry.createPolygonMode.coordinatesCount()
    }

    readClosed: function() {
        return MapModeController.isEditing
                ? true
                : MapModeRegistry.createPolygonMode.closed
    }

    readCoord: function(index) {
        if (MapModeController.isEditing)
            return MapModeController.alertZone.coordinates[index]
        return MapModeRegistry.createPolygonMode.getCoordinate(index)
    }

    writeCoordinate: function(index, coord) {
        if (MapModeController.isEditing)
            AlertZoneModel.setCoordinate(MapModeController.alertZone.modelIndex, index, coord)
        else
            MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
    }
}
