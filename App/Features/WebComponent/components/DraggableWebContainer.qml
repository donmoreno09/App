import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    id: container

    // Public properties
    property real minWidth: 400
    property real minHeight: 300
    property alias webViewUrl: webViewFrame.url

    // Signals
    signal closeRequested()

    // Default content slot
    default property alias content: contentArea.data

    // Styling from Theme
    color: Theme.colors.surface
    radius: Theme.radius.md
    border.color: Theme.colors.border
    border.width: Theme.borders.b1

    // Internal state
    property real _windowWidth: parent ? parent.width : 1400
    property real _windowHeight: parent ? parent.height : 800

    // Dynamic constraint calculation
    readonly property real _maxX: Math.max(0, _windowWidth - width)
    readonly property real _maxY: Math.max(0, _windowHeight - height)

    // Clamp position and size using a timer to avoid binding loops
    Timer {
        id: constraintTimer
        interval: 0
        repeat: false
        onTriggered: {
            // Clamp position
            if (container.x < 0) container.x = 0
            if (container.x > container._maxX) container.x = container._maxX
            if (container.y < 0) container.y = 0
            if (container.y > container._maxY) container.y = container._maxY

            // Clamp size
            if (container.width < container.minWidth) container.width = container.minWidth
            if (container.height < container.minHeight) container.height = container.minHeight
            if (container.x + container.width > container._windowWidth) {
                container.width = container._windowWidth - container.x
            }
            if (container.y + container.height > container._windowHeight) {
                container.height = container._windowHeight - container.y
            }
        }
    }

    onXChanged: Qt.callLater(constraintTimer.restart)
    onYChanged: Qt.callLater(constraintTimer.restart)
    onWidthChanged: Qt.callLater(constraintTimer.restart)
    onHeightChanged: Qt.callLater(constraintTimer.restart)

    // Title bar
    Rectangle {
        id: titleBar
        height: Theme.spacing.s10
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: Theme.colors.primary700
        radius: Theme.radius.md
        z: Theme.elevation.raised

        // Only round top corners
        // Rectangle {
        //     anchors.bottom: parent.bottom
        //     anchors.left: parent.left
        //     anchors.right: parent.right
        //     height: parent.radius
        //     color: parent.color
        // }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            anchors.rightMargin: closeButton.width + Theme.spacing.s4
            drag.target: container
            drag.axis: Drag.XAndYAxis
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: container._maxX
            drag.maximumY: container._maxY

            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s4
                anchors.rightMargin: Theme.spacing.s4
                spacing: Theme.spacing.s2

                Image {
                    source: "qrc:/App/assets/icons/world.svg"
                    Layout.preferredWidth: Theme.icons.sizeMd
                    Layout.preferredHeight: Theme.icons.sizeMd
                }

                Text {
                    text: qsTr("Web View")
                    color: Theme.colors.text
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightMedium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Close button
        UI.Button {
            id: closeButton
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.s2
            anchors.verticalCenter: parent.verticalCenter

            variant: UI.ButtonStyles.Ghost
            display: AbstractButton.IconOnly
            Layout.preferredWidth: Theme.spacing.s8
            Layout.preferredHeight: Theme.spacing.s8

            icon.source: "qrc:/App/assets/icons/x-close.svg"
            icon.width: Theme.icons.sizeSm
            icon.height: Theme.icons.sizeSm
            icon.color: Theme.colors.text

            backgroundRect.radius: Theme.radius.circle(width, height)
            backgroundRect.border.width: Theme.borders.b0
            backgroundRect.color: hovered ? Theme.colors.error500 : Theme.colors.transparent

            onClicked: container.closeRequested()

            Behavior on backgroundRect.color {
                ColorAnimation {
                    duration: Theme.motion.panelTransitionMs
                    easing.type: Theme.motion.panelTransitionEasing
                }
            }
        }
    }

    // Content area
    Item {
        id: contentArea
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.borders.b1
        clip: true

        WebViewFrame {
            id: webViewFrame
            anchors.fill: parent
            url: container.webViewUrl
        }
    }

    // Resize handle
    Rectangle {
        id: resizeHandle
        width: Theme.spacing.s4
        height: Theme.spacing.s4
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.s1
        color: resizeArea.containsMouse ? Theme.colors.accent500 : Theme.colors.grey400
        radius: Theme.radius.xs
        z: Theme.elevation.popup

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.panelTransitionMs
                easing.type: Theme.motion.panelTransitionEasing
            }
        }

        MouseArea {
            id: resizeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor

            property point startPos
            property real startWidth
            property real startHeight

            onPressed: function(mouse) {
                startPos = Qt.point(mouse.x, mouse.y)
                startWidth = container.width
                startHeight = container.height
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    const deltaX = mouse.x - startPos.x
                    const deltaY = mouse.y - startPos.y

                    let newWidth = startWidth + deltaX
                    let newHeight = startHeight + deltaY

                    // Apply constraints
                    newWidth = Math.max(container.minWidth, newWidth)
                    newHeight = Math.max(container.minHeight, newHeight)
                    newWidth = Math.min(newWidth, container._windowWidth - container.x)
                    newHeight = Math.min(newHeight, container._windowHeight - container.y)

                    container.width = newWidth
                    container.height = newHeight
                }
            }
        }
    }
}
