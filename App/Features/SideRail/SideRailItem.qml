import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    property alias source: root.icon.source
    property bool preserveIconColor: false

    variant: UI.ButtonStyles.Ghost
    Layout.fillWidth: true
    Layout.preferredHeight: width
    Layout.alignment: Qt.AlignCenter
    display: AbstractButton.TextUnderIcon

    icon.source: source
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: preserveIconColor ? "transparent" : Theme.colors.text

    radius: 0
    backgroundRect.border.width: Theme.borders.b0
}
