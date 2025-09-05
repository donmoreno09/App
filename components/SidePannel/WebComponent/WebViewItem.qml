import QtQuick 2.15
import QtQuick.Controls 6.5
import QtWebEngine 1.10

Item {
    id: webViewItem
    anchors.fill: parent
    property string urlPath

    WebEngineView {
        id: webView
        anchors.fill: parent
        url: urlPath

        settings.javascriptEnabled: true
        settings.pluginsEnabled: true
    }
}
