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

                Text {
                    visible: TruckNotificationModel.count === 0
                    text: `${TranslationManager.revision}` && qsTr("No notifications")
                    color: Theme.colors.textMuted
                    font.family: Theme.typography.bodySans25Family
                    font.pointSize: Theme.typography.bodySans25Size
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.spacing.s8
                }

                Repeater {
                    model: TruckNotificationModel

                    delegate: NotificationCard {
                        notificationId: model.id
                        operationCode: model.operationCode
                        operationState: model.operationState
                        operationIssueTypeId: model.operationIssueTypeId
                        operationIssueSolutionTypeId: model.operationIssueSolutionTypeId
                        reportedAt: model.reportedAt
                        estimatedArrival: model.estimatedArrival
                        location: model.location
                        note: model.note
                    }
                }

                UI.VerticalSpacer {}

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
                TruckNotificationModel.clearAll()
            }
        }
    }
}
