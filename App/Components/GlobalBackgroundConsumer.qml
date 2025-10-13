import QtQuick
import QtQuick.Effects

Item {
    id: root

    property alias maskRect: maskRect

    // Forward background instance here for quick access
    readonly property GlobalBackground bg: globalBackground

    // Certain actions like animations need manual intervention
    // to update the background so it does not come off bugged.
    function recalculateMaskedBg() {
        maskShader.sourceRect = _recalculate()
    }

    function _recalculate() {
        const p = bg.mapFromItem(root, 0, 0)
        return Qt.rect(p.x, p.y, root.width, root.height)
    }

    // Prevent map interactions below this component
    InputShield { anchors.fill: parent }

    // Render background
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
                // Force dependency tracking of screen resizes.
                // This fixes stuck panel with white background.
                root.x; root.y; bg.x; bg.y; bg.width; bg.height;

                return _recalculate()
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
