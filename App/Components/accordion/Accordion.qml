import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    // Public properties
    property alias headerContent: headerSlot.data
    property alias content: contentSlot.data
    property bool expanded: false
    property int variant: AccordionStyles.Default
    property int headerHeight: Theme.spacing.s12

    signal clicked()
    signal toggled(bool expanded)

    // Internals
    property AccordionStyle _style: AccordionStyles.fromVariant(variant)

    ColumnLayout {
        id: container
        anchors.fill: parent
        spacing: 0

        // Header (always visible, clickable)
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            color: headerMouse.containsMouse ? _style.backgroundHover : _style.backgroundColor
            radius: root.expanded ? 0 : Theme.radius.sm
            border.width: Theme.borders.b1
            border.color: Theme.colors.grey500

            // Top corners rounded, bottom square when expanded
            topLeftRadius: Theme.radius.sm
            topRightRadius: Theme.radius.sm
            bottomLeftRadius: root.expanded ? 0 : Theme.radius.sm
            bottomRightRadius: root.expanded ? 0 : Theme.radius.sm

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    root.expanded = !root.expanded
                    root.toggled(root.expanded)
                    root.clicked()
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s4
                anchors.rightMargin: Theme.spacing.s4
                spacing: Theme.spacing.s4

                // Chevron indicator
                Image {
                    Layout.preferredWidth: Theme.icons.sizeSm
                    Layout.preferredHeight: Theme.icons.sizeSm
                    source: "qrc:/App/assets/icons/chevron-down-combobox.svg"
                    rotation: root.expanded ? 0 : -90

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Theme.motion.panelTransitionMs
                            easing.type: Theme.motion.panelTransitionEasing
                        }
                    }
                }

                // Header content slot
                Item {
                    id: headerSlot
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        // Content area (expandable)
        Rectangle {
            id: contentContainer
            Layout.fillWidth: true
            Layout.preferredHeight: root.expanded ? (contentSlot.childrenRect.height + Theme.spacing.s4 * 2) : 0
            visible: Layout.preferredHeight > 0
            color: Theme.colors.surface
            border.width: Theme.borders.b1
            border.color: Theme.colors.grey500
            bottomLeftRadius: Theme.radius.sm
            bottomRightRadius: Theme.radius.sm

            clip: true

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: Theme.motion.panelTransitionMs
                    easing.type: Theme.motion.panelTransitionEasing
                }
            }

            // Remove top border to connect with header
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: -1
                height: Theme.borders.b1 + 1
                color: _style.backgroundColor
                z: 1
            }

            // Content slot - NO anchors.fill, just position it
            Item {
                id: contentSlot
                x: Theme.spacing.s4
                y: Theme.spacing.s4
                width: parent.width - Theme.spacing.s4 * 2
                height: childrenRect.height
            }
        }
    }
}
