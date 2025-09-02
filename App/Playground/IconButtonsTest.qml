import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

// Focused icon button test component - 6 core icons with proper theming
Item {
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: Theme.spacing.s8

        // Header
        Text {
            text: "Icon Button Components"
            font.pixelSize: Theme.typography.size2xl
            font.weight: Theme.typography.weightBold
            color: Theme.colors.text
            Layout.fillWidth: true
        }

        // 1. Core Icon Set
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "1. Core Icon Set (6 Icons)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Primary set of icons using base Button component with proper theme sizing"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                // Clipboard/Mission icon with text (vertical layout like Figma)
                UI.Button {
                    variant: "primary"
                    display: AbstractButton.TextUnderIcon  // Icon on top, text below

                    icon.source: "icons/clipboard.svg"
                    icon.width: Theme.icons.sizeLg    // 24px from theme
                    icon.height: Theme.icons.sizeLg   // 24px from theme
                    icon.color: Theme.colors.primaryText

                    text: "Mission"

                    onClicked: console.log("Mission clipboard clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Mission Clipboard"
                        delay: 800
                    }
                }

                // Map icon
                UI.Button {
                    variant: "secondary"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/map.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text

                    onClicked: console.log("Map clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Navigation Map"
                        delay: 800
                    }
                }

                // Home icon
                UI.Button {
                    variant: "ghost"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/home.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text


                    onClicked: console.log("Home clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Home Base"
                        delay: 800
                    }
                }

                // Send icon
                UI.Button {
                    variant: "ghost"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text


                    onClicked: console.log("Send clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Send Command"
                        delay: 800
                    }
                }

                // Plus icon
                UI.Button {
                    variant: "success"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/plus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText


                    onClicked: console.log("Add clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Add Item"
                        delay: 800
                    }
                }

                // Minus icon
                UI.Button {
                    variant: "danger"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/minus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText


                    onClicked: console.log("Remove clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Remove Item"
                        delay: 800
                    }
                }
            }
        }

        // 2. Size Variants
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "2. Icon Button Sizes"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Using theme icon sizes: sm (16px), md (20px), lg (24px)"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Row {
                spacing: Theme.spacing.s4
                Layout.alignment: Qt.AlignLeft

                // Small (32px button, 16px icon)
                UI.Button {
                    variant: "secondary"
                    size: "sm"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/plus.svg"
                    icon.width: Theme.icons.sizeSm   // 16px
                    icon.height: Theme.icons.sizeSm
                    icon.color: Theme.colors.text

                    ToolTip {
                        visible: parent.hovered
                        text: "Small (32px)"
                        delay: 800
                    }
                }

                // Medium (36px button, 20px icon)
                UI.Button {
                    variant: "secondary"
                    size: "md"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/plus.svg"
                    icon.width: Theme.icons.sizeMd   // 20px
                    icon.height: Theme.icons.sizeMd
                    icon.color: Theme.colors.text

                    implicitWidth: 36                // Custom size
                    implicitHeight: 36

                    ToolTip {
                        visible: parent.hovered
                        text: "Medium (36px)"
                        delay: 800
                    }
                }

                // Large (40px button, 24px icon)
                UI.Button {
                    variant: "secondary"
                    size: "lg"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/plus.svg"
                    icon.width: Theme.icons.sizeLg   // 24px
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text

                    ToolTip {
                        visible: parent.hovered
                        text: "Large (40px)"
                        delay: 800
                    }
                }
            }
        }

        // 3. Mission Interface Example
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "3. Mission Interface Navigation"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Vertical navigation rail (80x80px as per Figma specs)"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Rectangle {
                width: 80  // Fixed width from Figma
                height: 380
                color: Theme.colors.surface
                border.color: Theme.colors.text
                border.width: Theme.borders.b1
                radius: Theme.radius.md
                Layout.alignment: Qt.AlignLeft

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.s4
                    spacing: Theme.spacing.s3

                    // Mission clipboard (active)
                    UI.Button {
                        variant: "primary"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/clipboard.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.primaryText



                        radius: Theme.radius.md

                        onClicked: console.log("Mission selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Mission"
                            delay: 800
                        }
                    }

                    // Map
                    UI.Button {
                        variant: "ghost"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/map.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.text



                        radius: Theme.radius.md

                        onClicked: console.log("Map selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Map"
                            delay: 800
                        }
                    }

                    // Home
                    UI.Button {
                        variant: "ghost"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/home.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.text



                        radius: Theme.radius.md

                        onClicked: console.log("Home selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Home"
                            delay: 800
                        }
                    }

                    // Send
                    UI.Button {
                        variant: "ghost"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/send.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.text



                        radius: Theme.radius.md

                        onClicked: console.log("Send selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Send"
                            delay: 800
                        }
                    }

                    // Plus
                    UI.Button {
                        variant: "ghost"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/plus.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.text



                        radius: Theme.radius.md

                        onClicked: console.log("Add selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Add"
                            delay: 800
                        }
                    }

                    // Minus
                    UI.Button {
                        variant: "ghost"
                        display: AbstractButton.IconOnly

                        icon.source: "icons/minus.svg"
                        icon.width: Theme.icons.sizeLg
                        icon.height: Theme.icons.sizeLg
                        icon.color: Theme.colors.text



                        radius: Theme.radius.md

                        onClicked: console.log("Remove selected")

                        ToolTip {
                            visible: parent.hovered
                            text: "Remove"
                            delay: 800
                        }
                    }
                }
            }
        }

        // 4. State Testing
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "4. Icon Button States"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Testing enabled, disabled, and interactive states"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                // Enabled
                UI.Button {
                    variant: "primary"
                    display: AbstractButton.IconOnly

                    icon.source: "icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText


                    onClicked: console.log("Enabled button clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Enabled"
                        delay: 800
                    }
                }

                // Disabled
                UI.Button {
                    variant: "primary"
                    enabled: false
                    display: AbstractButton.IconOnly

                    icon.source: "icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText


                    ToolTip {
                        visible: parent.hovered && parent.enabled
                        text: "Disabled"
                        delay: 800
                    }
                }

                // Toggle state
                UI.Button {
                    id: toggleButton
                    variant: isActive ? "success" : "secondary"
                    display: AbstractButton.IconOnly
                    property bool isActive: false

                    icon.source: isActive ? "icons/minus.svg" : "icons/plus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: isActive ? Theme.colors.primaryText : Theme.colors.text


                    onClicked: {
                        isActive = !isActive
                        console.log("Toggle: " + (isActive ? "ACTIVE" : "INACTIVE"))
                    }

                    ToolTip {
                        visible: parent.hovered
                        text: parent.isActive ? "Remove Mode" : "Add Mode"
                        delay: 800
                    }
                }
            }
        }
    }
}
