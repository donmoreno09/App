/*!
    \qmltype ButtonGroupTest
    \inqmlmodule App.Playground
    \brief Test component showing ButtonGroup as a simple container with existing Button components.
*/

import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

ScrollView {
    id: testRoot
    clip: true

    ColumnLayout {
        width: testRoot.width
        spacing: Theme.spacing.s8
        anchors.margins: Theme.spacing.s8

        // Header
        Text {
            text: "ButtonGroup - Simple Container Approach"
            font.pixelSize: Theme.typography.size2xl
            font.weight: Theme.typography.weightBold
            color: Theme.colors.text
            Layout.fillWidth: true
        }

        Text {
            text: "ButtonGroup as a simple container - you compose it with your existing Button components"
            font.pixelSize: Theme.typography.sizeSm
            color: Theme.colors.textMuted
            Layout.bottomMargin: Theme.spacing.s4
        }

        // 1. Exact Figma Left Toolbar Recreation
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "1. Left Toolbar from Figma (Map + Home)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Using your existing Button component inside ButtonGroup container"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            UI.ButtonGroup {
                Layout.alignment: Qt.AlignLeft

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/map.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText
                    display: AbstractButton.IconOnly
                    variant: "primary"
                    size: "md"

                    // Compact toolbar size
                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    ToolTip {
                        visible: parent.hovered
                        text: "Map View"
                        delay: 800
                    }
                }

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/home.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    size: "md"

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    ToolTip {
                        visible: parent.hovered
                        text: "Home Base"
                        delay: 800
                    }
                }
            }
        }

        // 2. Exact Figma Right Toolbar Recreation
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "2. Right Toolbar from Figma (Send + Plus + Menu)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Action buttons - no selection state, just click actions"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            UI.ButtonGroup {
                Layout.alignment: Qt.AlignLeft

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    size: "md"

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Send command clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Send Command"
                        delay: 800
                    }
                }

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/plus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.primaryText
                    display: AbstractButton.IconOnly
                    variant: "primary"
                    size: "md"

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Add item clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Add Item"
                        delay: 800
                    }
                }

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/minus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    icon.color: Theme.colors.text
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    size: "md"

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Menu options clicked")

                    ToolTip {
                        visible: parent.hovered
                        text: "Menu Options"
                        delay: 800
                    }
                }
            }
        }

        // 3. Full Layout Recreation
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "3. Full Figma Layout Recreation"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Both toolbars positioned exactly like in your Figma design"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            // Container mimicking your Figma layout
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: Theme.colors.background
                border.color: Theme.colors.textMuted
                border.width: Theme.borders.b1
                radius: Theme.radius.md

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4

                    // Left toolbar
                    UI.ButtonGroup {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/map.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            icon.color: Theme.colors.primaryText
                            display: AbstractButton.IconOnly
                            variant: "primary"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/home.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            icon.color: Theme.colors.text
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Right toolbar
                    UI.ButtonGroup {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/send.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            icon.color: Theme.colors.text
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/plus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            icon.color: Theme.colors.primaryText
                            display: AbstractButton.IconOnly
                            variant: "primary"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/minus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            icon.color: Theme.colors.text
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }
                }
            }
        }

        // 4. Different Container Styles
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "4. Container Style Variations"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s6

                // Dark container
                ColumnLayout {
                    spacing: Theme.spacing.s2

                    Text {
                        text: "Dark Container"
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.text
                    }

                    UI.ButtonGroup {
                        containerColor: Theme.colors.background

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/map.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "primary"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/home.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }
                }

                // More spacing
                ColumnLayout {
                    spacing: Theme.spacing.s2

                    Text {
                        text: "More Spacing"
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.text
                    }

                    UI.ButtonGroup {
                        spacing: Theme.spacing.s2

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/plus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "success"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/send.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "success"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }
                }

                // Different radius
                ColumnLayout {
                    spacing: Theme.spacing.s2

                    Text {
                        text: "Sharp Corners"
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.text
                    }

                    UI.ButtonGroup {
                        containerRadius: Theme.radius.sm

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/minus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "danger"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/send.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "danger"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }
                }
            }
        }

        // 5. Mixed Content Examples
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "5. Mixed Content - Icons and Text"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s6

                // Text buttons
                UI.ButtonGroup {
                    UI.Button {
                        text: "List"
                        variant: "primary"
                        size: "sm"
                    }

                    UI.Button {
                        text: "Grid"
                        variant: "ghost"
                        size: "sm"
                    }

                    UI.Button {
                        text: "Details"
                        variant: "ghost"
                        size: "sm"
                    }
                }

                // Mixed icons and text
                UI.ButtonGroup {
                    UI.Button {
                        icon.source: "qrc:/App/assets/icons/home.svg"
                        icon.width: Theme.icons.sizeSm
                        icon.height: Theme.icons.sizeSm
                        text: "Home"
                        display: AbstractButton.TextBesideIcon
                        variant: "secondary"
                        size: "sm"
                    }

                    UI.Button {
                        icon.source: "qrc:/App/assets/icons/map.svg"
                        icon.width: Theme.icons.sizeSm
                        icon.height: Theme.icons.sizeSm
                        text: "Map"
                        display: AbstractButton.TextBesideIcon
                        variant: "ghost"
                        size: "sm"
                    }
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: Theme.spacing.s8
        }
    }
}
