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
            anchors.margins: Theme.spacing.s6
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

                Row {
                    spacing: Theme.spacing.s6

                    Column {
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

                    Column {
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

                    Column {
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

                    Row {
                        spacing: Theme.spacing.s6
                        anchors.left: parent.left

                        Column {
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

                        Column {
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

                        Column {
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

                Column {
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

            // 4. Interactive Example
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("4. Interactive Settings Panel"))
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: settingsColumn.implicitHeight + Theme.spacing.s8
                    color: Theme.colors.primary800
                    border.color: Theme.colors.secondary500
                    border.width: Theme.borders.b1
                    radius: Theme.radius.md

                    ColumnLayout {
                        id: settingsColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacing.s6
                        spacing: Theme.spacing.s4

                        Text {
                            text: (TranslationManager.revision, qsTr("Mission Settings"))
                            font.pixelSize: Theme.typography.fontSize175
                            font.weight: Theme.typography.weightSemibold
                            color: Theme.colors.text
                        }

                        UI.Toggle {
                            id: autoLaunchToggle
                            leftLabel: (TranslationManager.revision, qsTr("Auto-launch sequence"))
                            size: "md"
                            checked: false
                            onToggled: resultText.text = (TranslationManager.revision, qsTr("Auto-launch: ")) + (checked ? (TranslationManager.revision, qsTr("ENABLED")) : (TranslationManager.revision, qsTr("DISABLED")))
                        }

                        UI.Toggle {
                            id: telemetryToggle
                            leftLabel: (TranslationManager.revision, qsTr("Real-time telemetry"))
                            size: "md"
                            checked: true
                            onToggled: resultText.text = (TranslationManager.revision, qsTr("Telemetry: ")) + (checked ? (TranslationManager.revision, qsTr("STREAMING")) : (TranslationManager.revision, qsTr("PAUSED")))
                        }

                        UI.Toggle {
                            id: emergencyToggle
                            leftLabel: (TranslationManager.revision, qsTr("Emergency override"))
                            size: "md"
                            checked: false
                            onToggled: resultText.text = (TranslationManager.revision, qsTr("Emergency mode: ")) + (checked ? (TranslationManager.revision, qsTr("ACTIVE")) : (TranslationManager.revision, qsTr("STANDBY")))
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: Theme.colors.secondary500
                            radius: Theme.radius.sm

                            Text {
                                id: resultText
                                anchors.centerIn: parent
                                text: (TranslationManager.revision, qsTr("Toggle any setting to see status"))
                                font.pixelSize: Theme.typography.fontSize125
                                color: Theme.colors.text
                            }
                        }
                    }
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // 5. Responsive Size Test
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("5. Size Comparison Chart"))
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: Theme.colors.primary900
                    border.color: Theme.colors.grey400
                    border.width: Theme.borders.b1
                    radius: Theme.radius.sm

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacing.s8

                        Column {
                            spacing: Theme.spacing.s2
                            Text { text: "SM"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                            UI.Toggle { size: "sm"; checked: true; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "32×18"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text { text: "MD"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                            UI.Toggle { size: "md"; checked: true; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "40×22"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                        Column {
                            spacing: Theme.spacing.s2
                            Text { text: "LG"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                            UI.Toggle { size: "lg"; checked: true; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "48×26"; font.pixelSize: Theme.typography.fontSize100; color: Theme.colors.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }
            }

            // Spacer
            Item { Layout.preferredHeight: Theme.spacing.s6 }
        }
    }

}
