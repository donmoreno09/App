import QtQuick
import QtQuick.Effects

Item {
    id: root

    property alias maskRect: maskRect

    property AppBackground bg: appBackground

    Rectangle {
        id: maskRect
        anchors.fill: parent
        layer.enabled: true

        ShaderEffectSource {
            id: maskShader
            anchors.fill: parent
            sourceItem: bg
            live: true
            recursive: true
            visible: false
            sourceRect: {
                const p = bg.mapFromItem(root, 0, 0)
                return Qt.rect(p.x, p.y, root.width, root.height)
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: maskShader
        maskEnabled: true
        maskSource: maskRect
    }
}
