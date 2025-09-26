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
                    text: "Button Component - Figma Design System"
                    font.pixelSize: Theme.typography.fontSize300
                    font.weight: Theme.typography.weightBold
                    color: Theme.colors.text
                    Layout.fillWidth: true
                }

                // Section 1: Text + Icon Buttons (All States)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "1. Text + Icon Buttons (Label + Icon)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary - All States
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
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
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            hoverEnabled: true
                            palette.buttonText: Qt.lighter(_currentTextColor, 1.1)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            opacity: 0.7
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            opacity: 0.5
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeSm
                        }
                    }

                    // Secondary - All States
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Secondary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                        }
                    }

                    // Danger - All States
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            text: "Label"
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 2: Icon Only Square Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "2. Icon Only (Square) - 32x32px"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary Square Icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Secondary Square Icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Secondary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Danger Square Icons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 3: Icon Only Circle Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "3. Icon Only (Circle) - 32x32px"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary Circle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }
                    }

                    // Danger Circle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger:"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 100
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/x-close.svg"
                            icon.width: Theme.icons.sizeSm
                            icon.height: Theme.icons.sizeSm
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }
                    }
                }

                UI.HorizontalDivider { Layout.fillWidth: true }

                // Section 3.5: Diamond Star Icon Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "3.5. Diamond Star Icon Buttons"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Primary Diamond Stars - Square
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary (Square):"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 120
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Primary Diamond Stars - Circle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Primary (Circle):"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 120
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Primary
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }
                    }

                    // Danger Diamond Stars - Square
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger (Square):"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 120
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                        }
                    }

                    // Danger Diamond Stars - Circle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        Text {
                            text: "Danger (Circle):"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                            Layout.preferredWidth: 120
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.8
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.6
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                            opacity: 0.4
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Danger
                            display: AbstractButton.IconOnly
                            enabled: false
                            icon.source: "qrc:/App/assets/icons/diamond-star.svg"
                            icon.width: Theme.icons.sizeMd
                            icon.height: Theme.icons.sizeMd
                            Layout.preferredWidth: Theme.spacing.s8
                            Layout.preferredHeight: Theme.spacing.s8
                            radius: Theme.radius.circle(Theme.spacing.s8, Theme.spacing.s8)
                        }
                    }
                }

                // Section 4: Pill Buttons (Figma Image 3)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "4. Pill Buttons (Secondary Variant)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s2

                        // Row 1
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

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
                        }

                        // Row 2 - with active state
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

                            UI.Button {
                                variant: UI.ButtonStyles.Primary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                active: true
                            }

                            UI.Button {
                                variant: UI.ButtonStyles.Secondary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                enabled: false
                            }
                        }

                        // Row 3
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

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
                        }

                        // Row 4 - with active state
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

                            UI.Button {
                                variant: UI.ButtonStyles.Primary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                active: true
                            }

                            UI.Button {
                                variant: UI.ButtonStyles.Secondary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                enabled: false
                            }
                        }

                        // Row 5
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

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
                        }

                        // Row 6 - with active state
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.s2

                            UI.Button {
                                variant: UI.ButtonStyles.Primary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                active: true
                            }

                            UI.Button {
                                variant: UI.ButtonStyles.Secondary
                                text: "Label"
                                radius: Theme.radius.full(height)
                                enabled: false
                            }
                        }
                    }
                }

                // Spacer
                Item { Layout.preferredHeight: Theme.spacing.s6 }
            }
        }
    }
}
