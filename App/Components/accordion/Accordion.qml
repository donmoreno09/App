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
            color: root.backgroundColor
            radius: root.expanded ? 0 : Theme.radius.sm
            border.width: Theme.borders.b1
            border.color: root.borderColor

            // Top corners rounded, bottom square when expanded
            topLeftRadius: Theme.radius.sm
            topRightRadius: Theme.radius.sm
            bottomLeftRadius: root.expanded ? 0 : Theme.radius.sm
            bottomRightRadius: root.expanded ? 0 : Theme.radius.sm

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
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
                            duration: Theme.motion.transitionMs
                            easing.type: Easing.InOutQuad
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
            Layout.preferredHeight: root.expanded ? contentSlot.implicitHeight : 0
            visible: Layout.preferredHeight > 0
            color: root.backgroundColor
            border.width: Theme.borders.b1
            border.color: root.borderColor
            bottomLeftRadius: Theme.radius.sm
            bottomRightRadius: Theme.radius.sm

            // Remove top border to connect with header
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: Theme.borders.b1
                color: root.backgroundColor
            }

            clip: true

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: Theme.motion.transitionMs
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                id: contentSlot
                anchors.fill: parent
                anchors.margins: Theme.spacing.s4
            }
        }
    }
}
