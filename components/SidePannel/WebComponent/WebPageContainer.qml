import QtQuick 2.15
import QtQuick.Window 2.15

// This is where you set the URL you want to display

DraggableResizableContainer {
    id: resizableContainerWebViewItem
    width: 800
    height: 600
    windowWidth: mainWindow.width
    windowHeight: mainWindow.height
    x: 100
    y: 100

    property string webViewUrl: "https://mbpv.fourclicks.it/#/ships/101?token=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkMGM4ZDI5Yi1lM2EyLTRhNzgtODQ1ZS02MDAwYWNhYTlmZWQifQ.eyJpYXQiOjE3NDkyMTQ5NTEsImp0aSI6IjQyNTk2YWY2LTM3OWYtNDMxYi05ZDBmLTk1MjhiMGMyNWI0YiIsImlzcyI6Imh0dHBzOi8vYWRtaW4uZm91cmNsaWNrcy5pdC9hdXRoL3JlYWxtcy9tYnB2IiwiYXVkIjoiaHR0cHM6Ly9hZG1pbi5mb3VyY2xpY2tzLml0L2F1dGgvcmVhbG1zL21icHYiLCJzdWIiOiJmYzAwZTUwZi1jYzZkLTQxNzEtODJjMy01MmE2OTQ5NTQ1YzgiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoibWJwdi1mcm9udGVuZCIsInNlc3Npb25fc3RhdGUiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIiLCJzY29wZSI6InByb2ZpbGUgb2ZmbGluZV9hY2Nlc3MgZW1haWwiLCJzaWQiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIifQ.OX81tY7LNifwUsX0muq1tcPGXPq-BnilG3KHp19IsVE"

    WebViewItem {
        id: webViewItem
        anchors.fill: parent
        urlPath: webViewUrl
    }

    onCloseRequested: {
        console.log("WebView container close requested")
        destroy()
    }
}
