import QtQuick 6.8
import Qt5Compat.GraphicalEffects
import App.Components 1.0 as UI
import App.Features.Map 1.0

Blend {
    id: root
    anchors.fill: parent
    z: 1

    property var mapSource: null

    // Base layer: Capture the MapView properly
    source: ShaderEffectSource {
        sourceItem: root.mapSource
        anchors.fill: parent
        live: true
        hideSource: false
    }

    // Overlay layer: Your GlobalBackground
    foregroundSource: UI.GlobalBackground {
        anchors.fill: parent
    }

    // Blend mode
    mode: "multiply"

    // Performance optimization
    cached: true

    // Controlled by MapController
    opacity: MapController.backgroundOverlayEnabled ? 1 : 0.0

    // Smooth animation
    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
}
