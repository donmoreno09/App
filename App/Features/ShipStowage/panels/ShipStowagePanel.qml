import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Ship Stowage"))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        UI.Button {
            Layout.preferredWidth: 280
            Layout.preferredHeight: Theme.spacing.s10
            Layout.alignment: Qt.AlignHCenter
            variant: UI.ButtonStyles.Primary
            text: (TranslationManager.revision, qsTr("Stowage - FourClicks"))

            onClicked: {
                var component = Qt.createComponent("qrc:/App/Features/ShipStowage/components/WebViewContainer.qml")

                const appWindow = parent.Window.window

                if (component.status === Component.Ready) {
                    var webView = component.createObject(appWindow , {
                        parentWindow: appWindow
                    })

                    if (webView === null) {
                        console.error("Error creating WebView")
                    }
                } else if (component.status === Component.Error) {
                    console.error("Error loading component:", component.errorString())
                }
            }
        }

        UI.VerticalSpacer { }
    }
}
