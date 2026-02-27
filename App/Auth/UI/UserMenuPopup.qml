import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Auth 1.0
import App.Features.Language 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

UI.Overlay {
    id: root

    width: Theme.layout.userMenuWidth
    modal: true
    showBackdrop: false
    anchors.centerIn: undefined
    transformOrigin: Item.BottomLeft
    padding: 0

    background: Rectangle {
        radius: Theme.radius.lg
        color: Theme.colors.surface
        border.width: Theme.borders.b1
        border.color: Theme.colors.whiteA10
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutBack }
            NumberAnimation { property: "scale"; from: 0.92; to: 1.0; duration: 200; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.92; duration: 150; easing.type: Easing.InCubic }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Profile header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.s4
            spacing: Theme.spacing.s3

            UI.Avatar {
                Layout.preferredWidth: Theme.spacing.s9
                Layout.preferredHeight: Theme.spacing.s9
                source: "qrc:/App/assets/images/avatar.png"
                radius: Theme.radius.circle(Theme.spacing.s9, Theme.spacing.s9)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s0_5

                Text {
                    Layout.fillWidth: true
                    text: AuthManager.displayName
                    color: Theme.colors.text
                    font.family: Theme.typography.bodySans50StrongFamily
                    font.pointSize: Theme.typography.bodySans50StrongSize
                    font.weight: Theme.typography.bodySans50StrongWeight
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: "@" + AuthManager.username
                    color: Theme.colors.textMuted
                    font.family: Theme.typography.bodySans25Family
                    font.pointSize: Theme.typography.bodySans25Size
                    font.weight: Theme.typography.bodySans25Weight
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: AuthManager.email
                    color: Theme.colors.textMuted
                    font.family: Theme.typography.bodySans25Family
                    font.pointSize: Theme.typography.bodySans25Size
                    font.weight: Theme.typography.bodySans25Weight
                    elide: Text.ElideRight
                }
            }
        }

        UI.HorizontalDivider {}

        // Logout button
        Item {
            Layout.fillWidth: true
            implicitHeight: logoutButton.implicitHeight + Theme.spacing.s2 * 2

            UI.Button {
                id: logoutButton
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.s2
                }

                variant: UI.ButtonStyles.Primary
                text: `${TranslationManager.revision}` && qsTr("Log out")

                onClicked: {
                    root.close()
                    AuthManager.logout()
                }
            }
        }
    }
}
