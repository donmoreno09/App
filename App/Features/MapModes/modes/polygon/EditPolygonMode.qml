import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Features.MapModes 1.0

PolygonMode {
    id: root

    function buildGeometry() {
        console.log("[STEP 5a-EditMode] EditPolygonMode.buildGeometry called")

        // Support both PoI and AlertZone
        const entity = MapModeController.poi || MapModeController.alertZone
        if (!entity) {
            console.log("[STEP 5a-EditMode] No entity (poi or alertZone) found")
            return {}
        }

        console.log("[STEP 5a-EditMode] Entity found, reading coordinates")
        const coordinates = entity.coordinates
        if (coordinates.length < 3) {
            console.log("[STEP 5a-EditMode] Not enough coordinates:", coordinates.length)
            return {}
        }

        console.log("[STEP 5a-EditMode] Building geometry from", coordinates.length, "coordinates")
        const out = []
        for (let i = 0; i < coordinates.length; i++) {
            const coord = coordinates[i]
            out.push({ x: coord.longitude, y: coord.latitude })
        }
        out.push({ x: out[0].x, y: out[0].y })

        console.log("[STEP 5a-EditMode] Geometry built with", out.length, "coordinates (including closing point)")
        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: out
        }
    }
}
