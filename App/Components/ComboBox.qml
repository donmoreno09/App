import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    property alias enabled: comboBox.enabled
    property alias labelText: label.text
    property alias currentIndex: comboBox.currentIndex
    property alias currentValue: comboBox.currentValue
    property alias displayText: comboBox.displayText
    property alias comboBox: comboBox

    property alias model: comboBox.model

    signal activated(int index)

    ColumnLayout {
        id: container
        anchors.fill: parent
        spacing: Theme.spacing.s3

        Label {
            id: label
            visible: label.text !== ""
            color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }

        // ComboBox Section
        ComboBox {
            id: comboBox
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s12
            indicator: null

            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }

            onActivated: function(index) {
                root.activated(index)
            }

            // Background
            background: Rectangle {
                color: {
                    if (!comboBox.enabled) return Theme.colors.textMuted
                    if (comboBox.pressed) return Qt.darker(Theme.colors.surface, 1.5)
                    if (comboBox.hovered) return Theme.colors.surface
                    return Theme.colors.transparent
                }
                radius: Theme.radius.sm

                UI.OutlineRect { target: comboBox }

                // Bottom border
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Theme.spacing.s0_5
                    color: {
                        if (!comboBox.enabled) return Theme.colors.grey300
                        if (comboBox.activeFocus) return Theme.colors.primary500
                        if (comboBox.hovered) return Theme.colors.grey400
                        return Theme.colors.grey300
                    }
                }
            }

            // Content Item
            contentItem: RowLayout {

                Item { Layout.preferredWidth: Theme.spacing.s2}

                Text {
                    text: comboBox.displayText
                    color: comboBox.enabled ? Theme.colors.text : Theme.colors.textMuted
                    font: comboBox.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                UI.HorizontalSpacer {}

                Image {
                    Layout.preferredWidth: Theme.icons.sizeSm
                    Layout.preferredHeight: Theme.icons.sizeSm
                    source: "qrc:/App/assets/icons/chevron-down-combobox.svg"
                    rotation: comboBox.popup.visible ? 180 : 0
                }

                Item { Layout.preferredWidth: Theme.spacing.s2}
            }

            // Popup
            popup: Popup {
                y: comboBox.height + Theme.spacing.s1
                width: comboBox.width
                implicitHeight: Math.min(contentItem.implicitHeight, Theme.spacing.s10 * 5) + topPadding + bottomPadding
                padding: Theme.spacing.s2
                transformOrigin: Popup.Top

                background: Rectangle {
                    color: Theme.colors.surface
                    radius: Theme.radius.sm
                    border.width: Theme.borders.b1
                    border.color: Theme.colors.grey300
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: comboBox.delegateModel
                    currentIndex: comboBox.highlightedIndex

                    ScrollBar.vertical: ScrollBar {}
                }
            }

            // Delegate (item nel popup)
            delegate: ItemDelegate {
                width: comboBox.popup.width
                height: Theme.spacing.s10

                contentItem: Text {
                    text: modelData
                    color: Theme.colors.text
                    font: comboBox.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: Theme.spacing.s3
                }

                background: Rectangle {
                    color: {
                        if(parent.highlighted) return Qt.darker(Theme.colors.surface, 1.5)
                        if(parent.hovered) return Qt.darker(Theme.colors.surface, 1.5)
                        return Theme.colors.transparent
                    }
                    radius: Theme.radius.sm
                }
            }
        }
    }
}
