import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls
import QtQuick.Layouts

import App.Themes 1.0
import App.Components 1.0 as UI
import App.StubComponents 1.0 as UI
import App.Playground 1.0 as UI
import App.Features.Map 1.0
import App.Features.TitleBar 1.0
import App.Features.SideRail 1.0
import App.Features.SidePanel 1.0
import App.Features.ContextPanel 1.0
import App.Features.NotificationsBar 1.0
import App.Features.MapToolbar 1.0

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

    Map {
        anchors.fill: parent
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // SideRail container
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

        // Main container w/ TitleBar
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TitleBar {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.layout.titleBarHeight
            }

            UI.HorizontalDivider { }

            // Main container
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Main's left side components
                Item {
                    implicitWidth: childrenRect.width
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    RowLayout {
                        id: slider
                        height: parent.height
                        spacing: 0

                        function recalculateMaskedBgs() {
                            if (!appLoaded) return
                            sidePanel.recalculateMaskedBg()
                            notificationsBar.recalculateMaskedBg()
                        }

                        Connections {
                            target: app

                            function onWidthChanged() { slider.recalculateMaskedBgs() }
                            function onHeightChanged() { slider.recalculateMaskedBgs() }
                        }

                        x: SidePanelController.isOpen ? 0 : -(Theme.layout.sidePanelWidth + Theme.borders.b1 * 2)
                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        onXChanged: recalculateMaskedBgs()

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

                // Main's right side components
                MapToolbar {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: Theme.spacing.s7
                    anchors.bottomMargin: Theme.spacing.s5
                }
            }
        }
    }
}
