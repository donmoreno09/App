pragma Singleton

import QtQuick 6.8

QtObject {
    id: root

    property bool hasActiveWindow: false

    signal windowOpened()
    signal windowClosed()

    function openStowageWindow(parentWindow) {
        if(!parentWindow) {
            console.error("[ShipStowageController] No parent window provided")
            return
        }

        if(hasActiveWindow) {
            console.warn("[ShipStowageController] A stowage window is already open")
        }

        var component = Qt.createComponent("qrc:/App/Features/ShipStowage/components/WebViewContainer.qml")

        if(component.status === Component.Ready) {
            var webView = component.createObject(parentWindow, {
                parentWindow: parentWindow
            })

            if(webView === null) {
                console.error("[ShipStowageController] Failed to create WebView instance")
            }

            hasActiveWindow = true
            windowOpened()

            webView.Component.destruction.connect(function() {
                hasActiveWindow = false
                windowClosed()
                console.log("[ShipStowageController] Stowage window closed")
            })

            console.log("[ShipStowageController] Stowage window opened")
        } else if(component.status === Component.Error) {
            console.error("[ShipStowageController] component error: ", component.errorString())
        } else {
            console.warn("[ShipStowageController] Component not ready status: ", component.status)
        }
    }
}
