import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DatePickerActions
    \brief Action buttons (Clear/Apply)
*/

RowLayout {
    id: root

    // Props
    property string mode: "single"
    property bool canClear: false
    property bool canApply: false

    // Signals
    signal clearClicked()
    signal applyClicked()

    spacing: Theme.spacing.s3

     Item { Layout.fillWidth: true }

    // Clear button
    UI.Button {
        Layout.preferredWidth: 86
        Layout.alignment: Qt.AlignHCenter
        size: "md"
        variant: UI.ButtonStyles.Ghost
        enabled: root.canClear

        onClicked: root.clearClicked()

        background: Rectangle {
            color: Theme.colors.transparent
            radius: Theme.radius.md
            border.width: 0
            border.color: "transparent"
        }

        contentItem: Text {
            anchors.centerIn: parent
            text: qsTr("Clear")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: root.canClear ? Theme.colors.text : Theme.colors.textMuted
        }
    }

    // Apply button
    UI.Button {
        Layout.preferredWidth: 86
        size: "md"
        variant: UI.ButtonStyles.Primary
        enabled: root.canApply

        onClicked: root.applyClicked()

        background: Rectangle {
            color: root.canApply ? Theme.colors.accent500 : Theme.colors.secondary500
            radius: Theme.radius.md
        }

        contentItem: Text {
            anchors.centerIn: parent
            text: qsTr("Apply")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: root.canApply ? Theme.colors.white500 : Theme.colors.textMuted
        }
    }

     Item { Layout.fillWidth: true }
}
