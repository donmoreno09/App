import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Auth 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

UI.Overlay {
    id: root

    padding: Theme.spacing.s5
    width: Theme.layout.logoutDialogWidth
    height: Theme.layout.logoutDialogHeight

    background: Rectangle {
        radius: Theme.radius.sm
        color: Theme.colors.bg
        border.width: Theme.borders.b1
        border.color: Theme.colors.whiteA10
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0;    to: 1.0;  duration: 200; easing.type: Easing.OutBack }
            NumberAnimation { property: "scale";   from: 0.95; to: 1.0;  duration: 200; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0;    duration: 15; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale";   from: 1.0; to: 0.95; duration: 15; easing.type: Easing.InCubic }
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.s4

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s2

            Text {
                text: qsTr("Logging out")
                color: Theme.colors.text
                font.family:    Theme.typography.bodySans50Family
                font.pointSize: Theme.typography.bodySans50Size
                font.weight:    Theme.typography.weightSemibold
                Layout.fillWidth: true
            }

            Item {
                implicitWidth:  Theme.icons.sizeSm
                implicitHeight: Theme.icons.sizeSm

                Image {
                    anchors.centerIn: parent
                    source:   "qrc:/App/assets/icons/x-close.svg"
                    fillMode: Image.PreserveAspectFit
                    width:    Theme.icons.sizeSm - 2
                    height:   Theme.icons.sizeSm - 2

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorizationColor: Theme.colors.text
                        colorization: 1.0
                    }
                }

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler   { onTapped: root.close() }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s4

            Text {
                text: qsTr("Do you want to log out?")
                color: Theme.colors.text
                font.family:    Theme.typography.bodySans25Family
                font.pointSize: Theme.typography.bodySans25Size
                font.weight:    Theme.typography.bodySans25Weight
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            RowLayout {
                UI.HorizontalSpacer {}

                UI.Button {
                    text: qsTr("Yes, log out")
                    variant: UI.ButtonStyles.PrimaryDarkMode
                    Layout.preferredWidth: 88
                    radius: Theme.radius.sm
                    onClicked: {
                        root.close()
                        AuthManager.logout()
                    }
                }

                UI.HorizontalSpacer {}
            }
        }
    }
}
