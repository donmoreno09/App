import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0

import ".." as UI

Item {
    id: input

    width: container.implicitWidth
    height: container.implicitHeight

    // Public properties
    property alias enabled: textField.enabled
    property alias text: textField.text
    property alias labelText: label.text
    property alias tooltipText: infoBadge.tooltipText
    property alias placeholderText: textField.placeholderText
    property alias messageText: messageText.text

    property string iconSource: ""
    property int variant: InputStyles.Default

    property alias textField: textField

    signal textEdited()
    signal textEditingFinished()

    // Forward other TextField's properties for convenience
    property alias echoMode: textField.echoMode
    property alias inputMask: textField.inputMask
    property alias maximumLength: textField.maximumLength
    property alias validator: textField.validator

    // Internals
    property InputStyle _style: InputStyles.fromVariant(variant)

    component InfoBadge: Button {
        property string tooltipText: ""

        display: AbstractButton.IconOnly
        icon.source: "qrc:/App/assets/icons/circle-info.svg"
        icon.color: Theme.colors.text
        background: Rectangle { color: Theme.colors.transparent }
        padding: 0

        UI.OutlineRect { }

        ToolTip.text: tooltipText
        ToolTip.visible: tooltipText && (hovered || pressed || activeFocus)
        ToolTip.delay: Application.styleHints.mousePressAndHoldInterval
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        onPressed: function (mouse) {
            textField.forceActiveFocus(Qt.MouseFocusReason)
            mouse.accepted = false // let the text field also handle the click
        }
    }

    ColumnLayout {
        id: container

        anchors.fill: parent
        spacing: Theme.spacing.s3

        // Label Section
        RowLayout {
            Layout.fillWidth: true
            visible: label.text !== ""

            Item { Layout.preferredWidth: Theme.spacing.s2 } // TODO: Replace with HorizontalPadding

            Label {
                id: label
                color: input.enabled ? _style.textColor : _style.textColorDisabled
                font {
                    family: Theme.typography.bodySans25Family
                    pointSize: Theme.typography.bodySans25Size
                    weight: Theme.typography.bodySans25Weight
                }
            }

            InfoBadge {
                id: infoBadge
                icon.width: Theme.icons.sizeSm
                icon.height: Theme.icons.sizeSm
                icon.color: _style.textColor
                enabled: input.enabled
                visible: tooltipText
            }
        }

        // Input Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: textField.height + Theme.spacing.s4 * 2
            topLeftRadius: Theme.radius.sm
            topRightRadius: Theme.radius.sm
            color: _style.background

            UI.OutlineRect { target: textField }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s4
                anchors.rightMargin: Theme.spacing.s4
                spacing: Theme.spacing.s1

                TextField {
                    id: textField
                    Layout.fillWidth: true
                    color: input.enabled ? _style.textColor : _style.textColorDisabled
                    placeholderTextColor: input.enabled ? _style.placeholderTextColor : _style.placeholderTextColorDisabled
                    background: Rectangle { color: Theme.colors.transparent }

                    font {
                        family: Theme.typography.bodySans25Family
                        pointSize: Theme.typography.bodySans25Size
                        weight: Theme.typography.bodySans25Weight
                    }

                    Accessible.name: placeholderText
                    Accessible.role: Accessible.EditableText

                    onTextEdited: input.textEdited()
                    onEditingFinished: input.textEditingFinished()
                }

                Button {
                    id: textFieldIcon
                    display: AbstractButton.IconOnly
                    icon.source: iconSource
                    icon.color: input.enabled ? _style.iconColor : _style.iconColorDisabled
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    enabled: input.enabled
                    visible: iconSource
                    background: Rectangle { color: Theme.colors.transparent }
                    padding: 0

                    UI.OutlineRect { }
                }
            }

            // Bottom border
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: {
                    if (!textField.enabled) return _style.borderColorDisabled
                    if (textField.activeFocus) return _style.borderColorFocused
                    return _style.borderColor
                }

                height: Theme.spacing.s0_5

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutInCubic }
                }
            }
        }

        // Message Section
        RowLayout {
            visible: messageText.text

            Item { Layout.preferredWidth: Theme.spacing.s2 } // TODO: Replace with HorizontalPadding

            Button {
                display: AbstractButton.IconOnly
                icon.source: _style.msgIconSource
                icon.color: _style.borderColor
                background: Rectangle { color: Theme.colors.transparent }
                padding: 0
                enabled: false // Make non-interactive
            }

            Text {
                id: messageText
                color:  _style.borderColor

                font {
                    family: Theme.typography.bodySans25Family
                    pointSize: Theme.typography.bodySans25Size
                    weight: Theme.typography.bodySans25Weight
                }
            }
        }
    }
}
