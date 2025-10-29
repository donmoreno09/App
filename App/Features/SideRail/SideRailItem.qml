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
    property color badgeColor: Theme.colors.error500
    property color badgeTextColor: Theme.colors.white

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

        width: root.badgeCount > 99 ? Theme.spacing.s7 :
               root.badgeCount > 9 ? Theme.spacing.s6 : Theme.spacing.s5
        height: Theme.spacing.s5

        radius: Theme.radius.circle(width, height)
        color: root.badgeColor

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.spacing.s4
        anchors.topMargin: Theme.spacing.s4

        Text {
            anchors.centerIn: parent
            text: root.badgeCount > 99 ? "99+" : root.badgeCount
            color: root.badgeTextColor
            font.family: Theme.typography.bodySans15Family
            font.pointSize: Theme.typography.bodySans15Size
            font.weight: Theme.typography.bodySans15StrongWeight
        }
    }
}
