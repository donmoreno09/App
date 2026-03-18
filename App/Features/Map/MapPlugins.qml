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

    component CustomPlugin : Plugin {
        // Adhoc to tell whether the map is a dark variant;
        // prefrerably use the theming system but it'll require major refactor
        // for many components
        required property bool isDark
    }

    readonly property CustomPlugin osm: CustomPlugin {
        name: "osm"
        locales: "it"
        isDark: false
    }

    readonly property CustomPlugin osmDefault: CustomPlugin {
        name: "osm"
        locales: "it"
        isDark: false

        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }

        PluginParameter {
            name: "osm.mapping.cache.directory"
            value: osmCacheDirectory
        }
    }

    readonly property CustomPlugin maplibreLight: CustomPlugin {
        name: "maplibre"
        isDark: false

        PluginParameter {
           name: "maplibre.map.styles"
           value: "https://api.maptiler.com/maps/019cb918-c81c-7afe-b5ca-eee71c1bd607/style.json?key=r8wW6WpMdHaIGV3JI9Ov"
        }
    }

    readonly property CustomPlugin maplibreDark: CustomPlugin {
        name: "maplibre"
        isDark: true

        PluginParameter {
           name: "maplibre.map.styles"
           value: "https://api.maptiler.com/maps/019cb835-5526-73d7-9426-fc6c2a697036/style.json?key=r8wW6WpMdHaIGV3JI9Ov"
        }
    }

    readonly property CustomPlugin maplibreSatellite: CustomPlugin {
        name: "maplibre"
        isDark: true

        PluginParameter {
           name: "maplibre.map.styles"
           value: "https://api.maptiler.com/maps/hybrid/style.json?key=0m5Y65SvoEZ1VL15Y7ty"
        }
    }
}
