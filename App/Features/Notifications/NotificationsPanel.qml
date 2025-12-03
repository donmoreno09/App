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

                // Empty state (shown when both models are empty)
                Text {
                    visible: TruckNotificationModel.count === 0 && AlertZoneNotificationModel.count === 0
                    text: `${TranslationManager.revision}` && qsTr("No notifications")
                    color: Theme.colors.textMuted
                    font.family: Theme.typography.bodySans25Family
                    font.pointSize: Theme.typography.bodySans25Size
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.spacing.s8
                }

                // ════════════════════════════════════════════════════════════
                // ALERT ZONE NOTIFICATIONS (EventType 2)
                // ════════════════════════════════════════════════════════════

                Text {
                    visible: AlertZoneNotificationModel.count > 0
                    text: `${TranslationManager.revision}` && qsTr("Alert Zone Intrusions")
                    color: Theme.colors.text
                    font.family: Theme.typography.bodySans25StrongFamily
                    font.pointSize: Theme.typography.bodySans25StrongSize
                    font.weight: Theme.typography.weightBold
                    Layout.topMargin: Theme.spacing.s4
                }

                Repeater {
                    model: AlertZoneNotificationModel

                    delegate: UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Urgent
                        expanded: false

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                Text {
                                    text: `${TranslationManager.revision}` && model.title
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        const dt = new Date(model.timestamp)
                                        const locale = Qt.locale(LanguageController.currentLanguage)
                                        return dt.toLocaleString(locale, Locale.ShortFormat)
                                    }
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s20
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.error500

                                Text {
                                    anchors.centerIn: parent
                                    text: `${TranslationManager.revision}` && qsTr("ALERT")
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: model.message
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: model.trackName !== "" && model.trackName !== null
                                text: `${TranslationManager.revision}` && qsTr("Track: %1").arg(model.trackName)
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                            }

                            Text {
                                visible: model.alertZoneName !== "" && model.alertZoneName !== null
                                text: `${TranslationManager.revision}` && qsTr("Alert Zone: %1").arg(model.alertZoneName)
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                            }

                            Text {
                                visible: model.location && model.location.isValid
                                text: {
                                    const loc = model.location
                                    return `${TranslationManager.revision}` && qsTr("Location: Lat %1°, Lon %2°")
                                        .arg(loc.latitude.toFixed(4))
                                        .arg(loc.longitude.toFixed(4))
                                }
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignRight

                                UI.Button {
                                    visible: model.location && model.location.isValid
                                    text: `${TranslationManager.revision}` && qsTr("View on Map")
                                    variant: UI.ButtonStyles.Primary
                                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                                    icon.width: 16
                                    icon.height: 16
                                    Layout.preferredHeight: Theme.spacing.s8

                                    onClicked: {
                                        MapController.setMapCenter(model.location)
                                    }
                                }

                                UI.Button {
                                    text: `${TranslationManager.revision}` && qsTr("Delete")
                                    variant: UI.ButtonStyles.Ghost
                                    Layout.preferredHeight: Theme.spacing.s8

                                    onClicked: {
                                        console.log("[NotificationsPanel] Confirming read for AlertZone:", model.id)
                                        SignalRClientService.invoke("ConfirmRead", [model.id])
                                        AlertZoneNotificationModel.removeNotification(model.id)
                                    }
                                }
                            }
                        }
                    }
                }

                UI.HorizontalDivider {
                    visible: AlertZoneNotificationModel.count > 0 && TruckNotificationModel.count > 0
                    Layout.topMargin: Theme.spacing.s4
                    Layout.bottomMargin: Theme.spacing.s4
                }

                // ════════════════════════════════════════════════════════════
                // TRUCK NOTIFICATIONS (EventType 0, 1)
                // ════════════════════════════════════════════════════════════

                Text {
                    visible: TruckNotificationModel.count > 0
                    text: `${TranslationManager.revision}` && qsTr("Truck Operations")
                    color: Theme.colors.text
                    font.family: Theme.typography.bodySans25StrongFamily
                    font.pointSize: Theme.typography.bodySans25StrongSize
                    font.weight: Theme.typography.weightBold
                    Layout.topMargin: Theme.spacing.s4
                }

                Repeater {
                    model: TruckNotificationModel

                    delegate: UI.Accordion {
                        Layout.fillWidth: true

                        variant: {
                            if (model.operationState === "BLOCKED") return UI.AccordionStyles.Warning
                            if (model.operationState === "ACTIVE") return UI.AccordionStyles.Success
                            return UI.AccordionStyles.Warning
                        }

                        expanded: false

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                Text {
                                    text: `${TranslationManager.revision}` && qsTr("Truck: ") + model.operationCode
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        const dt = new Date(model.reportedAt)
                                        const locale = Qt.locale(LanguageController.currentLanguage)
                                        return `${TranslationManager.revision}` && qsTr("Reported at %1").arg(dt.toLocaleString(locale, Locale.ShortFormat))
                                    }
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s20
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: {
                                    if (model.operationState === "BLOCKED") return Theme.colors.warning500
                                    if (model.operationState === "ACTIVE") return Theme.colors.success500
                                    return Theme.colors.caution500
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (model.operationState === "BLOCKED") return `${TranslationManager.revision}` && qsTr("NEW")
                                        if (model.operationState === "ACTIVE") return `${TranslationManager.revision}` && qsTr("UPDATED")
                                        return ""
                                    }
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: (`${TranslationManager.revision}` && qsTr("Truck: ")) + model.operationCode
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25StrongFamily
                                font.pointSize: Theme.typography.bodySans25StrongSize
                                font.weight: Theme.typography.weightBold
                            }

                            Text {
                                visible: model.operationState === "ACTIVE" && model.operationIssueTypeId > 0
                                text: {
                                    if (model.operationState === "ACTIVE" && model.operationIssueTypeId > 0) {
                                        const issueType = NotificationsTranslations.getIssueTypeName(model.operationIssueTypeId)
                                        return `${TranslationManager.revision}` && qsTr("Issue: %1").arg(issueType)
                                    }
                                    return ""
                                }
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: model.operationState === "ACTIVE" && model.operationIssueSolutionTypeId > 0
                                text: {
                                    if (model.operationState === "ACTIVE" && model.operationIssueSolutionTypeId > 0) {
                                        const solutionType = NotificationsTranslations.getSolutionTypeName(model.operationIssueSolutionTypeId)
                                        return `${TranslationManager.revision}` && qsTr("Resolution: %1").arg(solutionType)
                                    }
                                    return ""
                                }
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: model.estimatedArrival !== "" && model.estimatedArrival !== null
                                text: {
                                    if (model.estimatedArrival) {
                                        const dt = new Date(model.estimatedArrival)
                                        const locale = Qt.locale(LanguageController.currentLanguage)
                                        return `${TranslationManager.revision}` && qsTr("Estimated arrival: %1").arg(dt.toLocaleString(locale, Locale.ShortFormat))
                                    }
                                    return ""
                                }
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                            }

                            Text {
                                text: {
                                    const loc = model.location
                                    return `${TranslationManager.revision}` && qsTr("Location: Lat %1°, Lon %2°")
                                        .arg(loc.latitude.toFixed(4))
                                        .arg(loc.longitude.toFixed(4))
                                }
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                            }

                            Text {
                                visible: model.note !== "" && model.note !== null
                                text: `${TranslationManager.revision}` && qsTr("Note: %1").arg(model.note)
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignRight

                                UI.Button {
                                    text: `${TranslationManager.revision}` && qsTr("View on Map")
                                    variant: UI.ButtonStyles.Primary
                                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                                    icon.width: 16
                                    icon.height: 16
                                    Layout.preferredHeight: Theme.spacing.s8
                                    enabled: model.location && model.location.isValid

                                    onClicked: {
                                        MapController.setMapCenter(model.location)
                                    }
                                }

                                UI.Button {
                                    text: `${TranslationManager.revision}` && qsTr("Delete")
                                    variant: UI.ButtonStyles.Ghost
                                    Layout.preferredHeight: Theme.spacing.s8

                                    onClicked: {
                                        console.log("[NotificationsPanel] Confirming read for Truck:", model.id)
                                        SignalRClientService.invoke("ConfirmRead", [model.id])
                                        TruckNotificationModel.removeNotification(model.id)
                                    }
                                }
                            }
                        }
                    }
                }

                UI.VerticalSpacer {}
            }
        }
    }

    footer: RowLayout {
        visible: TruckNotificationModel.count > 0 || AlertZoneNotificationModel.count > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s3
        spacing: Theme.spacing.s2

        UI.Button {
            Layout.fillWidth: true
            variant: UI.ButtonStyles.Ghost
            text: `${TranslationManager.revision}` && qsTr("Back")

            background: Rectangle {
                color: Theme.colors.transparent
                border.width: 0
            }

            onClicked: {
                SidePanelController.close()
            }
        }

        UI.Button {
            Layout.fillWidth: true
            variant: UI.ButtonStyles.Primary
            text: `${TranslationManager.revision}` && qsTr("Delete All")

            onClicked: {
                console.log("[NotificationsPanel] Confirming read for all notifications")

                // Collect all notification IDs
                let allIds = []

                // Add truck notification IDs
                for (let i = 0; i < TruckNotificationModel.count; i++) {
                    const notif = TruckNotificationModel.getEditableNotification(i)
                    if (notif) allIds.push(notif.value("id"))
                }

                // Add alert zone notification IDs
                for (let i = 0; i < AlertZoneNotificationModel.count; i++) {
                    const notif = AlertZoneNotificationModel.getEditableNotification(i)
                    if (notif) allIds.push(notif.value("id"))
                }

                // Confirm all reads via SignalR (if backend supports bulk operation)
                if (allIds.length > 0) {
                    // Option 1: If backend has "ConfirmReadBulk" method
                    // SignalRClientService.invoke("ConfirmReadBulk", [allIds])

                    // Option 2: Individual calls (less efficient but works)
                    for (let id of allIds) {
                        SignalRClientService.invoke("ConfirmRead", [id])
                    }
                }

                // Clear local models
                TruckNotificationModel.clearAll()
                AlertZoneNotificationModel.clearAll()
            }
        }
    }
}
