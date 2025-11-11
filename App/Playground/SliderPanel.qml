import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Slider Test")

    ScrollView {
        id: sv
        anchors.fill: parent
        contentWidth: availableWidth

        Frame {
            padding: Theme.spacing.s5
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s8

                // Header
                Text {
                    text: "Slider Component Variants"
                    font.pixelSize: Theme.typography.fontSize300
                    font.weight: Theme.typography.weightBold
                    color: Theme.colors.text
                    Layout.fillWidth: true
                }

                // Section 1: Basic Single Value Sliders
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "Single Value Sliders"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        value: 50
                        from: 0
                        to: 100
                        label: "Label"
                        showValues: true
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        value: 75
                        from: 0
                        to: 100
                        label: "Label"
                        showValues: false
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        value: 85
                        from: 0
                        to: 100
                        showValues: true
                    }

                    // Inizio Modifica
                    // Dotted single slider example
                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        value: 60
                        from: 0
                        to: 100
                        label: "Dotted Track"
                        isDotted: true
                        showValues: true
                    }
                    // Fine Modifica
                }

                // Section 2: Range Sliders
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "Range Sliders"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s2

                        UI.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            isRange: true
                            firstValue: 20
                            secondValue: 80
                            from: 0
                            to: 100
                            label: "Label"
                            showValues: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            Text { text: "Min."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: "Max."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s2

                        UI.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            isRange: true
                            firstValue: 30
                            secondValue: 70
                            from: 0
                            to: 100
                            label: "Label"
                            showValues: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            Text { text: "Min."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: "Max."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s2

                        UI.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            isRange: true
                            firstValue: 45
                            secondValue: 55
                            from: 0
                            to: 100
                            label: "Label"
                            showValues: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 400
                            Text { text: "Min."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: "Max."; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                            Text { text: "Value"; font.pixelSize: Theme.typography.fontSize125; color: Theme.colors.textMuted }
                        }
                    }

                    // Inizio Modifica
                    // Dotted range slider example
                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        isRange: true
                        firstValue: 25
                        secondValue: 75
                        from: 0
                        to: 100
                        label: "Dotted Range"
                        showValues: true
                        isDotted: true
                    }
                    // Fine Modifica
                }

                // Section 3: Different Sizes and Configurations
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "Size Variants & Configurations"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        size: "sm"
                        value: 40
                        from: 0
                        to: 100
                        label: "Small Size"
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        size: "md"
                        value: 60
                        from: 0
                        to: 100
                        label: "Medium Size"
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        size: "lg"
                        value: 80
                        from: 0
                        to: 100
                        label: "Large Size"
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        value: 65
                        from: 0
                        to: 100
                        label: "Percentage"
                        valueSuffix: "%"
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        value: 250
                        from: 0
                        to: 1000
                        stepSize: 10
                        label: "Price Range"
                        valuePrefix: "$"
                    }

                    UI.Slider {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        value: 30
                        from: 0
                        to: 100
                        label: "Disabled"
                        enabled: false
                    }
                }

                // Section 4: Interactive Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s5

                    Text {
                        text: "Interactive Examples"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                        Layout.preferredHeight: 120
                        color: Theme.colors.grey50
                        border.width: 2
                        border.color: Theme.colors.accent200
                        radius: Theme.radius.lg

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.s4
                            spacing: Theme.spacing.s4

                            UI.Slider {
                                Layout.fillWidth: true
                                value: 25
                                from: 0
                                to: 100
                                showValues: false
                            }

                            UI.Slider {
                                Layout.fillWidth: true
                                isRange: true
                                firstValue: 30
                                secondValue: 70
                                from: 0
                                to: 100
                                showValues: false
                                // Inizio Modifica
                                isDotted: true
                                // Fine Modifica
                            }
                        }
                    }
                }

                // Test buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s3

                    UI.Button {
                        text: "Reset All"
                        size: "sm"
                        variant: UI.ButtonStyles.Secondary
                        onClicked: {
                            console.log("Reset all sliders")
                        }
                    }

                    UI.Button {
                        text: "Random Values"
                        size: "sm"
                        variant: UI.ButtonStyles.Ghost
                        onClicked: {
                            console.log("Set random values")
                        }
                    }
                }

                Item { Layout.preferredHeight: Theme.spacing.s6 }
            }
        }
    }
}
