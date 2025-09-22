import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Rectangle {
    // Set the component which should tell
    // this to show the outline
    property var target: parent

    // Set to the radius of its parent or
    // the component that needs outline
    property real parentRadius: 0

    readonly property bool tabFocused: target.activeFocus && (target.focusReason === Qt.TabFocusReason || target.focusReason === Qt.BacktabFocusReason)

    visible: tabFocused
    anchors.fill: parent
    anchors.margins: -Theme.borders.offset2
    color: Theme.colors.transparent
    radius: parentRadius + Theme.borders.outline2
    border.width: Theme.borders.outline2
    border.color: Qt.lighter(Theme.colors.textMuted, 1.6)
}
