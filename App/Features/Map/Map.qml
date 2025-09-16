import QtQuick 6.8
import QtLocation 6.8

// NOTE: For now we're using MapView directly from Qt, however,
//       it is better to grab a copy of it and change it
//       accordingly to our needs.
//       It is actually a suggested approach by the official docs itself
//       which you can find here: https://doc.qt.io/qt-6/qml-qtlocation-mapview.html
MapView {
    id: mapView
    map.plugin: Plugin {
        name: "osm"

        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }

        PluginParameter {
            name: "osm.mapping.cache.directory"
            value: "osm_cache"
        }
    }

    Component.onCompleted: {
        MapController.attach(map)
    }

    MapBackgroundOverlay {
        anchors.fill: parent
        z: 1
        mapSource: mapView
    }
}
