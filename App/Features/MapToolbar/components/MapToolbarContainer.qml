import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    default property alias content: contentSlot.data

    Layout.preferredWidth: childrenRect.width + Theme.spacing.s2 * 2
    Layout.preferredHeight: childrenRect.height + Theme.spacing.s2 * 2

    color: Theme.colors.background
    radius: Theme.radius.md
    border.color: Qt.rgba(1, 1, 1, 0.1)
    border.width: Theme.borders.b1

    RowLayout {
        id: contentSlot
        anchors.centerIn: parent
        spacing: Theme.spacing.s1_5
    }
}
