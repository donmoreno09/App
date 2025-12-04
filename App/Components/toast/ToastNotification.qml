import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    // Public API
    property string title: qsTr("Nuova notifica")
    property string message: ""
    property string notificationType: "truck"
    property int notificationId: -1

    signal closeRequested()
    signal clicked()

    implicitWidth: 320
    implicitHeight: contentContainer.implicitHeight

    // 10-second auto-dismiss timer
    property real _progress: 0

    Timer {
        id: autoCloseTimer
        interval: 10000
        running: true
        onTriggered: root.closeRequested()
    }

    // Progress update timer (separate)
    Timer {
        id: progressTimer
        interval: 50
        running: autoCloseTimer.running
        repeat: true

        property int elapsed: 0

        onRunningChanged: {
            if (running) {
                elapsed = 0
                root._progress = 0
            }
        }

        onTriggered: {
            elapsed += interval
            root._progress = Math.min(1.0, elapsed / autoCloseTimer.interval)
        }
    }

    // Modern input handling
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
        grabPermissions: PointerHandler.TakeOverForbidden
    }

    // Capture the background for blur effect
    ShaderEffectSource {
        id: backgroundSource
        sourceItem: root.parent  // Captures the map behind
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        anchors.fill: parent
        visible: false
        live: true
    }

    // Apply blur effect
    MultiEffect {
        id: blurEffect
        anchors.fill: parent
        source: backgroundSource
        blurEnabled: true
        blur: 1.0
        blurMax: 32
        blurMultiplier: 0.5
        visible: false
    }

    // Mask for rounded corners
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: Theme.radius.sm
        visible: false
    }

    // Apply mask to blur
    MultiEffect {
        id: maskedBlur
        anchors.fill: parent
        source: blurEffect
        maskEnabled: true
        maskSource: mask
    }

    // Glass overlay with color tint
    Rectangle {
        id: glassOverlay
        anchors.fill: parent
        color: Qt.rgba(0.1, 0.15, 0.2, 0.7)  // Dark semi-transparent tint
        radius: Theme.radius.sm
        border.width: Theme.borders.b1
        border.color: Qt.rgba(1, 1, 1, 0.2)  // Subtle light border
    }

    // Content container
    ColumnLayout {
        id: contentContainer
        anchors.fill: parent
        spacing: 0

        // Content area with padding
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.s4
            spacing: Theme.spacing.s2

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s3

                // Notification icon
                Image {
                    Layout.preferredWidth: Theme.icons.sizeMd
                    Layout.preferredHeight: Theme.icons.sizeMd
                    source: "qrc:/App/assets/icons/bell.svg"
                }

                // Text content
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s1

                    Text {
                        text: root.title
                        color: Theme.colors.white500
                        font.family: Theme.typography.bodySans25StrongFamily
                        font.pointSize: Theme.typography.bodySans25StrongSize
                        font.weight: Theme.typography.weightBold
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.message
                        color: Qt.rgba(1, 1, 1, 0.7)  // Lighter text for subtitle
                        font.family: Theme.typography.bodySans15Family
                        font.pointSize: Theme.typography.bodySans15Size
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Close button
                UI.Button {
                    id: closeBtn
                    Layout.preferredWidth: Theme.spacing.s6
                    Layout.preferredHeight: Theme.spacing.s6
                    variant: UI.ButtonStyles.Ghost
                    display: AbstractButton.IconOnly
                    padding: 0

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                        grabPermissions: PointerHandler.CanTakeOverFromAnything
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(1, 1, 1, 0.15) : Theme.colors.transparent
                        radius: Theme.radius.sm
                    }

                    contentItem: Text {
                        text: "✕"
                        color: Theme.colors.white500
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        root.closeRequested()
                    }
                }
            }
        }

        // Progress bar at bottom edge (no margins)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s0_5
            color: Qt.rgba(1, 1, 1, 0.2)
            radius: 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (1 - root._progress)
                color: Theme.colors.accent500
                radius: 0

                Behavior on width {
                    NumberAnimation { duration: 50; easing.type: Easing.Linear }
                }
            }
        }
    }

    // Entrance animation
    opacity: 0
    scale: 0.9
    Component.onCompleted: {
        opacity = 1
        scale = 1
    }

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack }
    }
}
