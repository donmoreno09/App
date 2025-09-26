/*!
    \qmltype MapController
    \inqmlmodule App.Features.Map
    \brief A singleton QML controller which handles all Map-specific behaviours.
*/

pragma Singleton

import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import "internals"

QtObject {
    readonly property bool isMapLoading: map !== null && !map.mapReady
    property Map map: null
    property Loader _loader: null
    property Plugin _currentPlugin: null
    property MapState _state: MapState { onRestored: mapRestored() }

    signal mapLoaded()
    signal mapRestored()

    // --------------------- METHODS --------------------- //

    function attachLoader(loader: Loader) {
        if (_loader) _loader.loaded.disconnect(_onLoadedMap)

        _loader = loader
        _loader.loaded.connect(_onLoadedMap)
    }

    function setPlugin(plugin: Plugin) {
        if (isMapLoading) return
        if (plugin === _currentPlugin) return

        // Destroy previous map
        _state.captureState()
        _destroyMap()

        _currentPlugin = plugin
        _loader.source = Qt.resolvedUrl("internals/Map.qml")
    }

    function zoomIn(quantifier) {
        if (!quantifier) quantifier = 1

        if (map.zoomLevel + quantifier >= map.maximumZoomLevel) {
            map.zoomLevel = map.maximumZoomLevel
        } else {
            map.zoomLevel += quantifier
        }
    }

    function zoomOut(quantifier) {
        if (!quantifier) quantifier = 1

        if (map.zoomLevel - quantifier <= map.minimumZoomLevel) {
            map.zoomLevel = map.minimumZoomLevel
        } else {
            map.zoomLevel -= quantifier
        }
    }

    // ----------------- INTERNAL METHODS ----------------- //

    function _onLoadedMap() {
        // No need to check if _loader.item is not null since
        // this gets called if item does exist.
        map = _loader.item
        _state.attach(map)
        map.plugin = _currentPlugin
        mapLoaded()
    }

    function _destroyMap() {
        if (map) {
            _state.detach()
            map.clearData()
        }
        map = null
        _loader.sourceComponent = null
    }
}
