import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel
import App.Features.TitleBar
import App.Features.Language 1.0
import App.Features.ShipStowage 1.0
import App.Features.Notifications 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

UI.GlobalBackgroundConsumer {
    // TESTING PURPOSES
    property bool devPanelsShown: false

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
                visible: devPanelsShown
                source: "qrc:/App/assets/icons/clipboard.svg"
                text: (TranslationManager.revision, qsTr("Mission"))
                active: PanelRouter.currentPath === "mission" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.Mission)
            }

            SideRailItem {
                visible: devPanelsShown
                source: "qrc:/App/assets/icons/submarine.svg"
                text: (TranslationManager.revision, qsTr("Pod"))
                active: PanelRouter.currentPath === "pod" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.Pod)
            }

            SideRailItem {
                visible: devPanelsShown
                source: "qrc:/App/assets/icons/notification.svg"
                text: (TranslationManager.revision, qsTr("Notifications"))
                active: PanelRouter.currentPath === "notifications" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.Notifications)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/layers.svg"
                text: (TranslationManager.revision, qsTr("Layers"))
                active: PanelRouter.currentPath === "maplayers" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.MapLayers)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/poi.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("PoI"))
                active: PanelRouter.currentPath === Routes.Poi && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.Poi)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/truck.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Truck Arrivals"))
                active: PanelRouter.currentPath === "arrival-content" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.ArrivalContent)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/calendar-arrivals.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Truck Arrivals Date"))
                active: PanelRouter.currentPath === "arrival-date-content" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.ArrivalDateContent)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/settings.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Truck Arrivals DT"))
                active: PanelRouter.currentPath === "arrival-date-time-content" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.ArrivalDateTimeContent)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/compass.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Trailer Prediction"))
                active: PanelRouter.currentPath === "trailer-prediction" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.TrailerPrediction)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/monitor.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Ship Stowage"))
                active: PanelRouter.currentPath === "shipstowage" && SidePanelController.isOpen

                onClicked: ShipStowageController.openStowageWindow(Window.window)
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/test.svg"
                preserveIconColor: true
                text: (TranslationManager.revision, qsTr("Leonardo ViGate Services"))
                active: PanelRouter.currentPath === "viGate-services" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.ViGateServices)

            }

            SideRailItem {
                source: "qrc:/App/assets/icons/notification-bell.svg"
                text: (TranslationManager.revision, qsTr("Notifications"))
                active: PanelRouter.currentPath === "notification" && SidePanelController.isOpen

                badgeCount: NotificationsController.totalCount

                onClicked: SidePanelController.toggle(Routes.Notification)
            }

            SideRailItem {
                visible: PanelRouter.currentPath === "language" && SidePanelController.isOpen
                source: "qrc:/App/assets/icons/world.svg"
                icon.width: Theme.icons.sizeMd
                icon.height: Theme.icons.sizeMd
                text: (TranslationManager.revision, qsTr("Languages"))
                active: PanelRouter.currentPath === "language" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.Languages)
            }

            SideRailItem {
                visible: PanelRouter.currentPath === "maptilesets" && SidePanelController.isOpen
                source: "qrc:/App/assets/icons/map.svg"
                icon.width: Theme.icons.sizeMd
                icon.height: Theme.icons.sizeMd
                text: (TranslationManager.revision, qsTr("Tilesets"))
                active: PanelRouter.currentPath === "maptilesets" && SidePanelController.isOpen

                onClicked: SidePanelController.toggle(Routes.MapTilesets)
            }
        }

        UI.VerticalSpacer { }

        ColumnLayout {
            Layout.alignment: Qt.AlignCenter

            // Stay visible while fading out, hide only when fully transparent
            property bool shouldBeVisible: PanelRouter.currentPath !== ""
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
                    else SidePanelController.open()
                }

                rotation: SidePanelController.isOpen ? 0 : 180
            }

            UI.VerticalPadding { }
        }

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
