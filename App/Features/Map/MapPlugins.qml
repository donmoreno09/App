pragma Singleton

import QtQuick 6.8
import QtLocation 6.8

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

    readonly property Plugin maplibreSatellite: Plugin {
        name: "maplibre"

        PluginParameter {
           name: "maplibre.map.styles"
           value: "https://api.maptiler.com/maps/hybrid/style.json?key=0m5Y65SvoEZ1VL15Y7ty"
        }
    }
}
