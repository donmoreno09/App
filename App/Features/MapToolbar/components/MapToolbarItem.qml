import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    property alias source: root.icon.source

    display: AbstractButton.IconOnly

    Layout.preferredWidth: Theme.spacing.s8
    Layout.preferredHeight: Theme.spacing.s8

    icon.width: Theme.icons.sizeMd
    icon.height: Theme.icons.sizeMd
    icon.color: Theme.colors.text

    padding: Theme.spacing.s0

    backgroundRect.border.width: Theme.borders.b0
    // backgroundRect.color: checked ? Qt.darker(Theme.colors.primary500, 2) : Theme.colors.primary500
}
