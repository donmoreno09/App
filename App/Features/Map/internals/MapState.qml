/*!
    \qmltype MapState
    \inqmlmodule App.Features.Map
    \brief Handles persisting map state through plugin switches.
*/

import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

QtObject {
    id: mapState

    property Map _map: null
    property bool _initialLoad: true

    signal captured()
    signal restored()

    // ------------ MAP PROPERTIES TO PERSIST ------------ //
    // property MapType activeMapType // NOTE: The property itself cannot be moved from plugin to plugin; needs research.
    property real bearing
    property var center
    property color color
    property bool copyrightsVisible
    property real fieldOfView
    // property list<Item> mapItems // NOTE: This doesn't invoke autocomplete; It should be a Model anyways. Just here for completeness.
    property real tilt
    property real zoomLevel

    // --------------------- METHODS --------------------- //

    function attach(map: Map) {
        if (_map) detach()

        _map = map
        if (!_map) return

        _map.mapReadyChanged.connect(_mapReadyChangedListener)

        // If it's already ready (can happen), restore on next tick
        if (_map.mapReady) Qt.callLater(() => _mapReadyChangedListener())
    }

    function detach() {
        if (_map) _map.mapReadyChanged.disconnect(_mapReadyChangedListener)

        _map = null
    }

    function captureState() {
        if (!_map) return

        _syncProps(_map, mapState)
        captured()
    }

    function restoreState() {
        if (!_map) return

        _syncProps(mapState, _map)
        restored()
    }

    // ----------------- INTERNAL METHODS ----------------- //

    function _mapReadyChangedListener() {
        if (_initialLoad) {
            _initialLoad = false
            return
        }

        restoreState()
    }

    function _syncProps(fromObj, toObj) {
        const keys = Object.keys(mapState) // Iterate declared MapState props
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i]

            // Only copy if the destination actually exposes that property
            if (!(key in fromObj) || !(key in toObj)) continue
            if (key === "objectName") continue

            // Skip private & signals
            if (key.startsWith("_") || key.endsWith("Changed")) continue

            const value = fromObj[key]
            if (value === undefined) continue // Allow 0/false/null but skip undefined
            if (typeof value === "function") continue

            try {
                toObj[key] = value
            } catch (error) {
                console.error(`Cannot sync "${key}":`, error)
            }
        }
    }
}
