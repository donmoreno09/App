import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtWebEngine 1.10

import App.Themes 1.0
import App.Features.ShipStowage 1.0

Item {
    id: webViewItem
    anchors.fill: parent

    property string urlPath
    property alias webView: webView
    property alias loading: webView.loading

    // Loading indicator
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.primary900
        visible: webView.loading

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.s4

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: webView.loading
            }

            Text {
                text: qsTr("Loading...")
                color: Theme.colors.text
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    WebEngineView {
        id: webView
        anchors.fill: parent
        url: urlPath

        profile: WebEngineProfileManager.sharedProfile

        // Critical performance settings
        settings.javascriptEnabled: true
        settings.pluginsEnabled: true
        settings.localStorageEnabled: true
        settings.localContentCanAccessRemoteUrls: true

        // ADD THESE PERFORMANCE SETTINGS:
        settings.accelerated2dCanvasEnabled: true
        settings.webGLEnabled: true
        settings.autoLoadImages: true
        settings.javascriptCanOpenWindows: false
        settings.showScrollBars: true

        // Memory and performance optimization
        lifecycleState: WebEngineView.LifecycleState.Active

        // Background color to prevent white flash
        backgroundColor: Theme.colors.primary900

        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            var ignoredMessages = [
                "useDefaultLang",
                "defaultLanguage",
                "sessionChecksEnabled",
                "error loading user info",
                "fallbackLang"
            ]

            for (var i = 0; i < ignoredMessages.length; i++) {
                if (message.indexOf(ignoredMessages[i]) !== -1) {
                    return
                }
            }
        }

        // Handle loading errors
        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                console.error("WebView failed to load:", loadRequest.errorString)
            }
        }

        Component.onDestruction: {
            lifecycleState = WebEngineView.LifecycleState.Discarded
            stop()
            url = "about:blank"
        }
    }
}
