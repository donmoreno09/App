import QtQuick 6.8
import QtQuick.Window 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.ShipStowage 1.0

UI.FloatingWindow {
    id: container
    width: 800
    height: 600
    windowTitle: `${TranslationManager.revision}` && qsTr("Ship Stowage")
    visible: false  // Start hidden

    property var parentWindow: null
    property alias webViewItem: webViewItem

    windowWidth: parentWindow ? parentWindow.width : 800
    windowHeight: parentWindow ? parentWindow.height : 600

    property string webViewUrl: "https://mbpv.fourclicks.it/#/ships/101?token=..."

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
        ShipStowageController.closeStowageWindow()
    }

    // Handle visibility changes
    onVisibleChanged: {
        if (visible) {
            x = (windowWidth - width) / 2
            y = (windowHeight - height) / 2
        }
    }
}
