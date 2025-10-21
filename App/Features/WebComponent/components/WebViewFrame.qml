import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtWebEngine

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    required property string url

    readonly property bool isLoading: webView.loading
    readonly property bool hasError: webView.loadProgress === 0 && !webView.loading && webView.url !== ""

    signal loadingChanged(bool loading)
    signal loadProgressChanged(int progress)
    signal webUrlChanged(url newUrl)

    // Loading overlay
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        visible: root.isLoading
        z: Theme.elevation.popup

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.s4

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: root.isLoading
            }

            Text {
                text: qsTr("Loading web content...")
                color: Theme.colors.text
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Error overlay
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        visible: root.hasError && !root.isLoading
        z: Theme.elevation.popup

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.s4

            Image {
                source: "qrc:/App/assets/icons/circle-xmark.svg"
                Layout.preferredWidth: Theme.icons.size2Xl
                Layout.preferredHeight: Theme.icons.size2Xl
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: qsTr("Failed to load web content")
                color: Theme.colors.error
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightMedium
                Layout.alignment: Qt.AlignHCenter
            }

            UI.Button {
                text: qsTr("Retry")
                variant: UI.ButtonStyles.Primary
                Layout.alignment: Qt.AlignHCenter
                onClicked: webView.reload()
            }
        }
    }

    // Actual web view
    WebEngineView {
        id: webView
        anchors.fill: parent
        url: root.url

        settings.javascriptEnabled: true
        settings.pluginsEnabled: true
        settings.autoLoadImages: true
        settings.errorPageEnabled: true

        // Handle JavaScript console messages
        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            const prefix = "[WebView JS]"
            switch(level) {
                case WebEngineView.InfoMessageLevel:
                    console.log(prefix, message, "(" + sourceID + ":" + lineNumber + ")")
                    break
                case WebEngineView.WarningMessageLevel:
                    console.warn(prefix, message, "(" + sourceID + ":" + lineNumber + ")")
                    break
                case WebEngineView.ErrorMessageLevel:
                    console.error(prefix, message, "(" + sourceID + ":" + lineNumber + ")")
                    break
            }
        }

        onLoadingChanged: function(loadRequest) {
            root.loadingChanged(loadRequest.status === WebEngineLoadingInfo.LoadStartedStatus)

            // Log load errors
            if (loadRequest.status === WebEngineLoadingInfo.LoadFailedStatus) {
                console.error("[WebView] Failed to load:", loadRequest.url, "Error:", loadRequest.errorString)
            }
        }

        onLoadProgressChanged: {
            root.loadProgressChanged(webView.loadProgress)
        }

        onUrlChanged: {
            root.webUrlChanged(webView.url)
        }
    }
}
