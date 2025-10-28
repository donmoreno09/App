import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

EllipseMode {
    id: root

    function buildGeometry() {
        const poi = MapModeController.poi
        if (!poi) return {}

        return {
            shapeTypeId: MapModeController.EllipseType,
            coordinate: { x: poi.coordinate.longitude, y: poi.coordinate.latitude },
            radiusA: poi.radiusA,
            radiusB: poi.radiusB,
        }
    }
}
