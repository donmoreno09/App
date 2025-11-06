import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

RectangleMode {
    id: root

    function buildGeometry() {
        const poi = MapModeController.poi
        if (!poi) return {}

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: root.rectToPoints({
                topLeft: poi.topLeft,
                bottomRight: poi.bottomRight
            }),
        }
    }
}
