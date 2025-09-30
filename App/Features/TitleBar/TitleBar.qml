import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
// Import itself to get autocomplete with WindowsNcController
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.StubComponents 1.0 as UI
import App.Components 1.0 as UI

import "components"

UI.GlobalBackgroundConsumer {
    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s2
        z: Theme.elevation.panel

        UI.HorizontalPadding { padding: Theme.spacing.s8 }

        UI.DateTime { }

        UI.HorizontalSpacer { }

        UI.Title { }

        UI.HorizontalSpacer { }

        RowLayout {
            spacing: Theme.spacing.s4

            // LanguageButton
            UI.Button {
                display: AbstractButton.IconOnly
                size: "sm"
                variant: UI.ButtonStyles.Ghost

                icon.width: Theme.icons.sizeSm
                icon.height: Theme.icons.sizeSm
                icon.source: "qrc:/App/assets/icons/world.svg"
                backgroundRect.color: Theme.colors.whiteA20
                backgroundRect.border.width: Theme.borders.b0

                onClicked: {
                    SidePanelController.toggle("language")
                    TitleBarController.setTitle("Languages")
                }
            }

            UI.SearchBar {
                Layout.preferredWidth: Theme.layout.searchBarWidth
                Layout.preferredHeight: Theme.layout.searchBarHeight
                textField.placeholderText: {
                    TranslationManager.revision
                    return qsTr("Search here...")
                }
            }

            RowLayout {
                visible: WindowsNcController.isWindows()
                spacing: Theme.spacing.s2

                SystemButton {
                    source: "qrc:/App/assets/icons/minus.svg"

                    onClicked: WindowsNcController.window.showMinimized()
                }

                SystemButton {
                    source: "qrc:/App/assets/icons/maximize.svg"

                    onClicked: WindowsNcController.window.visibility = (WindowsNcController.window.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized
                }

                SystemButton {
                    source: "qrc:/App/assets/icons/x-close.svg"

                    onClicked: WindowsNcController.window.close()
                }
            }
        }

        UI.HorizontalPadding { padding: Theme.spacing.s8 }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: WindowsNcController.window.startSystemMove()
        onDoubleClicked: WindowsNcController.window.visibility = (WindowsNcController.window.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized
    }
}
