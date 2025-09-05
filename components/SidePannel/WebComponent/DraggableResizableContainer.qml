import QtQuick 2.15
import QtQuick.Controls 6.5
import QtQuick.Layouts 1.15
import QtWebEngine 1.10

Rectangle {
    id: container
    width: 400
    height: 300
    x: 50
    y: 50
    radius: 4
    color: "#222"
    border.color: "#888"
    border.width: 1

    signal closeRequested()

    // Minimum position and size constraints
    property real minX: 0
    property real minY: 0
    property real minWidth: 200
    property real minHeight: 150

    // These must be set from outside (main window)
    property real windowWidth: 800
    property real windowHeight: 600

    // Maximum allowed position based on window size and current width/height
    property real maxX: windowWidth - width
    property real maxY: windowHeight - height

    // Clamp position within window bounds
    onXChanged: x = Math.max(minX, Math.min(x, maxX))
    onYChanged: y = Math.max(minY, Math.min(y, maxY))

    // Clamp size within min size and available window space
    onWidthChanged: width = Math.max(minWidth, Math.min(width, windowWidth - x))
    onHeightChanged: height = Math.max(minHeight, Math.min(height, windowHeight - y))

    // Default alias to add content inside container
    default property alias content: contentArea.data

    // Drag handle bar on top
    Rectangle {
        id: dragHandle
        height: 30
        width: parent.width
        color: "#444"
        radius: 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        border.color: "#666"
        border.width: 1
        z: 10

        MouseArea {
            id: dragMouseArea
            anchors.fill: parent
            drag.target: container
            drag.axis: Drag.XAndYAxis

            // Limit dragging inside window bounds dynamically
            drag.minimumX: container.minX
            drag.minimumY: container.minY
            drag.maximumX: container.maxX
            drag.maximumY: container.maxY

            cursorShape: Qt.OpenHandCursor
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
            hoverEnabled: true
        }

        // Close button on drag bar
        Rectangle {
            id: closeButton
            width: 24
            height: 24
            radius: 4
            anchors {
                right: parent.right
                rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            color: closeMouseArea.containsMouse ? "#ff4444" : "#333"
            border.color: "#aaa"

            Text {
                text: "✕"
                color: "white"
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: container.closeRequested()
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
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
            margins: 1
        }
        clip: true
    }

    // Resize handle at bottom-right corner
    Rectangle {
        id: resizeHandle
        width: 16
        height: 16
        radius: 4
        color: resizeMouseArea.drag.active ? "#888" : "#555"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 100

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

            onEntered: resizeHandle.color = "#aaa"
            onExited: resizeHandle.color = drag.active ? "#888" : "#555"

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
