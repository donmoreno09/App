pragma Singleton
import QtQuick 6.8
import QtWebEngine 1.10

QtObject {
    id: root

    property bool hasActiveWindow: false
    property var webViewContainer: null  // Keep reference to container

    signal windowOpened()
    signal windowClosed()

    // Call this on app startup or first use
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

        // Initialize if not already done
        if (!webViewContainer) {
            initialize(parentWindow)
        }

        if (hasActiveWindow) {
            console.warn("[ShipStowageController] A stowage window is already open")
            return
        }

        // Show and activate the existing container
        webViewContainer.visible = true
        webViewContainer.parentWindow = parentWindow

        // Reactivate WebView
        if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
            webViewContainer.webViewItem.webView.lifecycleState = WebEngineView.LifecycleState.Active
        }

        hasActiveWindow = true
        windowOpened()

        console.log("[ShipStowageController] Stowage window opened")
    }

    function closeStowageWindow() {
        if (!webViewContainer || !hasActiveWindow) return

        // Hide instead of destroy
        webViewContainer.visible = false

        // Freeze to save resources
        if (webViewContainer.webViewItem && webViewContainer.webViewItem.webView) {
            webViewContainer.webViewItem.webView.lifecycleState = WebEngineView.LifecycleState.Frozen
        }

        hasActiveWindow = false
        windowClosed()

        console.log("[ShipStowageController] Stowage window hidden")
    }
}
