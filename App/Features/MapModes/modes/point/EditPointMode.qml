import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

PointMode {
    function buildGeometry() {
        const poi = MapModeController.poi
        if (!poi) return {}

        return {
            shapeTypeId: MapModeController.PointType,
            coordinate: {
                x: poi.coordinate.longitude,
                y: poi.coordinate.latitude,
            },
        }
    }
}
