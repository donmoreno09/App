import QtQuick 6.8
import QtQuick.Effects 6.8
import App.Components 1.0 as UI
import App.Features.Map 1.0

UI.GlobalBackgroundConsumer {
    id: root

    // Property to receive the map source from parent
    property var mapSource: null

    // Controlled by MapController
    opacity: MapController.backgroundOverlayEnabled ? 0.8 : 0.0

    MultiEffect {
        anchors.fill: parent
        source: root.mapSource

        // Make the map brighter so it illuminates through the overlay
        brightness: 0.8        // Brighten the map significantly
        contrast: 1.2          // Increase contrast for better visibility
        saturation: 0.4        // Slightly reduce saturation for tactical look

        opacity: 1.0          // Full opacity for the effect
    }

    // Smooth animation
    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
}
