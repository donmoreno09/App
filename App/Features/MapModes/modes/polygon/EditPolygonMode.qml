import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import "../.."
import "./PolygonGeometry.js" as PolyGeom

PolygonMode {
    id: root

    function buildGeometry() {
        const entity = MapModeController.poi || MapModeController.alertZone
        if (!entity) { return {} }

        const coords = PolyGeom.pathToCoordinates(entity.coordinates)
        if (coords.length < 4) { return {} }

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: coords
        }
    }

    function coordinatesCount() {
            const entity = MapModeController.poi || MapModeController.alertZone
            return entity ? entity.coordinates.length : 0
        }

    function removeCoordinate(index) {
        const entity = MapModeController.poi || MapModeController.alertZone
        if (!entity) return

        const modelIndex = entity.modelIndex

        if (MapModeController.poi) {
            PoiModel.removeCoordinate(modelIndex, index)
        } else if (MapModeController.alertZone) {
            AlertZoneModel.removeCoordinate(modelIndex, index)
        }
    }
}
