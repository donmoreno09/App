import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0

import "../.."
import App.Components 1.0 as UI

PointMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    // Properties
    property geoCoordinate coord: QtPositioning.coordinate()

    function buildGeometry() {
        return {
            shapeTypeId: MapModeController.PointType,
            coordinate: { x: coord.longitude, y: coord.latitude },
        }
    }

    function resetPreview() {
        coord   = QtPositioning.coordinate()
    }

    // Input handlers
    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds

        onTapped: function (event) {
            const point = map.mapFromItem(root, event.position)
            coord = map.toCoordinate(point, false)
        }
    }

    UI.EditablePoint {
        id: mapPoint
        coordinate: coord
        z: root.z + 1

        isEditing: true
        tapEnabled: false
        showLabel: false
        highlightOnEditing: false

        onPointChanged: function(c) {
            coord = c
        }
    }
}
