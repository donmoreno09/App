pragma Singleton

import QtQuick 6.8

import App.Features.MapModes 1.0

QtObject {
    id: root

    // Properties
    property var poi: null
    // TODO: Handle discarding changes by containing the "old" poi

    property BaseMode activeMode: null

    // Methods
    function setActiveMode(mode: BaseMode) {
        if (poi) poi = null // TODO: Handle discarding changes

        activeMode = mode
    }

    function editPoi(editablePoi) {
        poi = editablePoi
    }
}
