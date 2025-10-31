import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    // ---- API ----
    property alias source: root.icon.source
    property bool preserveIconColor: false
    property int badgeCount: 0

    // ---- Layout: enforce square ----
    Layout.fillWidth: true
    Layout.preferredHeight: width      // square in Layouts
    implicitHeight: width              // square when standalone

    variant: UI.ButtonStyles.Ghost
    Layout.alignment: Qt.AlignCenter

    // Built-in icon props (still used below)
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: preserveIconColor ? "transparent" : Theme.colors.text

    radius: 0
    backgroundRect.border.width: Theme.borders.b0

    // We'll manage our own content (icon over text) to allow wrapping.
    // NOTE: do not set `display: AbstractButton.TextUnderIcon` anymore.
    padding: Theme.spacing.s2

    // Square area content with wrapping text
    contentItem: Item {
        id: content
        anchors.fill: parent
        clip: true

        // Compute an icon size that fits even on small widths
        readonly property int iconSize: Math.min(root.icon.width, width - 2*root.padding)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: Theme.spacing.s1

            // tiny spacer so text doesn't kiss the bottom edge
            Item { Layout.fillHeight: true; height: Theme.spacing.s0 }

            Image {
                id: iconImg
                source: root.icon.source
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignHCenter

                // Use layout hints so ColumnLayout respects them
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize

                // Crisp scaling for PNGs/JPGs (optional)
                // sourceSize.width:  content.iconSize * Screen.devicePixelRatio
                // sourceSize.height: content.iconSize * Screen.devicePixelRatio
                // smooth: true
                // mipmap: true
            }

            // WRAPPING LABEL
            Text {
                text: root.text
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                maximumLineCount: 2              // cap to avoid overflow
                // Optional theme font/color:
                color: Theme.colors.text
                font.family: Theme.typography.bodySans15Family
                font.pointSize: Theme.typography.fontSize100
            }

            // tiny spacer so text doesn't kiss the bottom edge
            Item { Layout.fillHeight: true; height: Theme.spacing.s0 }
        }
    }

    // Badge (unchanged)
    Rectangle {
        id: badge
        visible: root.badgeCount > 0
        z: Theme.elevation.raised

        width: root.badgeCount > 99 ? Theme.spacing.s6 :
               root.badgeCount > 9  ? Theme.spacing.s5 : Theme.spacing.s4
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

    // Accessibility
    Accessible.name: root.text
}
