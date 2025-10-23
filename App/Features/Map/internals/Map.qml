/*!
    \qmltype Map
    \inqmlmodule App.Features.Map
    \brief A Map component which imports map behaviours logic
           such as panning, zooming, etc. from Qt's MapView component.

    Qt's documentation actually does say to grab their MapView component
    and use it however we want. The main idea here is that instead of
    having a wrapper component like MapView, we instead integrate it
    into one Map component.

    UPDATE: Since we're centralizing input, the interaction handlers
            are inside the InteractionMode QML component.

    For more information, check [MapView QML Type](https://doc.qt.io/qt-6/qml-qtlocation-mapview.html).
*/

import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import Qt.labs.animation 6.8

import App.Themes 1.0
import App.Features.MapModes 1.0

Map {
    id: map

    tilt: interactionMode.tiltHandler.persistentTranslation.y / -5

    BoundaryRule on zoomLevel {
        id: br
        minimum: map.minimumZoomLevel
        maximum: map.maximumZoomLevel
    }

    Component.onCompleted: MapModeController.setActiveMode(interactionMode)

    InteractionMode {
        id: interactionMode
        visible: MapModeController.activeMode === interactionMode
        map: map
        br: br
        Component.onCompleted: MapModeRegistry.interactionMode = interactionMode
    }
}
