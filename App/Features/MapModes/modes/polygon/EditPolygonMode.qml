import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

PolygonMode {
    id: root

    function buildGeometry() {
        const poi = MapModeController.poi
        if (!poi) return {}

        const coordinates = poi.coordinates
        if (coordinates.length < 3) return {}

        const out = []
        for (let i = 0; i < coordinates.length; i++) {
            const coord = coordinates[i]
            out.push({ x: coord.longitude, y: coord.latitude })
        }
        out.push({ x: out[0].x, y: out[0].y })

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: out
        }
    }
}
