import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.Revision, qsTr("Toggle Test"))

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.s8

            // Header
            Text {
                text: (TranslationManager.revision, qsTr("Toggle Component Test"))
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize300
                font.weight: Theme.typography.weightBold
                color: Theme.colors.text
                Layout.fillWidth: true
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 1. Basic Toggles
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("1. Basic Toggle States"))
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                RowLayout {
                    spacing: Theme.spacing.s6

                    ColumnLayout {
                        spacing: Theme.spacing.s2
                        Text {
                            text: (TranslationManager.revision, qsTr("Off"))
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }
                        UI.Toggle {
                            checked: false
                        }
                    }

                    ColumnLayout {
                        spacing: Theme.spacing.s2
                        Text {
                            text: (TranslationManager.revision, qsTr("On"))
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }
                        UI.Toggle {
                            checked: true
                        }
                    }

                    ColumnLayout {
                        spacing: Theme.spacing.s2
                        Text {
                            text: (TranslationManager.revision, qsTr("Disabled"))
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }
                        UI.Toggle {
                            enabled: false
                            checked: true
                        }
                    }
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 2. Size Variants
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("2. Size Variants"))
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Column {
                    spacing: Theme.spacing.s4

                    RowLayout {
                        spacing: Theme.spacing.s6
                        anchors.left: parent.left

                        ColumnLayout {
                            spacing: Theme.spacing.s2
                            Text {
                                text: (TranslationManager.revision, qsTr("Small (32x18)"))
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                size: "sm"
                                checked: true
                            }
                        }

                        ColumnLayout {
                            spacing: Theme.spacing.s2
                            Text {
                                text: (TranslationManager.revision, qsTr("Medium (40x22)"))
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                size: "md"
                                checked: true
                            }
                        }

                        ColumnLayout {
                            spacing: Theme.spacing.s2
                            Text {
                                text: (TranslationManager.revision, qsTr("Large (48x26)"))
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                size: "lg"
                                checked: true
                            }
                        }
                    }
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 3. With Labels (Like Figma Design)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("3. Toggles with Labels"))
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                ColumnLayout {
                    spacing: Theme.spacing.s4

                    // Left label only
                    UI.Toggle {
                        leftLabel: (TranslationManager.revision, qsTr("Enable notifications"))
                        checked: true
                    }

                    // Right label only
                    UI.Toggle {
                        rightLabel: (TranslationManager.revision, qsTr("Auto-save"))
                        checked: false
                    }

                    // Settings style labels
                    UI.Toggle {
                        leftLabel: (TranslationManager.revision, qsTr("Dark mode"))
                        checked: false
                    }

                    UI.Toggle {
                        leftLabel: (TranslationManager.revision, qsTr("Location services"))
                        checked: true
                    }
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }
        }
    }

}
