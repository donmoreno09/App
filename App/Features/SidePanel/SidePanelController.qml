pragma Singleton

import QtQuick 6.8
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0

QtObject {
    // Properties
    property bool isOpen: false

    // Signals
    signal opening()
    signal opened()
    signal closing()
    signal closed()
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

        opening()
        if (path == null) path = PanelRouter.currentPath ?? ""
        PanelRouter.replace(path, props || {})
        isOpen = true
        opened()
    }

    function toggle(path, props) {
        if (!isOpen) {
            open(path, props)
            return
        }

        if (PanelRouter.currentPath === path) {
            close()
            return
        }

        PanelRouter.replace(path, props || {})
    }

    function close(destroy) {
        if (!isOpen) return

        closing()
        isOpen = false
        TitleBarController.setTitle("Overview")
        if (destroy) PanelRouter.clear()
        closed()
    }
}
