import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.TitleBar 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    property alias source: root.icon.source

    variant: UI.ButtonStyles.Ghost
    display: AbstractButton.IconOnly
    Layout.preferredWidth: Theme.spacing.s8
    Layout.preferredHeight: Theme.spacing.s8

    icon.source: source
    icon.height: 0
    icon.color: Theme.colors.text

    padding: Theme.spacing.s1
    radius: Theme.radius.circle(width, height)
    backgroundRect.color: Theme.colors.whiteA20
    backgroundRect.border.width: Theme.borders.b0
}
