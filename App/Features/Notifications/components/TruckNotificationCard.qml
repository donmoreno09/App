import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.Map 1.0

import "qrc:/App/Features/Notifications/NotificationUtils.js" as Utils

UI.Accordion {
    id: root

    // Data properties
    required property string notificationId
    required property string operationCode
    required property string operationState
    required property string reportedAt
    required property int operationIssueTypeId
    required property int operationIssueSolutionTypeId
    required property string estimatedArrival
    required property var location
    required property string note

    // Signals
    signal deleteRequested(string id)
    signal viewOnMapRequested(var location)

    Layout.fillWidth: true

    variant: {
        if (root.operationState === "BLOCKED") return UI.AccordionStyles.Warning
        if (root.operationState === "ACTIVE") return UI.AccordionStyles.Success
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
                text: `${TranslationManager.revision}` && qsTr("Truck: ") + root.operationCode
                color: Theme.colors.text
                font.family: Theme.typography.bodySans25StrongFamily
                font.pointSize: Theme.typography.bodySans25StrongSize
                font.weight: Theme.typography.weightBold
                Layout.fillWidth: true
            }

            Text {
                text: {
                    const formatted = Utils.formatNotificationDate(root.reportedAt, LanguageController.currentLanguage)
                    return `${TranslationManager.revision}` && qsTr("Reported at %1 of %2").arg(formatted.time).arg(formatted.date)
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
                if (root.operationState === "BLOCKED") return Theme.colors.warning500
                if (root.operationState === "ACTIVE") return Theme.colors.success500
                return Theme.colors.caution500
            }

            Text {
                anchors.centerIn: parent
                text: {
                    if (root.operationState === "BLOCKED") return `${TranslationManager.revision}` && qsTr("NEW")
                    if (root.operationState === "ACTIVE") return `${TranslationManager.revision}` && qsTr("UPDATED")
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
            text: root.operationCode
            color: Theme.colors.text
            font.family: Theme.typography.bodySans25StrongFamily
            font.pointSize: Theme.typography.bodySans25StrongSize
            font.weight: Theme.typography.weightBold
        }

        Text {
            text: {
                const formatted = Utils.formatNotificationDate(root.reportedAt, LanguageController.currentLanguage)
                return `${TranslationManager.revision}` && qsTr("Reported at %1 of %2").arg(formatted.time).arg(formatted.date)
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.operationState === "ACTIVE" && root.operationIssueTypeId > 0
            text: {
                if (root.operationState === "ACTIVE" && root.operationIssueTypeId > 0) {
                    const issueType = NotificationsTranslations.getIssueTypeName(root.operationIssueTypeId)
                    return `${TranslationManager.revision}` && qsTr("Issue: %1").arg(issueType)
                }
                return ""
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            visible: root.operationState === "ACTIVE" && root.operationIssueSolutionTypeId > 0
            text: {
                if (root.operationState === "ACTIVE" && root.operationIssueSolutionTypeId > 0) {
                    const solutionType = NotificationsTranslations.getSolutionTypeName(root.operationIssueSolutionTypeId)
                    return `${TranslationManager.revision}` && qsTr("Resolution: %1").arg(solutionType)
                }
                return ""
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            visible: root.estimatedArrival !== "" && root.estimatedArrival !== null
            text: {
                if (root.estimatedArrival) {
                    const dt = new Date(root.estimatedArrival)
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
                const loc = root.location
                return `${TranslationManager.revision}` && qsTr("Location: Lat %1°, Lon %2°")
                    .arg(loc.latitude.toFixed(4))
                    .arg(loc.longitude.toFixed(4))
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
        }

        Text {
            visible: root.note !== "" && root.note !== null
            text: `${TranslationManager.revision}` && qsTr("Note: %1").arg(root.note)
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
                enabled: root.location && root.location.isValid

                onClicked: {
                    root.viewOnMapRequested(root.location)
                }
            }

            UI.Button {
                text: `${TranslationManager.revision}` && qsTr("Delete")
                variant: UI.ButtonStyles.Ghost
                Layout.preferredHeight: Theme.spacing.s8

                onClicked: {
                    root.deleteRequested(root.notificationId)
                }
            }
        }
    }
}
