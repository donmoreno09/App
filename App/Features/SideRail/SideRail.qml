import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel
import App.Features.TitleBar
import App.Features.MapModes
import App.Features.Language 1.0
import App.Features.ShipStowage 1.0
import App.Features.Notifications 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

UI.GlobalBackgroundConsumer {
    // TESTING PURPOSES
    property bool devPanelsShown: false

    property string currentPanelPath: SidePanelController.router.currentPath

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s0
        z: Theme.elevation.panel

        // TOP SECTION (FIXED)
        UI.VerticalPadding { }

        Image {
            source: "qrc:/App/assets/images/logo.png"
            Layout.preferredWidth: Theme.icons.sizeLogo
            Layout.preferredHeight: Theme.icons.sizeLogo
            Layout.alignment: Qt.AlignCenter
        }

        UI.VerticalPadding { }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.parent.width
                spacing: Theme.spacing.s0

                SideRailItem {
                    source: "qrc:/App/assets/icons/location-dot.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("POI")
                    active: currentPanelPath === Routes.Poi && SidePanelController.isOpen

                    onClicked: {
                        MapModeController.clearState()
                        SidePanelController.toggle(Routes.Poi)
                    }
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/alert-zone.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Alert Zone")
                    active: currentPanelPath === Routes.AlertZone && SidePanelController.isOpen

                    onClicked: {
                        MapModeController.clearState()
                        SidePanelController.toggle(Routes.AlertZone)
                    }
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/truck-fast.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Arrivals")
                    active: currentPanelPath === "arrival-content" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.ArrivalContent)
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/calendar-days.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Date")
                    active: currentPanelPath === "arrival-date-content" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.ArrivalDateContent)
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/calendar-range.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("DT Arrivals")
                    active: currentPanelPath === "arrival-date-time-content" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.ArrivalDateTimeContent)
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/timeline-arrow.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Predictions")
                    active: currentPanelPath === "trailer-prediction" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.TrailerPrediction)
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/ship.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Stowage")
                    active: currentPanelPath === "shipstowage" && SidePanelController.isOpen

                    onClicked: {
                        SidePanelController.close(true)
                        ShipStowageController.openStowageWindow(Window.window)
                    }
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/gate.svg"
                    preserveIconColor: true
                    text: `${TranslationManager.revision}` && qsTr("Gates")
                    active: currentPanelPath === "viGate-services" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.ViGateServices)
                }

                SideRailItem {
                    source: "qrc:/App/assets/icons/bell.svg"
                    text: `${TranslationManager.revision}` && qsTr("Notifications")
                    active: currentPanelPath === "notification" && SidePanelController.isOpen

                    badgeCount: TruckNotificationModel.count + AlertZoneNotificationModel.count

                    onClicked: SidePanelController.toggle(Routes.Notification)
                }

                SideRailItem {
                    visible: currentPanelPath === "languages" && SidePanelController.isOpen
                    source: "qrc:/App/assets/icons/world.svg"
                    icon.width: Theme.icons.sizeMd
                    icon.height: Theme.icons.sizeMd
                    text: `${TranslationManager.revision}` && qsTr("Languages")
                    active: currentPanelPath === "languages" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.Languages)
                }

                SideRailItem {
                    visible: currentPanelPath === "maptilesets" && SidePanelController.isOpen
                    source: "qrc:/App/assets/icons/map.svg"
                    icon.width: Theme.icons.sizeMd
                    icon.height: Theme.icons.sizeMd
                    text: `${TranslationManager.revision}` && qsTr("Tilesets")
                    active: currentPanelPath === "maptilesets" && SidePanelController.isOpen

                    onClicked: SidePanelController.toggle(Routes.MapTilesets)
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: Theme.spacing.s4

            // Stay visible while fading out, hide only when fully transparent
            property bool shouldBeVisible: currentPanelPath !== ""
            opacity: shouldBeVisible ? 1 : 0
            visible: shouldBeVisible || opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.panelTransitionMs
                    easing.type: Theme.motion.panelTransitionEasing
                }
            }

            UI.Button {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/App/assets/icons/panel-chevron.svg"
                icon.width: Theme.icons.sizeMd
                icon.height: Theme.icons.sizeMd
                padding: Theme.spacing.s2

                Layout.preferredWidth: Theme.spacing.s9
                Layout.preferredHeight: Theme.spacing.s9

                onClicked: {
                    if (SidePanelController.isOpen) SidePanelController.close()
                    else SidePanelController.show()
                }

                rotation: SidePanelController.isOpen ? 0 : 180
            }

            UI.VerticalPadding { }
        }

        UI.Avatar {
            Layout.preferredWidth: Theme.spacing.s9
            Layout.preferredHeight: Theme.spacing.s9
            Layout.topMargin: (currentPanelPath !== "") ? 0 : Theme.spacing.s5
            Layout.alignment: Qt.AlignCenter

            source: "qrc:/App/assets/images/avatar.png"
            radius: Theme.radius.circle(width, height)
        }

        UI.VerticalPadding { }
    }
}
