import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

import "." as UI

RowLayout {
    spacing: Theme.spacing.s2

    UI.Button {
        width: Theme.icons.sizeLg
        height: Theme.icons.sizeLg
        radius: Theme.icons.sizeLg
    }

    // Stub UTC time LOCAL time
    Rectangle {
        width: 188
        height: 24
        color: Theme.colors.textMuted
    }
}
