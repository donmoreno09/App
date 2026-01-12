import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Switcher Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                // 1. Basic Switcher
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "1. Basic Switcher"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Switcher {
                        id: basicSwitcher
                        Layout.alignment: Qt.AlignHCenter
                        model: ["Component", "Items", "Settings", "Preview"]
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: Theme.colors.primary800
                        border.color: Theme.colors.secondary500
                        border.width: Theme.borders.b1
                        radius: Theme.radius.md

                        Text {
                            anchors.centerIn: parent
                            text: "Content for: " + (basicSwitcher.model[basicSwitcher.currentIndex] || "")
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize175
                        }
                    }
                }

                // 2. Ghost Variant
                // ColumnLayout {
                //     Layout.fillWidth: true
                //     spacing: Theme.spacing.s4

                //     Text {
                //         text: "2. Ghost Variant"
                //         font.pixelSize: Theme.typography.fontSize200
                //         font.weight: Theme.typography.weightSemibold
                //         color: Theme.colors.accent500
                //     }

                //     UI.Switcher {
                //         id: ghostSwitcher
                //         Layout.alignment: Qt.AlignHCenter
                //         model: ["Overview", "Details", "History"]
                //     }

                //     Rectangle {
                //         Layout.fillWidth: true
                //         Layout.preferredHeight: 80
                //         color: Theme.colors.greyA10
                //         border.color: Theme.colors.greyA30
                //         border.width: Theme.borders.b1
                //         radius: Theme.radius.md

                //         Text {
                //             anchors.centerIn: parent
                //             text: "Ghost content: " + (ghostSwitcher.model[ghostSwitcher.currentIndex] || "")
                //             color: Theme.colors.text
                //             font.family: Theme.typography.familySans
                //             font.pixelSize: Theme.typography.fontSize150
                //         }
                //     }
                // }

                // 3. Secondary Variant
                // ColumnLayout {
                //     Layout.fillWidth: true
                //     spacing: Theme.spacing.s4

                //     Text {
                //         text: "3. Secondary Variant"
                //         font.pixelSize: Theme.typography.fontSize200
                //         font.weight: Theme.typography.weightSemibold
                //         color: Theme.colors.accent500
                //     }

                //     UI.Switcher {
                //         id: secondarySwitcher
                //         Layout.alignment: Qt.AlignHCenter
                //         model: ["Quick", "Advanced", "Expert"]
                //     }

                //     Rectangle {
                //         Layout.fillWidth: true
                //         Layout.preferredHeight: 80
                //         color: Theme.colors.secondary100
                //         border.color: Theme.colors.secondary300
                //         border.width: Theme.borders.b1
                //         radius: Theme.radius.md

                //         Text {
                //             anchors.centerIn: parent
                //             text: "Secondary: " + (secondarySwitcher.model[secondarySwitcher.currentIndex] || "")
                //             color: Theme.colors.secondary700
                //             font.family: Theme.typography.familySans
                //             font.pixelSize: Theme.typography.fontSize150
                //         }
                //     }
                // }

                // 4. Different Model Sizes
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "4. Different Model Sizes"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        // Two items
                        Row {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Two items:"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            UI.Switcher {
                                model: ["On", "Off"]
                            }
                        }

                        // Five items
                        Row {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Five items:"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            UI.Switcher {
                                model: ["Mon", "Tue", "Wed", "Thu", "Fri"]
                            }
                        }

                        // Long labels
                        Row {
                            spacing: Theme.spacing.s2
                            Text {
                                text: "Long labels:"
                                font.pixelSize: Theme.typography.fontSize150
                                color: Theme.colors.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            UI.Switcher {
                                model: ["Configuration", "Management", "Administration"]
                            }
                        }
                    }
                }

                // 5. Disabled State
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "5. Disabled State"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Switcher {
                        Layout.alignment: Qt.AlignHCenter
                        model: ["Disabled", "Component", "Test"]
                        enabled: false
                        currentIndex: 1
                    }
                }

                // 6. Interactive Test with Content
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "6. Interactive Test with Real Content"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Switcher {
                        id: interactiveSwitcher
                        Layout.alignment: Qt.AlignHCenter
                        model: ["Info", "Settings", "Data", "Actions"]
                        onItemClicked: function(index) {
                            console.log("Switched to tab:", index, "(" + model[index] + ")")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: Theme.colors.primary800
                        border.color: Theme.colors.secondary500
                        border.width: Theme.borders.b1
                        radius: Theme.radius.md

                        StackLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.s4
                            currentIndex: interactiveSwitcher.currentIndex

                            // Info tab
                            ColumnLayout {
                                spacing: Theme.spacing.s3

                                Text {
                                    text: "Information Panel"
                                    font.family: Theme.typography.familySans
                                    font.pixelSize: Theme.typography.fontSize175
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.colors.text
                                }

                                Text {
                                    text: "This panel shows general information about the system status and current configuration."
                                    font.family: Theme.typography.familySans
                                    font.pixelSize: Theme.typography.fontSize150
                                    color: Theme.colors.textMuted
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            // Settings tab
                            ColumnLayout {
                                spacing: Theme.spacing.s3

                                Text {
                                    text: "Settings Configuration"
                                    font.family: Theme.typography.familySans
                                    font.pixelSize: Theme.typography.fontSize175
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.colors.text
                                }

                                ColumnLayout {
                                    spacing: Theme.spacing.s2

                                    UI.Toggle {
                                        leftLabel: "Enable notifications"
                                        checked: true
                                    }

                                    UI.Toggle {
                                        leftLabel: "Auto-save changes"
                                        checked: false
                                    }
                                }
                            }

                            // Data tab
                            ColumnLayout {
                                spacing: Theme.spacing.s3

                                Text {
                                    text: "Data Overview"
                                    font.family: Theme.typography.familySans
                                    font.pixelSize: Theme.typography.fontSize175
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.colors.text
                                }

                                GridLayout {
                                    columns: 2
                                    columnSpacing: Theme.spacing.s4
                                    rowSpacing: Theme.spacing.s2

                                    Text { text: "Records:"; color: Theme.colors.textMuted }
                                    Text { text: "1,247"; color: Theme.colors.text; font.weight: Theme.typography.weightMedium }

                                    Text { text: "Active:"; color: Theme.colors.textMuted }
                                    Text { text: "1,198"; color: Theme.colors.success500; font.weight: Theme.typography.weightMedium }

                                    Text { text: "Pending:"; color: Theme.colors.textMuted }
                                    Text { text: "49"; color: Theme.colors.warning500; font.weight: Theme.typography.weightMedium }
                                }
                            }

                            // Actions tab
                            ColumnLayout {
                                spacing: Theme.spacing.s3

                                Text {
                                    text: "Available Actions"
                                    font.family: Theme.typography.familySans
                                    font.pixelSize: Theme.typography.fontSize175
                                    font.weight: Theme.typography.weightMedium
                                    color: Theme.colors.text
                                }

                                RowLayout {
                                    spacing: Theme.spacing.s3

                                    UI.Button {
                                        text: "Export"
                                        variant: UI.ButtonStyles.Primary
                                        size: "sm"
                                    }

                                    UI.Button {
                                        text: "Import"
                                        variant: UI.ButtonStyles.Secondary
                                        size: "sm"
                                    }

                                    UI.Button {
                                        text: "Reset"
                                        variant: UI.ButtonStyles.Ghost
                                        size: "sm"
                                    }
                                }
                            }
                        }
                    }
                }

                // 7. Test Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "7. Test Controls"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            text: "Set to Index 0"
                            size: "sm"
                            variant: UI.ButtonStyles.Secondary
                            onClicked: {
                                basicSwitcher.currentIndex = 0
                                interactiveSwitcher.currentIndex = 0
                            }
                        }

                        UI.Button {
                            text: "Set to Index 2"
                            size: "sm"
                            variant: UI.ButtonStyles.Secondary
                            onClicked: {
                                basicSwitcher.currentIndex = 2
                                interactiveSwitcher.currentIndex = 2
                            }
                        }

                        UI.Button {
                            text: "Random Index"
                            size: "sm"
                            variant: UI.ButtonStyles.Ghost
                            onClicked: {
                                const randomIndex = Math.floor(Math.random() * basicSwitcher.model.length)
                                basicSwitcher.currentIndex = randomIndex
                                interactiveSwitcher.currentIndex = randomIndex
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
