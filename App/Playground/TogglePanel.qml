import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Toggle Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                // 1. Basic Toggle States
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "1. Basic Toggle States"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Row {
                        spacing: Theme.spacing.s6

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Off"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                checked: false
                            }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "On"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                checked: true
                            }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Disabled"
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

                // 2. Size Variants
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "2. Size Variants"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Row {
                        spacing: Theme.spacing.s6

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Small (32x18)"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                size: "sm"
                                checked: true
                            }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Medium (40x22)"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                            }
                            UI.Toggle {
                                size: "md"
                                checked: true
                            }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Large (48x26)"
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

                // 3. Toggles with Labels
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "3. Toggles with Labels"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Column {
                        spacing: Theme.spacing.s4

                        UI.Toggle {
                            leftLabel: "Enable notifications"
                            checked: true
                        }

                        UI.Toggle {
                            rightLabel: "Auto-save"
                            checked: false
                        }

                        UI.Toggle {
                            leftLabel: "Dark mode"
                            checked: false
                        }

                        UI.Toggle {
                            leftLabel: "Location services"
                            checked: true
                        }
                    }
                }
            }
        }
    }
}
