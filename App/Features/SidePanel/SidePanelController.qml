pragma Singleton

import QtQuick 6.8
import App.Features.SidePanel 1.0

QtObject {
    // Properties
    property bool isOpen: false
    property string currentPath: ""

    // Signals
    signal willOpen()
    signal didOpen()
    signal willClose()
    signal didClose()
    signal routeChanged(string path)
    signal navigationError(string path, string reason)

    // Internals
    property Item _panel: null

    // Methods
    function attach(sidePanel) {
        _panel = sidePanel
    }

    function open(path, props) {
        if (isOpen) return

        willOpen()
        PanelRouter.replace(path, props || {})
        isOpen = true
        didOpen()
    }

    function toggle(path, props) {
        if (path == null) path = ""

        if (!isOpen) {
            open(path ?? PanelRouter.currentPath, props)
            return
        }

        if (PanelRouter.currentPath === path) {
            close()
            return
        }

        PanelRouter.replace(path, props || {})
    }

    function close() {
        if (!isOpen) return

        willClose()
        isOpen = false
        didClose()
    }
}
