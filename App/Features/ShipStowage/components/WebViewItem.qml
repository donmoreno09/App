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

        // Start frozen, will be activated when shown
        lifecycleState: WebEngineView.LifecycleState.Frozen

        settings.javascriptEnabled: true
        settings.pluginsEnabled: true
        settings.localStorageEnabled: true
        settings.localContentCanAccessRemoteUrls: true
        settings.accelerated2dCanvasEnabled: true
        settings.webGLEnabled: true
        settings.autoLoadImages: true
        settings.javascriptCanOpenWindows: false
        settings.showScrollBars: true

        backgroundColor: Theme.colors.primary900

        // Preconnect for faster subsequent loads
        Component.onCompleted: {
            runJavaScript(`
                const link = document.createElement('link');
                link.rel = 'preconnect';
                link.href = 'https://mbpv.fourclicks.it';
                link.crossOrigin = 'anonymous';
                if (document.head) document.head.appendChild(link);
            `)
        }

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

        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                console.error("WebView failed to load:", loadRequest.errorString)
            } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                console.log("WebView loaded successfully")
            }
        }
    }
}
