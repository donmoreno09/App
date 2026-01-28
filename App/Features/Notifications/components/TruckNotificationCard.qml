import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.Map 1.0

import "../NotificationUtils.js" as Utils

UI.Accordion {
    id: root

    property string cardNotificationId: ""
    property string cardEnvelopeId: ""
    property string cardOperationCode: ""
    property string cardOperationState: ""
    property string cardReportedAt: ""
    property string cardIssueType: ""
    property string cardSolutionType: ""
    property string cardEstimatedArrival: ""
    property var cardLocation: null
    property string cardNote: ""

    // Signals
    signal deleteRequested(string envelopeId, string id)
    signal viewOnMapRequested(var cardLocation)

    Layout.fillWidth: true

    variant: {
        if (root.cardOperationState === "BLOCKED") return UI.AccordionStyles.Warning
        if (root.cardOperationState === "ACTIVE") return UI.AccordionStyles.Success
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
                text: `${TranslationManager.revision}` && qsTr("Truck: ") + root.cardOperationCode
                color: Theme.colors.text
                font.family: Theme.typography.bodySans25StrongFamily
                font.pointSize: Theme.typography.bodySans25StrongSize
                font.weight: Theme.typography.weightBold
                Layout.fillWidth: true
            }

            Text {
                text: {
                    const formatted = Utils.formatNotificationDate(root.cardReportedAt, LanguageController.currentLanguage)
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
                if (root.cardOperationState === "BLOCKED") return Theme.colors.blocked
                if (root.cardOperationState === "ACTIVE") return Theme.colors.active
                return Theme.colors.caution500
            }

            Text {
                anchors.centerIn: parent
                text: {
                    if (root.cardOperationState === "BLOCKED") return `${TranslationManager.revision}` && qsTr("NEW")
                    if (root.cardOperationState === "ACTIVE") return `${TranslationManager.revision}` && qsTr("UPDATED")
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
            text: root.cardOperationCode
            color: Theme.colors.text
            font.family: Theme.typography.bodySans25StrongFamily
            font.pointSize: Theme.typography.bodySans25StrongSize
            font.weight: Theme.typography.weightBold
        }

        Text {
            text: {
                const formatted = Utils.formatNotificationDate(root.cardReportedAt, LanguageController.currentLanguage)
                return `${TranslationManager.revision}` && qsTr("Reported at %1 of %2").arg(formatted.time).arg(formatted.date)
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.cardOperationState === "ACTIVE" && root.cardIssueType !== ""
            text: {
                if (root.cardOperationState === "ACTIVE" && root.cardIssueType !== "") {
                    const issueType = NotificationsTranslations.getIssueTypeName(root.cardIssueType)
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
            visible: root.cardOperationState === "ACTIVE" && root.cardSolutionType !== ""
            text: {
                if (root.cardOperationState === "ACTIVE" && root.cardSolutionType !== "") {
                    const solutionType = NotificationsTranslations.getSolutionTypeName(root.cardSolutionType)
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
            visible: root.cardEstimatedArrival !== "" && root.cardEstimatedArrival !== null
            text: {
                if (root.cardEstimatedArrival) {
                    const dt = new Date(root.cardEstimatedArrival)
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
            visible: {
                if (!root.cardLocation) return false
                if (typeof root.cardLocation !== 'object') return false
                return root.cardLocation.isValid === true
            }
            text: {
                if (!root.cardLocation || !root.cardLocation.isValid) return ""
                return `${TranslationManager.revision}` && qsTr("Location: Lat %1°, Lon %2°")
                    .arg(root.cardLocation.latitude.toFixed(4))
                    .arg(root.cardLocation.longitude.toFixed(4))
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
        }

        Text {
            visible: root.cardNote !== "" && root.cardNote !== null
            text: `${TranslationManager.revision}` && qsTr("Note: %1").arg(root.cardNote)
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
                visible: root.cardLocation && typeof root.cardLocation === 'object' && root.cardLocation.isValid === true

                onClicked: {
                    if (root.cardLocation && root.cardLocation.isValid) {
                        root.viewOnMapRequested(root.cardLocation)
                    }
                }
            }

            UI.Button {
                text: `${TranslationManager.revision}` && qsTr("Delete")
                variant: UI.ButtonStyles.Ghost
                Layout.preferredHeight: Theme.spacing.s8

                onClicked: {
                    root.deleteRequested(root.cardEnvelopeId, root.cardNotificationId)
                }
            }
        }
    }
}
