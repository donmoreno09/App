import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Notifications 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Notifications"))

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                // Show message if no notifications
                Text {
                    visible: TruckNotificationModel.count === 0
                    text: (TranslationManager.revision, qsTr("No notifications"))
                    color: Theme.colors.textMuted
                    font.family: Theme.typography.bodySans25Family
                    font.pointSize: Theme.typography.bodySans25Size
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.spacing.s8
                }

                // Notifications list
                Repeater {
                    model: TruckNotificationModel

                    delegate: UI.Accordion {
                        Layout.fillWidth: true

                        // Map operationState to accordion variant
                        variant: {
                            if (model.operationState === "BLOCKED") return UI.AccordionStyles.Warning
                            if (model.operationState === "ACTIVE") return UI.AccordionStyles.Success
                            return UI.AccordionStyles.Warning
                        }

                        expanded: false

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            // Left side: Title + Preview stacked
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                // Bold title - Operation Code
                                Text {
                                    text: (TranslationManager.revision, qsTr("Truck: ")) + model.operationCode
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                // Preview text - Reported timestamp
                                Text {
                                    text: {
                                        const dt = new Date(model.reportedAt)
                                        return (TranslationManager.revision,
                                            qsTr("Reported at %1").arg(dt.toLocaleString(Qt.locale())))
                                    }
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15Weight
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Right side: Badge
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
                                        if (model.operationState === "BLOCKED") return (TranslationManager.revision, qsTr("NEW"))
                                        if (model.operationState === "ACTIVE") return (TranslationManager.revision, qsTr("UPDATED"))
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
                                text: (TranslationManager.revision, qsTr("Truck: ")) + model.operationCode
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25StrongFamily
                                font.pointSize: Theme.typography.bodySans25StrongSize
                                font.weight: Theme.typography.weightBold
                            }

                            // Show issue type or solution type based on state
                            Text {
                                visible: {
                                    if (model.operationState === "BLOCKED") {
                                        return model.operationIssueTypeId > 0
                                    } else if (model.operationState === "ACTIVE") {
                                        return model.operationIssueSolutionTypeId > 0
                                    }
                                    return false
                                }
                                text: {
                                    if (model.operationState === "BLOCKED" && model.operationIssueTypeId > 0) {
                                        const issueType = NotificationsTranslations.getIssueTypeName(model.operationIssueTypeId)
                                        return (TranslationManager.revision, qsTr("Issue: %1").arg(issueType))
                                    } else if (model.operationState === "ACTIVE" && model.operationIssueSolutionTypeId > 0) {
                                        const solutionType = NotificationsTranslations.getSolutionTypeName(model.operationIssueSolutionTypeId)
                                        return (TranslationManager.revision, qsTr("Resolution: %1").arg(solutionType))
                                    }
                                    return ""
                                }
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            // Show estimated arrival if available
                            Text {
                                visible: model.estimatedArrival !== "" && model.estimatedArrival !== null
                                text: {
                                    if (model.estimatedArrival) {
                                        const dt = new Date(model.estimatedArrival)
                                        return (TranslationManager.revision,
                                            qsTr("Estimated arrival: %1").arg(dt.toLocaleString(Qt.locale())))
                                    }
                                    return ""
                                }
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            // Show location
                            Text {
                                text: {
                                    const loc = model.location
                                    return (TranslationManager.revision,
                                        qsTr("Location: Lat %1°, Lon %2°")
                                        .arg(loc.latitude.toFixed(4))
                                        .arg(loc.longitude.toFixed(4)))
                                }
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            // Show note if available
                            Text {
                                visible: model.note !== "" && model.note !== null
                                text: (TranslationManager.revision, qsTr("Note: %1").arg(model.note))
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: (TranslationManager.revision, qsTr("Delete"))
                                variant: UI.ButtonStyles.Ghost
                                Layout.preferredHeight: Theme.spacing.s8

                                onClicked: {
                                    TruckNotificationModel.removeNotification(model.id)
                                }
                            }
                        }
                    }
                }

                UI.VerticalSpacer {}

                // Bottom actions
                UI.HorizontalDivider {
                    visible: TruckNotificationModel.count > 0
                }
            }
        }
    }

    footer: RowLayout {
            visible: TruckNotificationModel.count > 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.s3
            spacing: Theme.spacing.s2

            UI.Button {
                Layout.fillWidth: true
                variant: UI.ButtonStyles.Ghost
                text: (TranslationManager.revision, qsTr("Back"))

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
                text: (TranslationManager.revision, qsTr("Delete All"))

                onClicked: {
                    TruckNotificationModel.clearAll()
                }
            }
        }
}
