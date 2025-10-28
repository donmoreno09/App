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

    property int variant: UI.InputStyles.Default

    property alias enabled: comboBox.enabled
    property alias labelText: label.text
    property alias currentIndex: comboBox.currentIndex
    property alias currentText: comboBox.currentText
    property alias currentValue: comboBox.currentValue
    property alias displayText: comboBox.displayText
    property alias comboBox: comboBox
    property alias textRole: comboBox.textRole
    property alias valueRole: comboBox.valueRole

    property alias model: comboBox.model

    signal activated(int index)

    // Internals
    property UI.InputStyle _style: UI.InputStyles.fromVariant(variant)

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
                visible: label.text !== ""
                color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
                font {
                    family: Theme.typography.bodySans25Family
                    pointSize: Theme.typography.bodySans25Size
                    weight: Theme.typography.bodySans25Weight
                }
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
                color: _style.background
                radius: Theme.radius.sm

                UI.OutlineRect { target: comboBox }

                // Bottom border
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Theme.spacing.s0_5
                    color: {
                        if (!comboBox.enabled) return _style.borderColorDisabled
                        if (comboBox.activeFocus) return _style.borderColor
                        return _style.borderColor
                    }
                }
            }

            // Content Item
            contentItem: RowLayout {
                Item { Layout.preferredWidth: Theme.spacing.s4 }

                Text {
                    text: {
                        if (comboBox.currentIndex >= 0) {
                            var item = comboBox.model[comboBox.currentIndex]
                            if (item && typeof item === 'object' && 'id' in item && 'name' in item) {
                                return item.id + " - " + item.name
                            }
                        }
                        return comboBox.displayText
                    }
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

                Item { Layout.preferredWidth: Theme.spacing.s4 }
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
                    text: {
                        var item = comboBox.model[index]
                        if (item && typeof item === 'object' && 'id' in item && 'name' in item) {
                            return item.id + " - " + item.name
                        }
                        return comboBox.textAt(index)
                    }
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
