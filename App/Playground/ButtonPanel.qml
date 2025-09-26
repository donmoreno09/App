import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Button Test"))

    ScrollView {
        id: sv
        anchors.fill: parent
        contentWidth: availableWidth

        Frame {
            padding: Theme.spacing.s6
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s8

                // Header
                Text {
                    text: "Button Component Variants"
                    font.pixelSize: Theme.typography.fontSize300
                    font.weight: Theme.typography.weightBold
                    color: Theme.colors.text
                    Layout.fillWidth: true
                }

                // Section 1: Text Buttons with Label & Icon
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "1. Text Buttons (Label + Icon)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary variant row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }
                    }

                    // Secondary variant row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Secondary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }
                    }

                    // Danger variant row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 2: Icon-Only Buttons (Square)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "2. Icon-Only Buttons (Square)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Secondary icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Secondary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Danger icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 3: Icon-Only Buttons (Circle)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "3. Icon-Only Buttons (Circle)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 80
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 4: Size Variants
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "4. Size Variants"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Small"
                            size: "sm"
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Medium"
                            size: "md"
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Large"
                            size: "lg"
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 5: Pill Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "5. Pill Buttons"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            radius: Theme.radius.full(height)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            radius: Theme.radius.full(height)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            radius: Theme.radius.full(height)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            radius: Theme.radius.full(height)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            enabled: false
                            radius: Theme.radius.full(height)
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 6: Interactive State Test
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "6. Interactive State Test"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Text {
                        text: "Hover, press, and focus these buttons to test states"
                        font.pixelSize: Theme.typography.fontSize150
                        color: Theme.colors.textMuted
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Hover Me"
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Press Me"
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Success
                            text: "Focus Me"
                        }

                        UI.Button {
                            id: activeButton
                            variant: UI.ButtonStyles.Primary
                            text: activeButton.active ? "Active" : "Inactive"
                            active: activeButton.checked
                            checkable: true
                        }
                    }
                }

                // Spacer
                Item { Layout.preferredHeight: Theme.spacing.s6 }
            }
        }
    }
}
