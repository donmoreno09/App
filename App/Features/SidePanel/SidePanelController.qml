pragma Singleton

import QtQuick 6.8
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.ShipStowage 1.0

QtObject {
    id: root

    // Properties
    property bool isOpen: false

    // Signals
    signal opening()
    signal opened()
    signal closing()
    signal closed()
    signal routeChanged(string path)

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
        if (ShipStowageController.hasActiveWindow) {
            ShipStowageController.closeStowageWindow()
        }

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
        if (destroy) PanelRouter.clear()
        closed()
    }

    function openOrRefresh(path, props) {
        if (!path) {
            path = PanelRouter.currentPath ?? ""
        }

        if (!isOpen) {
            open(path, props)
            return
        }

        if (PanelRouter.currentPath === path) {
            // force a refresh of props even if route is the same
            PanelRouter.replace(path, props || {})
            return
        }

        close()
        open(path, props)
    }

    Component.onCompleted: PanelRouter.stackChanged.connect(onStackChanged)
    Component.onDestruction: PanelRouter.stackChanged.disconnect(onStackChanged)
    function onStackChanged(depth: int, currentPath: string) { root.routeChanged(currentPath) }
}
