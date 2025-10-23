import QtQuick 6.8
import QtQuick.Window 6.8

import App.Themes 1.0

DraggableResizableContainer {
    id: container
    width: 800
    height: 600

    property var parentWindow: null

    windowWidth: parentWindow ? parentWindow.width : 800
    windowHeight: parentWindow ? parentWindow.height : 600

    property string webViewUrl: "https://mbpv.fourclicks.it/#/ships/101?token=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkMGM4ZDI5Yi1lM2EyLTRhNzgtODQ1ZS02MDAwYWNhYTlmZWQifQ.eyJpYXQiOjE3NDkyMTQ5NTEsImp0aSI6IjQyNTk2YWY2LTM3OWYtNDMxYi05ZDBmLTk1MjhiMGMyNWI0YiIsImlzcyI6Imh0dHBzOi8vYWRtaW4uZm91cmNsaWNrcy5pdC9hdXRoL3JlYWxtcy9tYnB2IiwiYXVkIjoiaHR0cHM6Ly9hZG1pbi5mb3VyY2xpY2tzLml0L2F1dGgvcmVhbG1zL21icHYiLCJzdWIiOiJmYzAwZTUwZi1jYzZkLTQxNzEtODJjMy01MmE2OTQ5NTQ1YzgiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoibWJwdi1mcm9udGVuZCIsInNlc3Npb25fc3RhdGUiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIiLCJzY29wZSI6InByb2ZpbGUgb2ZmbGluZV9hY2Nlc3MgZW1haWwiLCJzaWQiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIifQ.OX81tY7LNifwUsX0muq1tcPGXPq-BnilG3KHp19IsVE"

    Component.onCompleted: {
        x = (windowWidth - width) / 2
        y = (windowHeight - height) / 2
    }

    WebViewItem {
        id: webViewItem
        anchors.fill: parent
        urlPath: webViewUrl
    }

    onCloseRequested: {
        console.log("WebView container close requested")

        // This stops the webview first before destroying it
        if (webViewItem && webViewItem.webView) {
            webViewItem.webView.stop()
            webViewItem.webView.url = "about:blank"
        }

        // Uses a timer to give time to WebEngine to clean
        Qt.callLater(function() {
            destroy()
        })
    }
}
