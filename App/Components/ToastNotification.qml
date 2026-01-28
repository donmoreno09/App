import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    property string title: qsTr("New Notification")
    property string message: ""
    property string notificationType: "truck"
    property string notificationId: "-1"

    property Item mapSource: null

    signal closeRequested()
    signal clicked()

    implicitWidth: 320
    implicitHeight: contentContainer.implicitHeight

    property real _progress: 0

    Timer {
        id: tick
        interval: 16
        running: true
        repeat: true

        property real startTime: Date.now()   // record actual time at start
        property real totalMs: 10000

        onTriggered: {
            const now = Date.now()
            const elapsed = now - startTime
            root._progress = Math.min(1.0, elapsed / totalMs)

            if (elapsed >= totalMs) {
                root.closeRequested()
                tick.stop()
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
        grabPermissions: PointerHandler.TakeOverForbidden
    }


    ShaderEffectSource {
        id: backgroundSource
        sourceItem: root.mapSource
        live: true
        recursive: true
        hideSource: false
        anchors.fill: parent
    }

    MultiEffect {
        id: blurredBackground
        anchors.fill: parent
        source: backgroundSource
        blurEnabled: true
        blur: 1.0
    }

    MultiEffect {
        id: maskedBlur
        anchors.fill: parent
        source: blurredBackground
        maskEnabled: true
        maskSource: Rectangle {
            anchors.fill: parent
            radius: Theme.radius.sm
        }
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: Theme.radius.sm
        visible: false
    }

    Rectangle {
        id: glassTint
        anchors.fill: parent
        radius: Theme.radius.sm
        color: Qt.rgba(0.08, 0.12, 0.18, 0.60)
    }

    // Content container
    ColumnLayout {
        id: contentContainer
        anchors.fill: parent
        spacing: 0

        // Content area
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
                        color: Qt.rgba(1, 1, 1, 0.75)
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
                        console.log("[Toast] Close button clicked - ID:", root.notificationId)
                        root.closeRequested()
                    }
                }
            }
        }

        // Progress bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s1
            color: Qt.rgba(1, 1, 1, 0.2)
            radius: Theme.radius.sm

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (1 - root._progress)
                color: Theme.colors.accent500
                radius: Theme.radius.sm
            }
        }
    }

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
