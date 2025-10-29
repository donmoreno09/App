import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: textAreaInput

    height: container.implicitHeight

    // Public properties
    property alias enabled: textArea.enabled
    property alias text: textArea.text
    property alias labelText: label.text
    property alias tooltipText: infoBadge.tooltipText
    property alias placeholderText: textArea.placeholderText
    property alias messageText: messageText.text
    property alias characterLimit: characterCounter.limit

    property int variant: UI.InputStyles.Default
    property int minimumHeight: 60

    property alias textArea: textArea
    property alias scrollView: scrollView

    signal textEdited()
    signal textEditingFinished()

    property alias wrapMode: textArea.wrapMode
    property alias selectByMouse: textArea.selectByMouse

    // Internals
    property UI.InputStyle _style: UI.InputStyles.fromVariant(variant)

    component CharacterCounter: Text {
        property int limit: 1000
        text: textArea.length + "/" + limit
        color: _style.textColorDisabled
        font {
            family: Theme.typography.bodySans15Family
            pointSize: Theme.typography.bodySans15Size
            weight: Theme.typography.bodySans15Weight
        }
    }

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
            textArea.forceActiveFocus(Qt.MouseFocusReason)
            mouse.accepted = false
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

            Item { Layout.preferredWidth: Theme.spacing.s2 }

            Label {
                id: label
                color: textAreaInput.enabled ? _style.textColor : _style.textColorDisabled
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
                enabled: textAreaInput.enabled
                visible: tooltipText
            }

            Item { Layout.fillWidth: true } // Spacer

            CharacterCounter {
                id: characterCounter
            }
        }

        // Input Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: minimumHeight + Theme.spacing.s4 * 2
            Layout.maximumHeight: minimumHeight + Theme.spacing.s4 * 2
            topLeftRadius: Theme.radius.sm
            topRightRadius: Theme.radius.sm
            color: _style.background

            UI.OutlineRect { }

            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.margins: Theme.spacing.s4
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextArea {
                    id: textArea
                    color: textAreaInput.enabled ? _style.textColor : _style.textColorDisabled
                    placeholderTextColor: textAreaInput.enabled ? _style.placeholderTextColor : _style.placeholderTextColorDisabled
                    background: Rectangle { color: Theme.colors.transparent }
                    wrapMode: TextArea.Wrap
                    selectByMouse: true

                    font {
                        family: Theme.typography.bodySans25Family
                        pointSize: Theme.typography.bodySans25Size
                        weight: Theme.typography.bodySans25Weight
                    }

                    Accessible.name: placeholderText
                    Accessible.role: Accessible.EditableText

                    onTextChanged: {
                        // Enforce character limit
                        if (text.length > characterCounter.limit) {
                            var cursorPos = cursorPosition
                            text = text.substring(0, characterCounter.limit)
                            cursorPosition = Math.min(cursorPos, text.length)
                        }
                        textAreaInput.textEdited()
                    }
                    onEditingFinished: textAreaInput.textEditingFinished()
                }
            }

            // Bottom border
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: {
                    if (!textArea.enabled) return _style.borderColorDisabled
                    if (textArea.activeFocus) return _style.borderColorFocused
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

            Item { Layout.preferredWidth: Theme.spacing.s2 }

            Button {
                display: AbstractButton.IconOnly
                icon.source: _style.msgIconSource
                icon.color: _style.borderColor
                background: Rectangle { color: Theme.colors.transparent }
                padding: 0
                enabled: false
            }

            Text {
                id: messageText
                color: _style.borderColor

                font {
                    family: Theme.typography.bodySans25Family
                    pointSize: Theme.typography.bodySans25Size
                    weight: Theme.typography.bodySans25Weight
                }
            }
        }
    }
}
