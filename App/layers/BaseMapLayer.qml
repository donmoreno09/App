import QtQuick 6.8
import QtLocation 6.8

import App.Features.Map 1.0

MapItemGroup {
    id: root

    property var _mapLayer: null

    Connections {
        target: MapController

        function onMapBeforeLoad() {
            if (MapController.map) MapController.map.removeMapItemGroup(root)
        }

        function onMapLoaded() {
            _mapLayer.map = MapController.map
            MapController.map.addMapItemGroup(root)
        }
    }
}
