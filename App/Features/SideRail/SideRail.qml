import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel
import App.Features.TitleBar
import App.Features.Language 1.0

UI.GlobalBackgroundConsumer {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s0
        z: Theme.elevation.panel

        UI.VerticalPadding { }

        Image {
            source: "qrc:/App/assets/images/logo.png"
            Layout.preferredWidth: Theme.icons.sizeLogo
            Layout.preferredHeight: Theme.icons.sizeLogo
            Layout.alignment: Qt.AlignCenter
        }

        UI.VerticalPadding { }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s0

            SideRailItem {
                source: "qrc:/App/assets/icons/clipboard.svg"
                text: (TranslationManager.revision, qsTr("Mission"))
                active: PanelRouter.currentPath === "mission" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("Mission")
                    SidePanelController.toggle("mission")
                }
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/submarine.svg"
                text: (TranslationManager.revision, qsTr("Pod"))
                active: PanelRouter.currentPath === "pod" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("Pod")
                    SidePanelController.toggle("pod")
                }
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/notification.svg"
                text: (TranslationManager.revision, qsTr("Notifications"))
                active: PanelRouter.currentPath === "notifications" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("Notifications")
                    SidePanelController.toggle("notifications")
                }
            }

            SideRailItem {
                visible: PanelRouter.currentPath === "language" && SidePanelController.isOpen
                source: "qrc:/App/assets/icons/world.svg"
                text: (TranslationManager.revision, qsTr("Language"))
                active: PanelRouter.currentPath === "language" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("Languages")
                    SidePanelController.toggle("language")
                }
            }

            SideRailItem {
                visible: PanelRouter.currentPath === "maptilesets" && SidePanelController.isOpen
                source: "qrc:/App/assets/icons/map.svg"
                text: (TranslationManager.revision, qsTr("Tilesets"))
                active: PanelRouter.currentPath === "maptilesets" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("Map Tilesets")
                    SidePanelController.toggle("maptilesets")
                }
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/calendar.svg"
                text: (TranslationManager.revision, qsTr("DateTime"))
                active: PanelRouter.currentPath === "datetime-test" && SidePanelController.isOpen

                onClicked: {
                    TitleBarController.setTitle("DateTimePicker Test")
                    SidePanelController.toggle("datetime-test")
                }
            }
        }

        UI.VerticalSpacer { }

        UI.Button {
            display: AbstractButton.IconOnly
            icon.source: "qrc:/App/assets/icons/panel-chevron.svg"
            icon.width: Theme.icons.sizeMd
            icon.height: Theme.icons.sizeMd
            padding: Theme.spacing.s2

            Layout.preferredWidth: Theme.spacing.s9
            Layout.preferredHeight: Theme.spacing.s9
            Layout.alignment: Qt.AlignCenter

            onClicked: {
                if (SidePanelController.isOpen) SidePanelController.close()
                else SidePanelController.open()
            }
        }

        UI.VerticalPadding { }

        UI.Avatar {
            Layout.preferredWidth: Theme.spacing.s9
            Layout.preferredHeight: Theme.spacing.s9
            Layout.alignment: Qt.AlignCenter

            source: "qrc:/App/assets/images/avatar.png"
            radius: Theme.radius.circle(width, height)
        }

        UI.VerticalPadding { }
    }
}
