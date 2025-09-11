import QtQuick 6.8

import App.Themes 1.0

Rectangle {
    visible: false
    anchors.fill: parent
    anchors.margins: -Theme.borders.offset2
    color: Theme.colors.transparent
    radius: root.radius + Theme.borders.outline2
    border.width: Theme.borders.outline2
    border.color: Qt.lighter(Theme.colors.textMuted, 1.6)
}
