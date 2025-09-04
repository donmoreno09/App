import QtQuick
import QtQuick.Effects

Item {
    id: root

    property alias maskRect: maskRect

    // NOTE: To be analyzed where should we pull from the
    //       global background component, right now it's
    //       being pulled through the "context tree" meaning
    //       this consumer component must be under a component
    //       instantiating the GlobalBackground component.
    //       I am thinking of a singleton-controller solution but
    //       needs to be properly assessed.
    property GlobalBackground bg: globalBackground

    // Certain actions like animations need manual intervention
    // to update the background so it does not come off bugged.
    function recalculateMaskedBg() {
        maskShader.sourceRect = _recalculate()
    }

    function _recalculate() {
        const p = bg.mapFromItem(root, 0, 0)
        return Qt.rect(p.x, p.y, root.width, root.height)
    }

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
