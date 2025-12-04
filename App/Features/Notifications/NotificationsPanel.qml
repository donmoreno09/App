import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Notifications 1.0
import App.Features.Map 1.0

import "components" as NotificationComponents

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Notifications")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                NotificationComponents.NotificationEmptyState {
                    visible: TruckNotificationModel.count === 0 && AlertZoneNotificationModel.count === 0
                }

                NotificationComponents.NotificationSectionHeader {
                    sectionTitle: qsTr("Alert Zone Intrusions")
                    visible: AlertZoneNotificationModel.count > 0
                }

                Repeater {
                    model: AlertZoneNotificationModel

                    delegate: NotificationComponents.AlertZoneNotificationCard {
                        notificationId: model.id
                        timestamp: model.timestamp
                        trackName: model.trackName || ""
                        alertZoneName: model.alertZoneName || ""
                        location: model.location

                        onDeleteRequested: (id) => {
                            console.log("[NotificationsPanel] Confirming read for AlertZone:", id)
                            SignalRClientService.invoke("ConfirmRead", [id])
                            AlertZoneNotificationModel.removeNotification(id)
                        }

                        onViewOnMapRequested: (loc) => {
                            MapController.setMapCenter(loc)
                        }
                    }
                }

                UI.HorizontalDivider {
                    visible: AlertZoneNotificationModel.count > 0 && TruckNotificationModel.count > 0
                    Layout.topMargin: Theme.spacing.s4
                    Layout.bottomMargin: Theme.spacing.s4
                }

                NotificationComponents.NotificationSectionHeader {
                    sectionTitle: qsTr("Truck Operations")
                    visible: TruckNotificationModel.count > 0
                }

                Repeater {
                    model: TruckNotificationModel

                    delegate: NotificationComponents.TruckNotificationCard {
                        notificationId: model.id
                        operationCode: model.operationCode
                        operationState: model.operationState
                        reportedAt: model.reportedAt
                        operationIssueTypeId: model.operationIssueTypeId
                        operationIssueSolutionTypeId: model.operationIssueSolutionTypeId
                        estimatedArrival: model.estimatedArrival || ""
                        location: model.location
                        note: model.note || ""

                        onDeleteRequested: (id) => {
                            console.log("[NotificationsPanel] Confirming read for Truck:", id)
                            SignalRClientService.invoke("ConfirmRead", [id])
                            TruckNotificationModel.removeNotification(id)
                        }

                        onViewOnMapRequested: (loc) => {
                            MapController.setMapCenter(loc)
                        }
                    }
                }

                UI.VerticalSpacer {}
            }
        }
    }

    footer: NotificationComponents.NotificationFooter {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s4

        onDeleteAllRequested: {
            console.log("[NotificationsPanel] Confirming read for all notifications")

            let allIds = []

            for (let i = 0; i < TruckNotificationModel.count; i++) {
                const notif = TruckNotificationModel.getEditableNotification(i)
                if (notif) allIds.push(notif.id)
            }

            for (let j = 0; j < AlertZoneNotificationModel.count; j++) {
                const notif = AlertZoneNotificationModel.getEditableNotification(j)
                if (notif) allIds.push(notif.id)
            }

            if (allIds.length > 0) {
                for (let id of allIds) {
                    SignalRClientService.invoke("ConfirmRead", [id])
                }
            }

            TruckNotificationModel.clearAll()
            AlertZoneNotificationModel.clearAll()
        }
    }
}
