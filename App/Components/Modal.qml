import QtQuick
import QtQuick.Controls

Item {
    id: root

    signal dialogOpened(var dialog)
    signal dialogClosed(var dialog)

    property var _stack: []
    readonly property int count: _stack.length

    Popup {
        id: dimOverlay
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        focus: false
        closePolicy: Popup.NoAutoClose

        Overlay.modal: Rectangle {
            color: "black"
            opacity: 0.5
        }

        contentItem: Item {
            Repeater {
                model: _stack

                Loader {
                    id: dialogLoader
                    anchors.centerIn: parent
                    z: index + 1
                    sourceComponent: modelData.component

                    onLoaded: {
                        if (item && item.closed)
                            item.closed.connect(root.pop)
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutQuad }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutQuad }
        }
    }

    function push(component) {
        _stack.push({ component, id: Date.now() })
        _stack = _stack
        if (_stack.length === 1)
            dimOverlay.open()
        dialogOpened(_stack[_stack.length - 1])
    }

    function pop() {
        if (!_stack.length) return
        const dialog = _stack.pop()
        _stack = _stack
        if (!_stack.length)
            dimOverlay.close()
        dialogClosed(dialog)
    }
}
