import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    default property alias content: contentSlot.data

    width: contentSlot.width + Theme.spacing.s2 * 2
    height: contentSlot.height + Theme.spacing.s2 * 2

    color: Theme.colors.glass
    radius: Theme.radius.md
    border.color: Theme.colors.glassBorder
    border.width: Theme.borders.b1

    UI.InputShield {
        width: parent.width
        height: parent.height
    }

    ColumnLayout {
        id: contentSlot
        anchors.centerIn: parent
        spacing: Theme.spacing.s1_5
    }
}

