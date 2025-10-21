import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtWebEngine 1.10

import App.Themes 1.0

Item {
    id: webViewItem
    anchors.fill: parent

    property string urlPath
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

        // Suppress console errors in Qt
        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            // Only log errors, ignore warnings and info
            if (level === WebEngineView.ErrorMessageLevel) {
                console.log("WebView Error:", message)
            }
        }

        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                console.error("WebView failed to load:", loadRequest.errorString)
            }
        }
    }
}
