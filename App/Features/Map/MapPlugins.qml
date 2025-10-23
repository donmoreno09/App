pragma Singleton

import QtQuick 6.8
import QtLocation 6.8
import MapLibre

QtObject {
    readonly property Plugin osm: Plugin {
        name: "osm"
        locales: "it"
    }

    readonly property Plugin osmDefault: Plugin {
        name: "osm"
        locales: "it"

        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }

        PluginParameter {
            name: "osm.mapping.cache.directory"
            value: "osm_cache"
        }
    }

    readonly property Plugin toner: Plugin {
        id: mapPlugin
        name: "maplibre"
        PluginParameter {
           name: "maplibre.map.styles"
           value: "https://api.maptiler.com/maps/toner/style.json?key=0m5Y65SvoEZ1VL15Y7ty"
        }
    }
}
