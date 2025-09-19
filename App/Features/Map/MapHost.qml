/*!
    \qmltype MapHost
    \inqmlmodule App.Features.Map
    \brief A container to place dynamically created Map objects.

    The reason for dynamically creating Map objects is because
    once we set Map.plugin, it cannot be changed, and therefore,
    to support changing tilesets using other plugins, this approach
    is needed.
*/

import QtQuick 6.8
import QtLocation 6.8

Item {
    required property Plugin initialPlugin

    readonly property Map map: loader.item

    property bool _initialLoad: true

    signal initialLoaded()
    signal loaded()

    Loader {
        id: loader
        anchors.fill: parent

        Component.onCompleted: {
            MapController.attachLoader(loader)
            MapController.setPlugin(initialPlugin)
        }
    }

    // Forward loaded signal for convenience
    Connections {
        target: MapController

        function onMapLoaded() {
            if (_initialLoad) {
                initialLoaded()
                _initialLoad = false
                return
            }

            loaded()
        }
    }
}
