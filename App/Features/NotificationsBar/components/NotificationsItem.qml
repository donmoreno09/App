import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    Layout.preferredWidth: container.width
    Layout.preferredHeight: container.height

    Rectangle {
        id: container

        width: item.width + Theme.spacing.s3
        height: item.height + Theme.spacing.s3
        radius: Theme.radius.circle(width, height)
        opacity: Theme.opacity.o20
    }

    Rectangle {
        id: item

        anchors.centerIn: parent

        width: Theme.layout.notificationsBarItemWidth
        height: Theme.layout.notificationsBarItemHeight
        radius: Theme.radius.circle(width, height)

        color: "blue"

        Text {
            anchors.centerIn: parent
            text: "N"
            color: Theme.colors.text
            font.weight: Theme.typography.weightSemibold
        }
    }
}
