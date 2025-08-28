import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

import "." as UI

RowLayout {
    spacing: Theme.spacing.s4

    UI.Button {
        width: Theme.icons.sizeXl
        height: Theme.icons.sizeXl

        background: Rectangle {
            anchors.fill: parent
            radius: Theme.icons.sizeXl
            color: Theme.colors.textMuted
        }
    }

    // Stub UTC time LOCAL time
    Text {
        text: "UTC 12:35:55 LOCAL 14:35:55"
        color: Theme.colors.text
        font.pointSize: Theme.typography.sizeSm
    }
}
