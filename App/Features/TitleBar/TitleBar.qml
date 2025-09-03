import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
// Import itself to get autocomplete with WindowsNcController
import App.Features.TitleBar 1.0
import App.StubComponents 1.0 as UI
import App.Components 1.0 as UI

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
                Layout.preferredWidth: Theme.icons.sizeXl
                Layout.preferredHeight: Theme.icons.sizeXl

                background: Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius.md
                    color: Theme.colors.textMuted
                }
            }

            UI.SearchBar { }

            RowLayout {
                visible: WindowsNcController.isWindows()
                spacing: Theme.spacing.s2

                UI.Button {
                    text: "\u2013"
                    onClicked: WindowsNcController.window.showMinimized()

                    // NOTE: Temporary style
                    Layout.preferredWidth: Theme.icons.sizeXl
                    Layout.preferredHeight: Theme.icons.sizeXl
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Theme.icons.sizeXl
                        color: Theme.colors.textMuted
                        opacity: Theme.opacity.o40
                    }
                }

                UI.Button {
                    id: maxButton
                    text: "\u2752"
                    onClicked: WindowsNcController.window.visibility = (WindowsNcController.window.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized

                    // NOTE: Temporary style
                    Layout.preferredWidth: Theme.icons.sizeXl
                    Layout.preferredHeight: Theme.icons.sizeXl
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Theme.icons.sizeXl
                        color: Theme.colors.textMuted
                        opacity: Theme.opacity.o40
                    }
                }

                UI.Button {
                    text: "\u2715"
                    onClicked: WindowsNcController.window.close()

                    // NOTE: Temporary style
                    Layout.preferredWidth: Theme.icons.sizeXl
                    Layout.preferredHeight: Theme.icons.sizeXl
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Theme.icons.sizeXl
                        color: Theme.colors.textMuted
                        opacity: Theme.opacity.o40
                    }
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
