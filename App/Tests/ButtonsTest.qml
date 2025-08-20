import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

// Clean button test component that can be imported into Main.qml
Item {
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: Theme.spacing.s8

        // Basic Variants Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true

            Text {
                text: "1. Basic Variants"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Testing all visual variants with flexible content sizing"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                UI.Button {
                    variant: "primary"
                    focus: true
                    contentItem: Text {
                        text: "Primary"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                    onClicked: console.log("Primary button clicked")
                }

                UI.Button {
                    variant: "secondary"
                    contentItem: Text {
                        text: "Secondary"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                    onClicked: console.log("Secondary button clicked")
                }

                UI.Button {
                    variant: "danger"
                    contentItem: Text {
                        text: "Danger"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                    onClicked: console.log("Danger button clicked")
                }

                UI.Button {
                    variant: "ghost"
                    contentItem: Text {
                        text: "Ghost"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                    onClicked: console.log("Ghost button clicked")
                }

                UI.Button {
                    variant: "success"
                    contentItem: Text {
                        text: "Success"
                        color: Theme.colors.primaryText
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
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "2. Size Variants"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Small (sm), Medium (md), and Large (lg) sizes - width adapts to content"
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
                    contentItem: Text {
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
                    contentItem: Text {
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
                    contentItem: Text {
                        text: "Large"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeLg
                        anchors.centerIn: parent
                    }
                    onClicked: console.log("Large button clicked")
                }
            }
        }

        // Flexible Width Demo Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "2.1. Flexible Width Demo"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Buttons automatically adapt their width to fit content length"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                UI.Button {
                    variant: "secondary"
                    contentItem: Text {
                        text: "OK"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "secondary"
                    contentItem: Text {
                        text: "Cancel Operation"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "secondary"
                    contentItem: Text {
                        text: "Download and Install Updates"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "primary"
                    contentItem: Text {
                        text: "This is a very long button text that should make the button quite wide"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }
            }
        }

        // Customization Properties Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "3. Customization Properties"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Testing radius, focus ring, and focus color customization"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Flow {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                UI.Button {
                    variant: "secondary"
                    radius: Theme.radius.none  // Square corners
                    contentItem: Text {
                        text: "Square"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "secondary"
                    radius: Theme.radius.xl  // Extra rounded
                    contentItem: Text {
                        text: "Extra Rounded"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "secondary"
                    radius: height / 2  // Pill shape
                    contentItem: Text {
                        text: "Pill Shape"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "ghost"
                    focusColor: Theme.colors.danger  // Red focus ring
                    focusOutlineWidth: Theme.borders.outline4  // Thick ring
                    contentItem: Text {
                        text: "Red Focus Ring"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "ghost"
                    focusColor: Theme.colors.success  // Green focus ring
                    focusOffset: Theme.borders.offset4  // Large gap
                    contentItem: Text {
                        text: "Green Distant Focus"
                        color: Theme.colors.text
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }
            }
        }

        // Icon and Combined Content Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "4. Icon and Combined Content"
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

                // Icon-only button (will be compact)
                UI.Button {
                    variant: "ghost"
                    size: "md"

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

                // Icon + Text button (will expand to fit content)
                UI.Button {
                    variant: "secondary"

                    contentItem: Row {
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

                // Complex content example (will expand as needed)
                UI.Button {
                    variant: "primary"
                    size: "lg"
                    radius: Theme.radius.lg

                    contentItem: Column {
                        spacing: 2
                        anchors.centerIn: parent

                        Text {
                            text: "Upload File"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeBase
                            font.weight: Theme.typography.weightSemibold
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Click or drag & drop"
                            color: Theme.colors.primaryText
                            font.pixelSize: Theme.typography.sizeXs
                            opacity: Theme.opacity.o80
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    onClicked: console.log("Upload button clicked")
                }
            }
        }

        // State Testing Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "5. State Testing"
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
                    enabled: false
                    contentItem: Text {
                        text: "Disabled Primary"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                        opacity: parent.parent.enabled ? Theme.opacity.o100 : Theme.opacity.o50
                    }
                }

                UI.Button {
                    variant: "secondary"
                    enabled: false
                    contentItem: Text {
                        text: "Disabled Secondary"
                        color: Theme.colors.textMuted
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                    }
                }

                UI.Button {
                    variant: "danger"
                    enabled: false
                    contentItem: Text {
                        text: "Disabled Danger"
                        color: Theme.colors.primaryText
                        font.pixelSize: Theme.typography.sizeBase
                        anchors.centerIn: parent
                        opacity: parent.parent.enabled ? Theme.opacity.o100 : Theme.opacity.o50
                    }
                }
            }
        }

        // Interactive Demo Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "6. Interactive Demo"
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

                    contentItem: Text {
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
                    variant: "secondary"

                    contentItem: Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: parent.parent.hovered ? "🔥 Hovered!" : "Hover me"
                            color: Theme.colors.text
                            font.pixelSize: Theme.typography.sizeSm
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: parent.parent.pressed ? "⚡ Pressed!" :
                                  parent.parent.focused ? "🎯 Focused!" : ""
                            color: Theme.colors.text
                            font.pixelSize: Theme.typography.sizeXs
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: Theme.opacity.o80
                        }
                    }

                    onClicked: console.log("State demo button clicked")
                }

                UI.Button {
                    id: toggleButton
                    variant: isOn ? "success" : "danger"
                    property bool isOn: true

                    contentItem: Text {
                        text: toggleButton.isOn ? "Turn OFF" : "Turn ON"
                        color: Theme.colors.primaryText
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

        // Focus Testing Section
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "7. Focus and Keyboard Navigation"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "Use Tab to navigate, Space or Enter to activate. Watch for focus indicators."
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            GridLayout {
                columns: 3
                columnSpacing: Theme.spacing.s4
                rowSpacing: Theme.spacing.s4
                Layout.alignment: Qt.AlignLeft

                Repeater {
                    model: ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"]

                    UI.Button {
                        variant: index % 2 === 0 ? "primary" : "secondary"

                        contentItem: Text {
                            text: modelData
                            color: index % 2 === 0 ? Theme.colors.primaryText : Theme.colors.text
                            font.pixelSize: Theme.typography.sizeBase
                            anchors.centerIn: parent
                        }

                        onClicked: console.log(modelData + " button activated")
                    }
                }
            }
        }

        // Fixed vs Flexible Width Comparison
        ColumnLayout {
            spacing: Theme.spacing.s4
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4

            Text {
                text: "8. Flexible Width Benefits"
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }

            Text {
                text: "See how buttons adapt to content naturally without wasted space"
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.textMuted
                Layout.bottomMargin: Theme.spacing.s2
            }

            Column {
                spacing: Theme.spacing.s4
                Layout.fillWidth: true

                Text {
                    text: "Varied content lengths:"
                    font.pixelSize: Theme.typography.sizeBase
                    color: Theme.colors.text
                    font.weight: Theme.typography.weightMedium
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.s3

                    Repeater {
                        model: [
                            "Save",
                            "Save Changes",
                            "Save Document",
                            "Save Document As...",
                            "Save Document to Cloud Storage",
                            "Export and Save Document to External Drive"
                        ]

                        UI.Button {
                            variant: "primary"
                            size: "sm"

                            contentItem: Text {
                                text: modelData
                                color: Theme.colors.primaryText
                                font.pixelSize: Theme.typography.sizeSm
                                anchors.centerIn: parent
                            }

                            onClicked: console.log("Clicked: " + modelData)
                        }
                    }
                }
            }
        }
    }
}
