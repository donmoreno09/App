import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

import "../internals"

AbstractButton {
    id: root

    padding: Theme.spacing.s2
    implicitWidth: contentItem.implicitWidth + padding * 2
    implicitHeight: contentItem.implicitHeight + padding * 2

    required property NotificationsChannel channel

    property bool active: false
    property int variant: NotificationsItemStyles.Info
    property NotificationsItemStyle _style: NotificationsItemStyles.fromVariant(variant)

    readonly property color _bgColor: {
        if (!enabled) return _style.backgroundDisabled
        if (pressed) return _style.backgroundPressed
        if (active) return _style.backgroundActive
        if (hovered) return _style.backgroundHover
        return _style.background
    }

    readonly property color _textColor: {
        if (!enabled) return _style.textColorDisabled
        return _style.textColor
    }

    contentItem: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        radius: Theme.radius.circle(width, height)
        color: _bgColor

        Text {
            anchors.centerIn: parent
            text: channel.count
            color: _style.textColor
            font.weight: Theme.typography.weightSemibold
        }
    }

    background: Rectangle {
        radius: Theme.radius.circle(width, height)
        color: _bgColor
        opacity: Theme.opacity.o10

        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite

            NumberAnimation { to: Theme.opacity.o40; duration: 1000 }
            NumberAnimation { to: Theme.opacity.o10; duration: 1000 }
        }
    }
}
