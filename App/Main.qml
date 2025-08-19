import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Assuming these are your custom modules.
// If not, you might need to replace Theme/UI calls with concrete values.
import App.Themes 1.0
import App.Components 1.0 as UI

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("IRIDESS FE")

    background: Rectangle {
        color: Theme.colors.background
    }

    // The ScrollView should be the main content item.
    // It will manage the scrolling of a single child, in this case, the ColumnLayout.
    ScrollView {
        anchors.fill: parent
        clip: true // Ensures content doesn't draw outside the scroll view

        ColumnLayout {
            // The layout should stretch to the width of the ScrollView.
            width: parent.width
            spacing: Theme.spacing.s8

            // --- "Hover Me" Item (Moved inside the layout) ---
            Item {
                // Use Layout properties when inside a Layout
                Layout.preferredWidth: 220
                Layout.preferredHeight: 140
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.spacing.s4
                Layout.bottomMargin: Theme.spacing.s4
                z: Theme.elevation.raised

                // Border
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius.md
                    color: Theme.colors.surface
                    border.width: Theme.borders.b2
                    border.color: Theme.colors.textMuted

                    Text {
                        anchors.centerIn: parent
                        text: "Hover me"
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                    }
                }

                // Outline ring
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    anchors.margins: -Theme.borders.offset2 // expand outward
                    border.width: Theme.borders.outline2
                    radius: Theme.radius.md + Theme.borders.outline2
                    border.color: Theme.colors.primary
                    visible: hoverArea.containsMouse
                }

                // Hover detection
                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton // hover only
                }
            }


            // --- Test Suite Sections ---

            // Header
            Text {
                text: "Button Component Test Suite"
                font.pixelSize: Theme.typography.size3xl
                font.weight: Theme.typography.weightBold
                color: Theme.colors.text
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s6
                Layout.bottomMargin: Theme.spacing.s4
            }

            // Basic Variants Section
            ColumnLayout {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s6
                Layout.rightMargin: Theme.spacing.s6


                Text {
                    text: "1. Basic Variants"
                    font.pixelSize: Theme.typography.sizeXl
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                Text {
                    text: "Testing all visual variants with consistent content"
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.textMuted
                    Layout.bottomMargin: Theme.spacing.s2
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    UI.Button {
                        variant: "primary"
                        Text {
                            text: "Primary"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Primary button clicked")
                    }

                    UI.Button {
                        variant: "secondary"
                        Text {
                            text: "Secondary"
                            color: Theme.colors.text
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Secondary button clicked")
                    }

                    UI.Button {
                        variant: "danger"
                        Text {
                            text: "Danger"
                            color: "white"
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Danger button clicked")
                    }

                    UI.Button {
                        variant: "ghost"
                        Text {
                            text: "Ghost"
                            color: Theme.colors.text
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Ghost button clicked")
                    }

                    UI.Button {
                        variant: "success"
                        Text {
                            text: "Success"
                            color: "white"
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Success button clicked")
                    }
                }
            }

            // Size Variants Section
            ColumnLayout {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.s8
                Layout.leftMargin: Theme.spacing.s6
                Layout.rightMargin: Theme.spacing.s6

                Text {
                    text: "2. Size Variants"
                    font.pixelSize: Theme.typography.sizeXl
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                Text {
                    text: "Small (sm), Medium (md), and Large (lg) sizes"
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.textMuted
                    Layout.bottomMargin: Theme.spacing.s2
                }

                Row {
                    spacing: Theme.spacing.s4
                    Layout.alignment: Qt.AlignLeft

                    UI.Button {
                        variant: "primary"
                        size: "sm"
                        Text {
                            text: "Small"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeSm
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Small button clicked")
                    }

                    UI.Button {
                        variant: "primary"
                        size: "md"
                        Text {
                            text: "Medium"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Medium button clicked")
                    }

                    UI.Button {
                        variant: "primary"
                        size: "lg"
                        Text {
                            text: "Large"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeLg
                            anchors.centerIn: parent
                        }
                        onClicked: console.log("Large button clicked")
                    }
                }
            }

            // Icon Buttons Section
            ColumnLayout {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.s8
                Layout.leftMargin: Theme.spacing.s6
                Layout.rightMargin: Theme.spacing.s6

                Text {
                    text: "3. Icon and Combined Content"
                    font.pixelSize: Theme.typography.sizeXl
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                Text {
                    text: "Demonstrating flexible content support - icons, text, and combinations"
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.textMuted
                    Layout.bottomMargin: Theme.spacing.s2
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    // Icon-only button (square)
                    UI.Button {
                        variant: "ghost"
                        size: "md"
                        width: height // Make it square for icon-only

                        // Simulate icon with a colored rectangle
                        Rectangle {
                            width: Theme.icons.sizeMd
                            height: Theme.icons.sizeMd
                            color: Theme.colors.text
                            radius: 2
                            anchors.centerIn: parent

                            // Add a simple "+" pattern to simulate an icon
                            Rectangle {
                                width: parent.width * 0.6
                                height: 2
                                color: Theme.colors.background
                                anchors.centerIn: parent
                            }
                            Rectangle {
                                width: 2
                                height: parent.height * 0.6
                                color: Theme.colors.background
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: console.log("Icon-only button clicked")
                    }

                    // Icon + Text button
                    UI.Button {
                        variant: "secondary"

                        Row {
                            spacing: Theme.spacing.s2
                            anchors.centerIn: parent

                            // Simulate icon
                            Rectangle {
                                width: Theme.icons.sizeSm
                                height: Theme.icons.sizeSm
                                color: Theme.colors.text
                                radius: 2
                                anchors.verticalCenter: parent.verticalCenter

                                // Simple gear-like pattern
                                Rectangle {
                                    width: 6
                                    height: 6
                                    color: Theme.colors.background
                                    radius: 3
                                    anchors.centerIn: parent
                                }
                            }

                            Text {
                                text: "Settings"
                                color: Theme.colors.text
                                font.pixelSize: Theme.typography.sizeBase
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        onClicked: console.log("Icon + text button clicked")
                    }
                }
            }

            // State Testing Section
            ColumnLayout {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.s8
                Layout.leftMargin: Theme.spacing.s6
                Layout.rightMargin: Theme.spacing.s6

                Text {
                    text: "4. State Testing"
                    font.pixelSize: Theme.typography.sizeXl
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                Text {
                    text: "Testing disabled states and interactive feedback"
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.textMuted
                    Layout.bottomMargin: Theme.spacing.s2
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    UI.Button {
                        variant: "primary"
                        enabled: false // Use 'enabled' to disable
                        Text {
                            text: "Disabled Primary"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                            opacity: 0.5
                        }
                    }

                    UI.Button {
                        variant: "secondary"
                        enabled: false
                        Text {
                            text: "Disabled Secondary"
                            color: Theme.colors.textMuted
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            // Interactive Demo Section
            ColumnLayout {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.s8
                Layout.leftMargin: Theme.spacing.s6
                Layout.rightMargin: Theme.spacing.s6

                Text {
                    text: "5. Interactive Demo"
                    font.pixelSize: Theme.typography.sizeXl
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }

                Text {
                    text: "Hover, click, and use keyboard navigation (Tab + Space/Enter) to test interactions"
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.textMuted
                    Layout.bottomMargin: Theme.spacing.s2
                }

                Row {
                    spacing: Theme.spacing.s6
                    Layout.alignment: Qt.AlignLeft

                    UI.Button {
                        id: clickCounter
                        variant: "primary"
                        property int clickCount: 0

                        Text {
                            // FIX: Use standard string concatenation for bindings
                            text: "Clicks: " + clickCounter.clickCount
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }

                        onClicked: {
                            clickCount++
                            console.log("Button clicked " + clickCount + " times")
                        }
                    }

                    UI.Button {
                        id: toggleButton
                        // FIX: Bind variant to the 'isOn' property, not 'enabled'
                        variant: isOn ? "success" : "danger"
                        property bool isOn: true

                        Text {
                            text: toggleButton.isOn ? "Turn OFF" : "Turn ON"
                            color: "white"
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }

                        onClicked: {
                            isOn = !isOn
                            console.log("Toggle button: " + (isOn ? "ON" : "OFF"))
                        }
                    }
                }
            }

            // Spacing at bottom
            Item {
                Layout.preferredHeight: Theme.spacing.s8
            }
        }
    }
}
