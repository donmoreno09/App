import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

RectangleMode {
    id: root

    function buildGeometry() {
        const entity = MapModeController.poi || MapModeController.alertZone
        if (!entity) return {}

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: root.rectToPoints({
                topLeft: entity.topLeft,
                bottomRight: entity.bottomRight
            }),
        }
    }
}
