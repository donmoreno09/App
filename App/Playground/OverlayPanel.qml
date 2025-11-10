import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Overlay Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                // 1. Basic Overlay Properties
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "1. Basic Properties"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Row {
                        spacing: Theme.spacing.s4

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "With Backdrop"
                            onClicked: withBackdrop.open()
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "No Backdrop"
                            onClicked: noBackdrop.open()
                        }
                    }
                }

                // 2. Different Sizes
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
                        spacing: Theme.spacing.s4

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Small"
                            onClicked: smallOverlay.open()
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Medium"
                            onClicked: mediumOverlay.open()
                        }

                        UI.Button {
                            variant: UI.ButtonStyles.Secondary
                            text: "Large"
                            onClicked: largeOverlay.open()
                        }
                    }
                }

                // 3. Dismiss Behavior
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "3. Dismiss Behavior"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Column {
                        spacing: Theme.spacing.s2

                        Text {
                            text: "• ESC key should close overlays"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }

                        Text {
                            text: "• Click outside should close (with backdrop)"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }

                        Text {
                            text: "• No backdrop = can interact with background"
                            font.pixelSize: Theme.typography.fontSize150
                            color: Theme.colors.textMuted
                        }
                    }

                    UI.Button {
                        variant: UI.ButtonStyles.Secondary
                        text: "Test Focus Management"
                        onClicked: focusTest.open()
                    }
                }
            }
        }
    }

    // Test overlays - minimal content, focus on overlay behavior
    UI.Overlay {
        id: withBackdrop
        width: 300
        height: 200
        showBackdrop: true

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            border.width: Theme.borders.b1
            border.color: Theme.colors.border

            Text {
                anchors.centerIn: parent
                text: "Overlay with backdrop\n\nPress ESC or click outside"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }
        }
    }

    UI.Overlay {
        id: noBackdrop
        width: 300
        height: 200
        showBackdrop: false

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            border.width: Theme.borders.b2
            border.color: Theme.colors.accent500

            Text {
                anchors.centerIn: parent
                text: "No backdrop overlay\n\nBackground stays interactive"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }
        }
    }

    UI.Overlay {
        id: smallOverlay
        width: 200
        height: 150
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            Text {
                anchors.centerIn: parent
                text: "Small\n200x150"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }
        }
    }

    UI.Overlay {
        id: mediumOverlay
        width: 400
        height: 300
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            Text {
                anchors.centerIn: parent
                text: "Medium\n400x300"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }
        }
    }

    UI.Overlay {
        id: largeOverlay
        width: 600
        height: 450
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            Text {
                anchors.centerIn: parent
                text: "Large\n600x450"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }
        }
    }

    UI.Overlay {
        id: focusTest
        width: 350
        height: 250

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.md
            border.width: Theme.borders.b1
            border.color: Theme.colors.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s4
                spacing: Theme.spacing.s3

                Text {
                    text: "Focus Test"
                    font.pixelSize: Theme.typography.fontSize175
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Try tabbing through these fields"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Focus should stay within overlay"
                }

                UI.Button {
                    variant: UI.ButtonStyles.Secondary
                    text: "Close"
                    Layout.alignment: Qt.AlignRight
                    onClicked: focusTest.close()
                }
            }
        }
    }
}
