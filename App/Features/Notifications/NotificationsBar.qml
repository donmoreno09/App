import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

import "components"

Item {
    id: root

    implicitWidth: container.width
    implicitHeight: container.height

    property alias background: backgroundConsumer

    // NOTE: Right now I'm using Rectangle to create a glass effect,
    //       however, it might be worth looking into MultiEffect to
    //       either replace this approach or complement it. (E.g. blur)
    Rectangle {
        id: container

        width: backgroundConsumer.childrenRect.width + Theme.spacing.s4
        height: backgroundConsumer.childrenRect.height + Theme.spacing.s4
        color: Theme.colors.glass

        radius: Theme.radius.md
        border.color: Theme.colors.glassBorder
        border.width: Theme.borders.b1
    }

    UI.GlobalBackgroundConsumer {
        id: backgroundConsumer
        anchors.centerIn: parent
        implicitHeight: notificationsContainer.implicitHeight + Theme.spacing.s1 * 2
        width: Theme.layout.notificationsBarWidth
        maskRect.radius: Theme.radius.sm

        NotificationsContainer {
            id: notificationsContainer

            anchors.leftMargin: Theme.spacing.s2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            NotificationsItem {
                variant: NotificationsItemStyles.Urgent
                channel: NotificationsController.urgent
            }

            NotificationsItem {
                variant: NotificationsItemStyles.Warning
                channel: NotificationsController.warning
            }

            NotificationsItem {
                variant: NotificationsItemStyles.Info
                channel: NotificationsController.info
            }
        }

        RowLayout {
            id: buttonsContainer
            spacing: Theme.spacing.s4

            anchors.rightMargin: Theme.spacing.s2
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                display: AbstractButton.IconOnly

                icon.source: "qrc:/App/assets/icons/arrow-right-bar.svg"
                icon.width: Theme.icons.sizeLg

                radius: 0
                padding: 0
                backgroundRect.border.width: Theme.borders.b0
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                display: AbstractButton.IconOnly

                icon.source: "qrc:/App/assets/icons/circled-check-underlined.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg

                radius: 0
                padding: 0
                backgroundRect.border.width: Theme.borders.b0
            }
        }
    }
}
