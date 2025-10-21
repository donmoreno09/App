import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Rectangle {
    id: container
    width: 400
    height: 300
    radius: Theme.radius.sm
    color: Theme.colors.primary900
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    z: Theme.elevation.modal

    signal closeRequested()

    // Minimum position and size constraints
    property real minPosX: 0
    property real minPosY: 0
    property real minWidth: 200
    property real minHeight: 150

    // These must be set from outside (main window)
    property real windowWidth: 800
    property real windowHeight: 600

    // Maximum allowed position based on window size and current width/height
    property real maxPosX: windowWidth - width
    property real maxPosY: windowHeight - height

    // Initial position
    Component.onCompleted: {
        x = 100
        y = 100
    }

    // Clamp position within window bounds
    onXChanged: x = Math.max(minPosX, Math.min(x, maxPosX))
    onYChanged: y = Math.max(minPosY, Math.min(y, maxPosY))

    // Clamp size within min size and available window space
    onWidthChanged: width = Math.max(minWidth, Math.min(width, windowWidth - x))
    onHeightChanged: height = Math.max(minHeight, Math.min(height, windowHeight - y))

    // Default alias to add content inside container
    default property alias content: contentArea.data

    // Drag handle bar on top
    Rectangle {
        id: dragHandle
        height: Theme.spacing.s8
        width: parent.width
        color: Theme.colors.primary700
        radius: Theme.radius.sm
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        border.color: Theme.colors.secondary500
        border.width: Theme.borders.b1
        z: 10

        MouseArea {
            id: dragMouseArea
            anchors.fill: parent
            drag.target: container
            drag.axis: Drag.XAndYAxis

            // Limit dragging inside window bounds dynamically
            drag.minimumX: container.minPosX
            drag.minimumY: container.minPosY
            drag.maximumX: container.maxPosX
            drag.maximumY: container.maxPosY

            cursorShape: Qt.OpenHandCursor
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
            hoverEnabled: true
        }

        // Close button on drag bar
        Rectangle {
            id: closeButton
            width: Theme.spacing.s6
            height: Theme.spacing.s6
            radius: Theme.radius.sm
            anchors {
                right: parent.right
                rightMargin: Theme.spacing.s2
                verticalCenter: parent.verticalCenter
            }
            color: closeMouseArea.containsMouse ? Theme.colors.error500 : Theme.colors.primary700
            border.color: Theme.colors.secondary500
            border.width: Theme.borders.b1

            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Text {
                text: "✕"
                color: Theme.colors.white500
                font.bold: true
                font.pixelSize: Theme.typography.fontSize150
                anchors.centerIn: parent
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: container.closeRequested()
            }
        }
    }

    // Content area inside container, below drag handle
    Item {
        id: contentArea
        anchors {
            top: dragHandle.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.spacing.s1
        }
        clip: true
    }

    // Resize handle at bottom-right corner
    Rectangle {
        id: resizeHandle
        width: Theme.spacing.s4
        height: Theme.spacing.s4
        radius: Theme.radius.sm
        color: resizeMouseArea.drag.active ? Theme.colors.secondary400 : Theme.colors.secondary500
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.s1
        z: 100

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            drag.target: resizeHandle
            drag.axis: Drag.XAndYAxis

            // Minimum resize constraints relative to current size
            drag.minimumX: container.minWidth - container.width
            drag.minimumY: container.minHeight - container.height

            // Maximum resize constrained by window size and current position
            drag.maximumX: container.windowWidth - container.width - container.x
            drag.maximumY: container.windowHeight - container.height - container.y

            onEntered: resizeHandle.color = Theme.colors.secondary300
            onExited: resizeHandle.color = drag.active ? Theme.colors.secondary400 : Theme.colors.secondary500

            onPositionChanged: {
                if (drag.active) {
                    var newWidth = container.width + mouseX
                    var newHeight = container.height + mouseY

                    // Apply min size
                    newWidth = Math.max(container.minWidth, newWidth)
                    newHeight = Math.max(container.minHeight, newHeight)

                    // Apply max size based on window bounds
                    newWidth = Math.min(newWidth, container.windowWidth - container.x)
                    newHeight = Math.min(newHeight, container.windowHeight - container.y)

                    container.width = newWidth
                    container.height = newHeight
                }
            }
        }
    }
}
