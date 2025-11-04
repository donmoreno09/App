pragma Singleton
import QtQuick 6.8
import QtWebEngine 1.10

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

            if (webViewContainer) {
                console.log("[ShipStowageController] WebView preloaded")
            }
        }
    }

    function openStowageWindow(parentWindow) {
        if (!parentWindow) {
            console.error("[ShipStowageController] No parent window provided")
            return
        }

        if (!webViewContainer) {
            initialize(parentWindow)
        }

        if (hasActiveWindow) {
            console.warn("[ShipStowageController] A stowage window is already open")
            return
        }

        webViewContainer.visible = true
        webViewContainer.parentWindow = parentWindow

        if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
            webViewContainer.webViewItem.webView.lifecycleState = WebEngineView.LifecycleState.Active
        }

        hasActiveWindow = true
        windowOpened()

        console.log("[ShipStowageController] Stowage window opened")
    }

    function closeStowageWindow() {
        if (!webViewContainer || !hasActiveWindow) return

        console.log("[ShipStowageController] Closing window...")

        // Nascondi subito
        webViewContainer.visible = false
        hasActiveWindow = false

        // Freeze dopo (con un solo callLater)
        Qt.callLater(function() {
            if (webViewContainer && webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
                var webView = webViewContainer.webViewItem.webView

                try {
                    webView.lifecycleState = WebEngineView.LifecycleState.Frozen
                    webView.runJavaScript("if (window.gc) window.gc();")
                    console.log("[ShipStowageController] Stowage window hidden (frozen)")
                } catch (e) {
                    console.error("[ShipStowageController] Error freezing:", e)
                }
            }

            windowClosed()
        })
    }

    function cleanup() {
        console.log("[ShipStowageController] Cleanup started")

        if (!webViewContainer) {
            console.log("[ShipStowageController] Nothing to clean up")
            return
        }

        // TUTTO IN MODO SINCRONO - nessun Qt.callLater!

        try {
            // 1. Nascondi
            if (webViewContainer.visible) {
                webViewContainer.visible = false
                console.log("[ShipStowageController] Container hidden")
            }

            hasActiveWindow = false

            // 2. Stop e Discard direttamente
            if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
                var webView = webViewContainer.webViewItem.webView

                webView.lifecycleState = WebEngineView.LifecycleState.Discarded
                console.log("[ShipStowageController] WebView discarded")
            }

            // 3. Destroy immediatamente
            webViewContainer.destroy()
            webViewContainer = null

            console.log("[ShipStowageController] Cleanup completed")

        } catch (e) {
            console.error("[ShipStowageController] Error during cleanup:", e)
        }
    }
}
