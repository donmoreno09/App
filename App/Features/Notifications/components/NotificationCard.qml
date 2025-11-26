import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.Notifications 1.0

UI.Accordion {
    id: root

    required property string notificationId
    required property string operationCode
    required property string operationState
    required property int operationIssueTypeId
    required property int operationIssueSolutionTypeId
    required property string reportedAt
    required property string estimatedArrival
    required property var location
    required property string note

    Layout.fillWidth: true
    expanded: false

    variant: {
        if (operationState === "BLOCKED") return UI.AccordionStyles.Warning
        if (operationState === "ACTIVE") return UI.AccordionStyles.Success
        return UI.AccordionStyles.Warning
    }

    headerContent: RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s3

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s1

            Text {
                text: `${TranslationManager.revision}` && qsTr("Truck: %1").arg(root.operationCode)
                color: Theme.colors.text
                font.family: Theme.typography.bodySans25StrongFamily
                font.pointSize: Theme.typography.bodySans25StrongSize
                font.weight: Theme.typography.weightBold
                Layout.fillWidth: true
            }

            Text {
                text: {
                    const dt = new Date(root.reportedAt)
                    const locale = Qt.locale(LanguageController.currentLanguage)
                    return `${TranslationManager.revision}` && qsTr("Reported at %1").arg(dt.toLocaleString(locale, Locale.ShortFormat))
                }
                color: Theme.colors.textMuted
                font.family: Theme.typography.bodySans15Family
                font.pointSize: Theme.typography.bodySans15Size
                font.weight: Theme.typography.bodySans15Weight
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        NotificationBadge {
            operationState: root.operationState
        }
    }

    content: ColumnLayout {
        width: parent.width
        spacing: Theme.spacing.s3

        // Issue Type (only for ACTIVE state with valid issue)
        Text {
            visible: root.operationState === "ACTIVE" && root.operationIssueTypeId > 0
            text: {
                const issueType = NotificationsTranslations.getIssueTypeName(root.operationIssueTypeId)
                return `${TranslationManager.revision}` && qsTr("Issue: %1").arg(issueType)
            }
            color: Theme.colors.text
            font.family: Theme.typography.bodySans25Family
            font.pointSize: Theme.typography.bodySans25Size
            font.weight: Theme.typography.bodySans25Weight
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Solution Type (only for ACTIVE state with valid solution)
        Text {
            visible: root.operationState === "ACTIVE" && root.operationIssueSolutionTypeId > 0
            text: {
                const solutionType = NotificationsTranslations.getSolutionTypeName(root.operationIssueSolutionTypeId)
                return `${TranslationManager.revision}` && qsTr("Resolution: %1").arg(solutionType)
            }
            color: Theme.colors.text
            font.family: Theme.typography.bodySans25Family
            font.pointSize: Theme.typography.bodySans25Size
            font.weight: Theme.typography.bodySans25Weight
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Estimated Arrival
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
            font.weight: Theme.typography.bodySans15Weight
        }

        // Location
        Text {
            visible: root.location && root.location.isValid
            text: {
                if (root.location && root.location.isValid) {
                    return `${TranslationManager.revision}` && qsTr("Location: Lat %1°, Lon %2°")
                        .arg(root.location.latitude.toFixed(4))
                        .arg(root.location.longitude.toFixed(4))
                }
                return ""
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            font.weight: Theme.typography.bodySans15Weight
        }

        // Note
        Text {
            visible: root.note !== "" && root.note !== null
            text: `${TranslationManager.revision}` && qsTr("Note: %1").arg(root.note)
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            font.weight: Theme.typography.bodySans15Weight
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Action Buttons
        NotificationActions {
            notificationId: root.notificationId
            location: root.location
        }
    }
}
