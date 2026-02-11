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
    id: root
    title.text: `${TranslationManager.revision}` && qsTr("Notifications")

    readonly property int alertZoneCount: AlertZoneNotificationModel.count
    readonly property int truckCount: TruckNotificationModel.count
    readonly property bool hasAlertZone: alertZoneCount > 0
    readonly property bool hasTruck: truckCount > 0

    NotificationEmptyState {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.spacing.s16
        visible: !hasAlertZone && !hasTruck
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s8
        spacing: Theme.spacing.s4
        visible: hasAlertZone || hasTruck

        // Alert Zone Section Header (fixed)
        NotificationSectionHeader {
            Layout.fillWidth: true
            sectionTitle: qsTr("Alert Zone Intrusions")
            visible: hasAlertZone
        }

        // Alert Zone ListView
        ListView {
            id: alertZoneList
            Layout.fillWidth: true
            Layout.fillHeight: hasTruck ? false : true
            Layout.preferredHeight: hasTruck ? Math.min(contentHeight, root.height * 0.4) : -1
            spacing: Theme.spacing.s4
            clip: true
            visible: hasAlertZone

            cacheBuffer: 400
            reuseItems: true

            model: AlertZoneNotificationModel

            delegate: AlertZoneNotificationCard {
                width: alertZoneList.width

                required property int index
                required property string id
                required property string detectedAt
                required property var alertZone
                required property var trackData

                cardNotificationId: id
                cardTimestamp: detectedAt
                cardAlertZone: alertZone ?? {}
                cardTrackData: trackData ?? {}

                onDeleteRequested: (notifId) => {
                    console.log("[NotificationsPanel] Confirming read for AlertZone:", notifId)
                    SignalRClientService.invoke("ConfirmRead", [notifId])
                    AlertZoneNotificationModel.removeNotification(notifId)
                }

                onViewOnMapRequested: (loc) => {
                    MapController.setMapCenter(loc)
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        // Divider (fixed)
        UI.HorizontalDivider {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4
            Layout.bottomMargin: Theme.spacing.s4
            visible: hasAlertZone && hasTruck
        }

        // Truck Section Header (fixed)
        NotificationSectionHeader {
            Layout.fillWidth: true
            sectionTitle: qsTr("Truck Operations")
            visible: hasTruck
        }

        // Truck ListView
        ListView {
            id: truckList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.s4
            clip: true
            visible: hasTruck

            cacheBuffer: 400
            reuseItems: true

            model: TruckNotificationModel

            delegate: TruckNotificationCard {
                width: truckList.width

                required property int index
                required property string id
                required property string envelopeId
                required property string operationCode
                required property string operationState
                required property string reportedAt
                required property string issueType
                required property string solutionType
                required property string estimatedArrival
                required property var location
                required property string note

                cardNotificationId: id
                cardEnvelopeId: envelopeId
                cardOperationCode: operationCode
                cardOperationState: operationState
                cardReportedAt: reportedAt
                cardIssueType: issueType
                cardSolutionType: solutionType
                cardEstimatedArrival: estimatedArrival ?? ""
                cardLocation: location ?? null
                cardNote: note ?? ""

                onDeleteRequested: (envId, notifId) => {
                    console.log("[NotificationsPanel] Confirming read for Truck:", envId)
                    SignalRClientService.invoke("ConfirmRead", [envId])
                    TruckNotificationModel.removeNotification(notifId)
                }

                onViewOnMapRequested: (loc) => {
                    MapController.setMapCenter(loc)
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
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
                for (let k = 0; k < allIds.length; k++) {
                    SignalRClientService.invoke("ConfirmRead", [allIds[k]])
                }
            }

            TruckNotificationModel.clearAll()
            AlertZoneNotificationModel.clearAll()
        }
    }
}
