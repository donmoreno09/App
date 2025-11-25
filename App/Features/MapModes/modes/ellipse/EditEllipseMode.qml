import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

EllipseMode {
    id: root

    function buildGeometry() {
        const entity = MapModeController.poi || MapModeController.alertZone
        if (!entity) return {}

        return {
            shapeTypeId: MapModeController.EllipseType,
            coordinate: { x: entity.coordinate.longitude, y: entity.coordinate.latitude },
            radiusA: entity.radiusA,
            radiusB: entity.radiusB,
        }
    }
}
