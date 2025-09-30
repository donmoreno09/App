import QtQuick 6.8
import QtQuick.Controls.Fusion 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.StubComponents 1.0 as UI
import App.Playground 1.0 as UI
import App.Features.Map 1.0
import App.Features.TitleBar 1.0
import App.Features.SideRail 1.0
import App.Features.SidePanel 1.0
import App.Features.ContextPanel 1.0
import App.Features.Notifications 1.0
import App.Features.MapToolbar 1.0
import App.Features.Language 1.0

ApplicationWindow {
    id: app
    width: Theme.layout.appWindowWidth
    height: Theme.layout.appWindowHeight
    visible: true
    title: qsTr("IRIDESS FE")

    palette {
        placeholderText: "white"
        buttonText: "white"
    }

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

    MapHost {
        anchors.fill: parent
        initialPlugin: MapPlugins.osmDefault

        onInitialLoaded: {
            map.center = QtPositioning.coordinate(44.4071, 8.9347)
            map.copyrightsVisible = false // Hide the copyright label from the bottom left
        }
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
                            notificationsBar.background.recalculateMaskedBg()
                        }

                        Connections {
                            target: app

                            function onWidthChanged() { slider.recalculateMaskedBgs() }
                            function onHeightChanged() { slider.recalculateMaskedBgs() }
                        }

                        x: SidePanelController.isOpen ? 0 : -(Theme.layout.sidePanelWidth + Theme.borders.b1 * 2)
                        onXChanged: recalculateMaskedBgs()
                        Behavior on x {
                            NumberAnimation {
                                duration: Theme.motion.panelTransitionMs
                                easing.type: Theme.motion.panelTransitionEasing
                            }
                        }

                        SidePanel {
                            id: sidePanel
                            Layout.preferredWidth: Theme.layout.sidePanelWidth
                            Layout.fillHeight: true
                        }

                        UI.VerticalDivider { }

                        UI.HorizontalPadding { padding: Theme.spacing.s5 }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignBottom

                            NotificationsBar { id: notificationsBar }

                            UI.VerticalPadding { padding: Theme.spacing.s5 }
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

                // Language switching buttons
                Row {
                    id: languageButtons
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: Theme.spacing.s4
                    anchors.topMargin: Theme.spacing.s4
                    spacing: Theme.spacing.s2

                    UI.Button {
                        id: englishButton
                        text: "English"
                        variant: LanguageController.currentLanguage === "en" ? UI.ButtonStyles.Primary : UI.ButtonStyles.Secondary
                        size: "sm"
                        onClicked: LanguageController.currentLanguage = "en"
                    }

                    UI.Button {
                        id: italianButton
                        text: "Italian"
                        variant: LanguageController.currentLanguage === "it" ? UI.ButtonStyles.Primary : UI.ButtonStyles.Secondary
                        size: "sm"
                        onClicked: LanguageController.currentLanguage = "it"
                    }
                }
            }
        }
    }
}
