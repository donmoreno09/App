import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    property alias source: root.icon.source
    property bool preserveIconColor: false

    property int badgeCount: 0

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

    Rectangle {
        id: badge
        visible: root.badgeCount > 0
        z: Theme.elevation.raised

        width: root.badgeCount > 99 ? Theme.spacing.s6 :
               root.badgeCount > 9 ? Theme.spacing.s5 : Theme.spacing.s4
        height: Theme.spacing.s4

        radius: Theme.radius.circle(width, height)
        color: Theme.colors.error500

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.spacing.s5
        anchors.topMargin: Theme.spacing.s3

        Text {
            anchors.centerIn: parent
            text: root.badgeCount > 99 ? "99+" : root.badgeCount
            color: Theme.colors.text
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.fontSize100
            font.weight: Theme.typography.bodySans15StrongWeight
        }
    }
}
