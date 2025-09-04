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

    // Used for listeners that needs for the app to be fully loaded first.
    // Apparently Qt's ApplicationWindow does not have a flag for it.
    property bool appLoaded: false

    Component.onCompleted: {
        WindowsNcController.attachToWindow(app)
        appLoaded = true
    }

    UI.GlobalBackground {
        id: globalBackground
        anchors.fill: parent
        visible: false
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillHeight: true
            spacing: 0
            z: Theme.elevation.panel

            SideRail {
                Layout.preferredWidth: Theme.layout.sideRailWidth
                Layout.fillHeight: true
            }

            UI.VerticalDivider { }
        }


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TitleBar {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.layout.titleBarHeight
            }

            UI.HorizontalDivider { }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Item {
                    Layout.preferredWidth: 0
                    Layout.fillHeight: true

                    RowLayout {
                        id: slider
                        height: parent.height
                        spacing: 0

                        x: SidePanelController.isOpen ? 0 : -(Theme.layout.sidePanelWidth + Theme.borders.b1 * 2)
                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        onXChanged: {
                            if (!appLoaded) return
                            sidePanel.recalculateMaskedBg()
                            notificationsBar.recalculateMaskedBg()
                        }

                        SidePanel {
                            id: sidePanel
                            Layout.preferredWidth: Theme.layout.sidePanelWidth
                            Layout.fillHeight: true
                        }

                        UI.VerticalDivider { }

                        NotificationsBar {
                            id: notificationsBar
                            Layout.preferredWidth: Theme.layout.notificationsBarWidth
                            Layout.preferredHeight: Theme.layout.notificationsBarHeight
                            Layout.alignment: Qt.AlignBottom
                        }
                    }
                }

                UI.HorizontalSpacer { }
            }
        }
    }
}
