import QtQuick 6.8
import QtLocation 6.8

MapView {
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
}
