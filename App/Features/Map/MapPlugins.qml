pragma Singleton

import QtQuick 6.8
import QtLocation 6.8
import QtCore 6.8

QtObject {
    function toLocalPath(u) {
        const s = u ? u.toString() : ""
        if (Qt.platform.os === "windows" && s.startsWith("file:///"))
            return decodeURIComponent(s.slice(8)) // C:/...
        if (s.startsWith("file://"))
            return decodeURIComponent(s.slice(7))
        return s
    }

    readonly property string osmCacheDirectory: {
        const cacheUrl = StandardPaths.writableLocation(StandardPaths.CacheLocation)
        const cachePath = toLocalPath(cacheUrl)
        return cachePath.length > 0 ? (cachePath + "/osm_cache") : ""
    }

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
            value: osmCacheDirectory
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
