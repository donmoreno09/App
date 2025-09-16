import QtQuick 6.8
import Qt5Compat.GraphicalEffects
import App.Components 1.0 as UI
import App.Features.Map 1.0

Item {
    id: root
    anchors.fill: parent
    z: 1

    property var mapSource: null

    Blend {
        anchors.fill: parent

        source: ShaderEffectSource {
            id: mapShader
            sourceItem: root.mapSource
            width: root.width
            height: root.height
            live: true
            hideSource: false
            sourceRect: Qt.rect(0, 0, root.width, root.height)
        }

        foregroundSource: UI.GlobalBackground {
            id: globalBg
            width: root.width
            height: root.height
        }

        mode: "hardlight"

        cached: false

        opacity: MapController.backgroundOverlayEnabled ? 1.0 : 0.0


        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
}
