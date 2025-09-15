pragma Singleton

import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

QtObject {
    // Internals
    property Map _map: null

    property bool backgroundOverlayEnabled: false

    // Methods
    function attach(map) {
        _map = map
    }

    function zoomIn(quantifier) {
        if (!quantifier) quantifier = 1

        if (_map.zoomLevel + quantifier >= _map.maximumZoomLevel) {
            _map.zoomLevel = _map.maximumZoomLevel
        } else {
            _map.zoomLevel += quantifier
        }
    }

    function zoomOut(quantifier) {
        if (!quantifier) quantifier = 1

        if (_map.zoomLevel - quantifier <= _map.minimumZoomLevel) {
            _map.zoomLevel = _map.minimumZoomLevel
        } else {
            _map.zoomLevel -= quantifier
        }
    }

    function toggleBackgroundOverlay() {
            backgroundOverlayEnabled = !backgroundOverlayEnabled
        }
}
