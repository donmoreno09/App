import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0
import App.Features.Notifications 1.0
import App.Features.Map 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Notifications")

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        Pane {
            anchors.fill: parent
            padding: Theme.spacing.s4
            background: Rectangle { color: Theme.colors.transparent }

            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.s4

                NotificationEmptyState {
                    visible: TruckNotificationModel.count === 0 && AlertZoneNotificationModel.count === 0
                }

                NotificationSectionHeader {
                    sectionTitle: qsTr("Alert Zone Intrusions")
                    visible: AlertZoneNotificationModel.count > 0
                }

                Repeater {
                    model: AlertZoneNotificationModel

                    delegate: AlertZoneNotificationCard {
                        required property string id
                        required property string timestamp
                        required property string trackName
                        required property string alertZoneName
                        required property var location

                        cardNotificationId: id
                        cardTimestamp: timestamp
                        cardTrackName: trackName || ""
                        cardAlertZoneName: alertZoneName || ""
                        cardLocation: location

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

                NotificationSectionHeader {
                    sectionTitle: qsTr("Truck Operations")
                    visible: TruckNotificationModel.count > 0
                }

                Repeater {
                    model: TruckNotificationModel

                    delegate: TruckNotificationCard {
                        required property string id
                        required property string envelopeId
                        required property string operationCode
                        required property string operationState
                        required property string reportedAt
                        required property int operationIssueTypeId
                        required property int operationIssueSolutionTypeId
                        required property string estimatedArrival
                        required property var location
                        required property string note

                        cardNotificationId: id
                        cardEnvelopeId: envelopeId
                        cardOperationCode: operationCode
                        cardOperationState: operationState
                        cardReportedAt: reportedAt
                        cardOperationIssueTypeId: operationIssueTypeId
                        cardOperationIssueSolutionTypeId: operationIssueSolutionTypeId
                        cardEstimatedArrival: estimatedArrival || ""
                        cardLocation: location
                        cardNote: note || ""

                        onDeleteRequested: (envelopeId, id) => {
                            console.log("[NotificationsPanel] Confirming read for Truck:", envelopeId)
                            SignalRClientService.invoke("ConfirmRead", [envelopeId])
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

    footer: NotificationFooter {

        onDeleteAllRequested: {
            console.log("[NotificationsPanel] Confirming read for all notifications")

            let allIds = []

            for (let i = 0; i < TruckNotificationModel.count; i++) {
                const notif = TruckNotificationModel.getEditableNotification(i)
                if (notif) allIds.push(notif.envelopeId)
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
