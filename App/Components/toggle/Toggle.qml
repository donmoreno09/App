/*!
    \qmltype Toggle
    \inqmlmodule App.Components
    \brief Clean toggle/switch component with variant-based styling.
*/

import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0

Switch {
    id: root

    property string size: "md"
    property string leftLabel: ""
    property string rightLabel: ""
    property int variant: ToggleStyles.Primary

    readonly property var _sizeStyles: ToggleStyles.sizeConfig(size)

    readonly property ToggleStyle _style: ToggleStyles.fromVariant(variant)

    implicitWidth: container.implicitWidth
    implicitHeight: _sizeStyles.height

    indicator: Item {
        width: container.implicitWidth
        height: container.implicitHeight

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onPressed: function (mouse) {
                root.checked = !root.checked
            }
        }

        RowLayout {
            id: container
            spacing: Theme.spacing.s2

            Text {
                visible: root.leftLabel !== ""
                text: root.leftLabel
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.text
            }

            Rectangle {
                width: root._sizeStyles.width
                height: root._sizeStyles.height

                color: {
                    if (!root.enabled) return root._style.backgroundDisabled
                    return root.checked ? root._style.backgroundChecked : root._style.background
                }
                radius: height / 2

                // Toggle knob
                Rectangle {
                    x: root.checked ? parent.width - width - 2 : 2
                    y: (parent.height - height) / 2
                    width: root._sizeStyles.knobSize
                    height: root._sizeStyles.knobSize
                    radius: height / 2
                    color: root.enabled ? root._style.knob : root._style.knobDisabled

                    Behavior on x {
                        NumberAnimation { duration: Theme.motion.panelTransitionMs; easing.type: Theme.motion.panelTransitionEasing }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.motion.panelTransitionMs; easing.type: Theme.motion.panelTransitionEasing }
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.motion.panelTransitionMs; easing.type: Theme.motion.panelTransitionEasing }
                }
            }

            Text {
                visible: root.rightLabel !== ""
                text: root.rightLabel
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.text
            }
        }
    }
}
