import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtWebEngine 1.10

import App.Themes 1.0

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

        settings.javascriptEnabled: true
        settings.pluginsEnabled: true
        settings.localStorageEnabled: true
        settings.localContentCanAccessRemoteUrls: true

        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            // ← MIGLIORA: log più dettagliati
            var levelStr = ""
            switch(level) {
                case WebEngineView.InfoMessageLevel: levelStr = "INFO"; break
                case WebEngineView.WarningMessageLevel: levelStr = "WARN"; break
                case WebEngineView.ErrorMessageLevel: levelStr = "ERROR"; break
            }

            if (level === WebEngineView.ErrorMessageLevel) {
                console.error("[WebView " + levelStr + "]", message, "at line", lineNumber, "in", sourceID)
            }
        }

        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                console.error("[WebView] Failed to load:", loadRequest.errorString, "URL:", loadRequest.url)
            } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                // console.log("[WebView] Successfully loaded:", loadRequest.url)
            } else if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                // console.log("[WebView] Loading started:", loadRequest.url)
            }
        }

        // Cleanup quando il componente viene distrutto
        Component.onDestruction: {
            stop()
            url = "about:blank"
        }

        // Handler per certificati SSL
        onCertificateError: function(error) {
            console.error("[WebView] Certificate error:", error.description)
            // error.ignoreCertificateError() // ← Uncomment se vuoi ignorare errori SSL (solo dev!)
        }

        // Handler per render process crashes
        onRenderProcessTerminated: function(terminationStatus, exitCode) {
            console.error("[WebView] Render process terminated:", terminationStatus, "exit code:", exitCode)
        }
    }
}
