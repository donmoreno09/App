import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    implicitWidth: container.width
    implicitHeight: container.height

    property alias background: backgroundConsumer

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
        width: Theme.layout.notificationsBarWidth
        height: 36
        maskRect.radius: Theme.radius.sm
    }
}
