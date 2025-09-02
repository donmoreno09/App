import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls
import QtQuick.Layouts

import App.Themes 1.0
import App.Components 1.0 as UI
import App.StubComponents 1.0 as UI
import App.Playground 1.0 as UI
import App.Features.TitleBar 1.0
import App.Features.SideRail 1.0
import App.Features.SidePanel 1.0
import App.Features.ContextPanel 1.0
import App.Features.NotificationsBar 1.0

ApplicationWindow {
    id: app
    width: Theme.layout.appWindowWidth
    height: Theme.layout.appWindowHeight
    visible: true
    title: qsTr("IRIDESS FE")

    Component.onCompleted: {
        WindowsNcController.attachToWindow(app)
    }

    UI.GlobalBackground {
        id: globalBackground
        anchors.fill: parent
        visible: false
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SideRail {
            Layout.preferredWidth: Theme.layout.sideRailWidth
            Layout.fillHeight: true
            z: Theme.elevation.panel

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "blue"
                border.width: 2
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TitleBar {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.layout.titleBarHeight
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Item {
                    Layout.preferredWidth: sidePanel.width
                    Layout.fillHeight: true

                    SidePanel {
                        id: sidePanel
                        width: Theme.layout.sidePanelWidth
                        height: parent.height

                        // UI.WizardPageTest {}

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "orange"
                            border.width: 2
                        }
                    }

                    NotificationsBar {
                        id: notificationsBar
                        width: Theme.layout.notificationsBarWidth
                        height: Theme.layout.notificationsBarHeight
                        anchors.left: sidePanel.right
                        anchors.bottom: sidePanel.bottom

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "red"
                            border.width: 2
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ContextPanel {
                    Layout.preferredWidth: Theme.layout.contextPanelWidth
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "green"
                        border.width: 2
                    }
                }
            }
        }
    }
}
