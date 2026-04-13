pragma Singleton

import QtQuick 6.8
import QtWebEngine 1.10

import App.Logger 1.0

QtObject {
    id: root

    property bool hasActiveWindow: false
    property var webViewContainer: null

    signal windowOpened()
    signal windowClosed()

    function initialize(parentWindow) {
        if (webViewContainer) return

        var component = Qt.createComponent("qrc:/App/Features/ShipStowage/components/WebViewContainer.qml")

        if (component.status === Component.Ready) {
            webViewContainer = component.createObject(parentWindow, {
                parentWindow: parentWindow,
                visible: false
            })
        }
    }

    function openStowageWindow(parentWindow) {
        if (!parentWindow) {
            AppLogger.withService("SHIP-STOWAGE-CONTROLLER").error("No parent window provided")
            return
        }

        if (!webViewContainer) {
            initialize(parentWindow)
        }

        if (hasActiveWindow) {
            AppLogger.withService("SHIP-STOWAGE-CONTROLLER").warn("A stowage window is already open")
            return
        }

        webViewContainer.visible = true
        webViewContainer.parentWindow = parentWindow

        if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
            webViewContainer.webViewItem.webView.lifecycleState = WebEngineView.LifecycleState.Active
        }

        hasActiveWindow = true
        windowOpened()
    }

    function closeStowageWindow() {
        if (!webViewContainer || !hasActiveWindow) return

        webViewContainer.visible = false
        hasActiveWindow = false

        Qt.callLater(function() {
            if (webViewContainer && webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
                var webView = webViewContainer.webViewItem.webView

                try {
                    webView.lifecycleState = WebEngineView.LifecycleState.Frozen
                    webView.runJavaScript("if (window.gc) window.gc();")
                    AppLogger.withService("SHIP-STOWAGE-CONTROLLER").info("Stowage window hidden (frozen)")
                } catch (e) {
                    AppLogger.withService("SHIP-STOWAGE-CONTROLLER").error("Error freezing", { error: String(e) })
                }
            }

            windowClosed()
        })
    }

    function cleanup() {
        if (!webViewContainer) {
            return
        }

        try {
            if (webViewContainer.visible) {
                webViewContainer.visible = false
            }

            hasActiveWindow = false

            if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
                var webView = webViewContainer.webViewItem.webView

                webView.lifecycleState = WebEngineView.LifecycleState.Discarded
            }

            webViewContainer.destroy()
            webViewContainer = null
        } catch (e) {
            AppLogger.withService("SHIP-STOWAGE-CONTROLLER").error("Error during cleanup", { error: String(e) })
        }
    }
}
