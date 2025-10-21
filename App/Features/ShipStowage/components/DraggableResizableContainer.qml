import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Rectangle {
    id: container
    // Use the same numbers for both logical min and Layout min (avoid conflicts)
    property real minWidth: 800
    property real minHeight: 600

    Layout.minimumWidth: minWidth
    Layout.minimumHeight: minHeight

    radius: Theme.radius.sm
    color: Theme.colors.primary900
    border.color: Theme.colors.secondary500
    border.width: Theme.borders.b1
    z: Theme.elevation.modal

    signal closeRequested()

    // Window bounds (set from outside)
    property real windowWidth: 800
    property real windowHeight: 600

    // Max position based on current size
    property real maxPosX: windowWidth - width
    property real maxPosY: windowHeight - height

    // Keep inside window
    onXChanged: x = Math.max(0, Math.min(x, maxPosX))
    onYChanged: y = Math.max(0, Math.min(y, maxPosY))

    // Clamp size if something external assigns width/height
    onWidthChanged: {
        if (width < minWidth) width = minWidth
        if (x + width > windowWidth) width = windowWidth - x
    }
    onHeightChanged: {
        if (height < minHeight) height = minHeight
        if (y + height > windowHeight) height = windowHeight - y
    }

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
            // Limit dragging within window bounds
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: container.maxPosX
            drag.maximumY: container.maxPosY

            cursorShape: Qt.OpenHandCursor
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
            hoverEnabled: true
        }

        // Close button
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

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

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

    // Content area
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

    // Resize handle (doesn't move; only resizes container)
    Rectangle {
        id: resizeHandle
        width: Theme.spacing.s4
        height: Theme.spacing.s4
        radius: Theme.radius.sm
        color: resizeMouseArea.pressed ? Theme.colors.secondary400 : Theme.colors.secondary500
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.s1
        z: 100

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.SizeFDiagCursor

            // Remember starting state
            property real startW: 0
            property real startH: 0
            property real startX: 0
            property real startY: 0

            onPressed: function(mouse) {
                startW = container.width
                startH = container.height
                startX = mouse.x
                startY = mouse.y
            }

            onPositionChanged: function(mouse) {
                if (!(mouse.buttons & Qt.LeftButton)) return

                var dx = mouse.x - startX
                var dy = mouse.y - startY

                var newW = Math.max(container.minWidth,  Math.min(startW + dx, container.windowWidth  - container.x))
                var newH = Math.max(container.minHeight, Math.min(startH + dy, container.windowHeight - container.y))

                container.width  = newW
                container.height = newH
            }
        }
    }
}
