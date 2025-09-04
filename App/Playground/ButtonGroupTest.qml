/*!
    \qmltype ButtonGroupTest
    \inqmlmodule App.Playground
    \brief Test component showing ButtonGroup as a simple container with optional selection management.
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
            text: "ButtonGroup - Simple Container + Selection"
            font.pixelSize: Theme.typography.size2xl
            font.weight: Theme.typography.weightBold
            color: Theme.colors.text
            Layout.fillWidth: true
        }

        Text {
            text: "ButtonGroup as simple container with optional exclusive selection management"
            font.pixelSize: Theme.typography.sizeSm
            color: Theme.colors.textMuted
            Layout.bottomMargin: Theme.spacing.s4
        }

        // 1. Figma Left Toolbar (Exclusive Selection)
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "1. Navigation Toolbar (Exclusive Selection)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "exclusive: true - only one button can be checked at a time"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            UI.ButtonGroup {
                exclusive: true
                Layout.alignment: Qt.AlignLeft

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/map.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    // checkable: true
                    // checked: true

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
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    checkable: true

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

        // 2. Figma Right Toolbar (Action Buttons - No Selection)
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "2. Action Toolbar (No Selection)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "exclusive: false, no checkable - just action buttons"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            UI.ButtonGroup {
                exclusive: false  // No selection management needed
                Layout.alignment: Qt.AlignLeft

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    // No checkable - just action button

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Send command")

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
                    display: AbstractButton.IconOnly
                    variant: "primary"  // Highlighted for emphasis

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Add item")

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
                    display: AbstractButton.IconOnly
                    variant: "ghost"

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    onClicked: console.log("Menu options")

                    ToolTip {
                        visible: parent.hovered
                        text: "Menu Options"
                        delay: 800
                    }
                }
            }
        }

        // 3. Full Figma Recreation
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

                    // Left navigation group (exclusive selection)
                    UI.ButtonGroup {
                        exclusive: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/map.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            checkable: true
                            checked: true
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/home.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            checkable: true
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Right action group (no selection)
                    UI.ButtonGroup {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/send.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/plus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "primary"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/minus.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }
                    }
                }
            }
        }

        // 4. Multiple Selection Example
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "4. Multiple Selection (No Exclusive)"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "exclusive: false with checkable buttons - multiple can be selected"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            UI.ButtonGroup {
                exclusive: false  // Allow multiple selection
                Layout.alignment: Qt.AlignLeft

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/send.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    checkable: true

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    ToolTip {
                        visible: parent.hovered
                        text: "Send Mode"
                        delay: 800
                    }
                }

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/plus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    checkable: true
                    checked: true  // Initially selected

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    ToolTip {
                        visible: parent.hovered
                        text: "Add Mode"
                        delay: 800
                    }
                }

                UI.Button {
                    icon.source: "qrc:/App/assets/icons/minus.svg"
                    icon.width: Theme.icons.sizeLg
                    icon.height: Theme.icons.sizeLg
                    display: AbstractButton.IconOnly
                    variant: "ghost"
                    checkable: true

                    implicitWidth: Theme.spacing.s10
                    implicitHeight: Theme.spacing.s10

                    ToolTip {
                        visible: parent.hovered
                        text: "Remove Mode"
                        delay: 800
                    }
                }
            }
        }

        // 5. Container Style Variations
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "5. Container Style Variations"
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
                        exclusive: true
                        containerColor: Theme.colors.background

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/map.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            checkable: true
                            implicitWidth: Theme.spacing.s10
                            implicitHeight: Theme.spacing.s10
                        }

                        UI.Button {
                            icon.source: "qrc:/App/assets/icons/home.svg"
                            icon.width: Theme.icons.sizeLg
                            icon.height: Theme.icons.sizeLg
                            display: AbstractButton.IconOnly
                            variant: "ghost"
                            checkable: true
                            checked: true
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
            }
        }

        // 6. Mixed Content
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "6. Mixed Content Examples"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s6

                // Text buttons with selection
                UI.ButtonGroup {
                    exclusive: true

                    UI.Button {
                        text: "List"
                        variant: "ghost"
                        size: "sm"
                        checkable: true
                        checked: true
                    }

                    UI.Button {
                        text: "Grid"
                        variant: "ghost"
                        size: "sm"
                        checkable: true
                    }

                    UI.Button {
                        text: "Details"
                        variant: "ghost"
                        size: "sm"
                        checkable: true
                    }
                }

                // Mixed icons and text
                UI.ButtonGroup {
                    exclusive: true

                    UI.Button {
                        icon.source: "qrc:/App/assets/icons/home.svg"
                        icon.width: Theme.icons.sizeSm
                        icon.height: Theme.icons.sizeSm
                        text: "Home"
                        display: AbstractButton.TextBesideIcon
                        variant: "ghost"
                        size: "sm"
                        checkable: true
                    }

                    UI.Button {
                        icon.source: "qrc:/App/assets/icons/map.svg"
                        icon.width: Theme.icons.sizeSm
                        icon.height: Theme.icons.sizeSm
                        text: "Map"
                        display: AbstractButton.TextBesideIcon
                        variant: "ghost"
                        size: "sm"
                        checkable: true
                        checked: true
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
