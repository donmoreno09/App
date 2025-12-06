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

    // Data properties
    property string cardNotificationId: ""
    property string cardTimestamp: ""
    property string cardTrackName: ""
    property string cardAlertZoneName: ""
    property var cardLocation: null

    // Signals
    signal deleteRequested(string id)
    signal viewOnMapRequested(var cardLocation)

    Layout.fillWidth: true
    variant: UI.AccordionStyles.Urgent
    expanded: false

    headerContent: RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s3

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "#FFCC00"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s1

            Text {
                text: `${TranslationManager.revision}` && qsTr("Alert Zone: ") + qsTr("Name of the alert zone.")
                color: Theme.colors.text
                font.family: Theme.typography.bodySans25StrongFamily
                font.pointSize: Theme.typography.bodySans25StrongSize
                font.weight: Theme.typography.weightBold
                Layout.fillWidth: true
            }

            Text {
                text: {
                    const formatted = Utils.formatNotificationDate(root.cardTimestamp, LanguageController.currentLanguage)
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
            color: Theme.colors.warning500

            Text {
                anchors.centerIn: parent
                text: `${TranslationManager.revision}` && qsTr("NEW")
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
            text: root.cardNotificationId
            color: Theme.colors.text
            font.family: Theme.typography.bodySans25Family
            font.pointSize: Theme.typography.bodySans25Size
            font.weight: Theme.typography.weightBold
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: {
                const formatted = Utils.formatNotificationDate(root.cardTimestamp, LanguageController.currentLanguage)
                return `${TranslationManager.revision}` && qsTr("Reported at %1 of %2").arg(formatted.time).arg(formatted.date)
            }
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.cardTrackName !== "" && root.cardTrackName !== null
            text: `${TranslationManager.revision}` && qsTr("Track: %1").arg(root.cardTrackName)
            color: Theme.colors.textMuted
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
        }

        Text {
            visible: root.cardAlertZoneName !== "" && root.cardAlertZoneName !== null
            text: `${TranslationManager.revision}` && qsTr("Alert Zone: %1").arg(root.cardAlertZoneName)
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

        RowLayout {
            Layout.alignment: Qt.AlignRight

            UI.Button {
                visible: {
                    if (!root.cardLocation) return false
                    if (typeof root.cardLocation !== 'object') return false
                    return root.cardLocation.isValid === true
                }
                text: `${TranslationManager.revision}` && qsTr("View on Map")
                variant: UI.ButtonStyles.Primary
                icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                icon.width: 16
                icon.height: 16
                Layout.preferredHeight: Theme.spacing.s8

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
                    root.deleteRequested(root.cardNotificationId)
                }
            }
        }
    }
}
