import QtQuick 6.8

import App 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0

UI.PolygonFormBase {
    isEditing: MapModeController.isEditing
    modeTarget: MapModeController.activeMode
    emptyMessage: qsTr("No coordinates inserted. Start by clicking anywhere on the map to insert the first coordinate.")

    readCount: function() {
        return MapModeController.isEditing
                ? MapModeController.poi.coordinates.length
                : MapModeRegistry.createPolygonMode.coordinatesCount()
    }

    readCoord: function(index) {
        if (MapModeController.isEditing)
            return MapModeController.poi.coordinates[index]
        return MapModeRegistry.createPolygonMode.getCoordinate(index)
    }

    writeCoordinate: function(index, coord) {
        if (MapModeController.isEditing)
            PoiModel.setCoordinate(MapModeController.poi.modelIndex, index, coord)
        else
            MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
    }
}
