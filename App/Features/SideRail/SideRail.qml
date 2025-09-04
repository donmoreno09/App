import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel
import App.Features.TitleBar

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
                text: "Mission"
                active: PanelRouter.currentPath === "mission" && SidePanelController.isOpen

                onClicked: {
                    SidePanelController.toggle("mission")
                    TitleBarController.setTitle("Mission")
                }
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/submarine.svg"
                text: "Pod"
                active: PanelRouter.currentPath === "pod" && SidePanelController.isOpen

                onClicked: {
                    SidePanelController.toggle("pod")
                    TitleBarController.setTitle("Pod")
                }
            }

            SideRailItem {
                visible: PanelRouter.currentPath === "language" && SidePanelController.isOpen
                source: "qrc:/App/assets/icons/world.svg"
                text: "Language"
                active: PanelRouter.currentPath === "language" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle("language")
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
