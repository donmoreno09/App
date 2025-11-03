import QtQuick 6.8
import QtQuick.Controls.Fusion 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
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
import App.Features.ShipStowage 1.0

ApplicationWindow {
    id: app
    minimumWidth: Theme.layout.appWindowWidth
    minimumHeight: Theme.layout.appWindowHeight
    visible: true
    title: qsTr("IRIDESS FE")

    palette: AppPalette { }

    // Used for listeners that needs for the app to be fully loaded first.
    // Apparently Qt's ApplicationWindow does not have a flag for it.
    property bool appLoaded: false

    Component.onCompleted: {
        PoiOptions.fetchAll()
        WindowsNcController.attachToWindow(app)
        appLoaded = true
    }

    UI.GlobalBackground {
        id: globalBackground
        anchors.fill: parent
    }

    MapHost {
        anchors.fill: parent
        initialPlugin: MapPlugins.osmDefault

        onInitialLoaded: {
            map.center = QtPositioning.coordinate(44.4071, 8.9347)
            map.copyrightsVisible = false // Hide the copyright label from the bottom left
        }

        MOCPoIStaticLayer { }

        PoiMapLayer { }

        AISTrackMapLayer { }

        TirTrackMapLayer { }

        DocSpaceTrackMapLayer { }
    }

    Connections {
        target: LayerManager

        function onAllLayersReady() {
            console.log("OK!")
        }
    }

    Connections {
        target: TranslationManager

        function onRevisionChanged() {
            PoiOptions.updateTranslations()
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
                            //notificationsBar.background.recalculateMaskedBg()
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

                        // NOTE: NotificationsBar is hidden since it is currently unused.
                        // UI.HorizontalPadding { padding: Theme.spacing.s5 }
                        // ColumnLayout {
                        //     Layout.alignment: Qt.AlignBottom

                        //     NotificationsBar { id: notificationsBar }

                        //     UI.VerticalPadding { padding: Theme.spacing.s5 }
                        // }
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
