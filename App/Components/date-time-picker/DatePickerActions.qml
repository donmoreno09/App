import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

/*!
    \qmltype DatePickerActions
    \brief Action buttons for DatePicker (Clear/Apply)
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

    // Clear button
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.spacing.s10
        color: Theme.colors.transparent

        Text {
            anchors.centerIn: parent
            text: "Clear"
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: root.canClear ? Theme.colors.text : Theme.colors.textMuted
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.canClear
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (enabled) {
                    root.clearClicked()
                }
            }
        }
    }

    // Apply button
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.spacing.s10
        color: root.canApply ? Theme.colors.accent500 : Theme.colors.secondary500
        radius: Theme.radius.sm

        Text {
            anchors.centerIn: parent
            text: "Apply"
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: root.canApply ? Theme.colors.white500 : Theme.colors.textMuted
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.canApply
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (enabled) {
                    root.applyClicked()
                }
            }
        }

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
