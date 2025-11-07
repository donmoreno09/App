import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    id: container

    property alias windowTitle: windowTitle.text
    property alias loading: spinner.running

    // Prevent map interactions below this component
    UI.InputShield { anchors.fill: parent }

    // Use the same numbers for both logical min and Layout min (avoid conflicts)
    property real minWidth: 800
    property real minHeight: 600

    Layout.minimumWidth: minWidth
    Layout.minimumHeight: minHeight

    radius: Theme.radius.sm
    color: Theme.colors.primary900
    border.color: Theme.colors.black
    border.width: Theme.borders.b1
    z: Theme.elevation.modal

    signal closeRequested()

    // Window bounds (set from outside)
    property real windowWidth: 800
    property real windowHeight: 600

    function clampToBounds() {
        container.x = Math.max(0, Math.min(container.x, container.windowWidth  - container.width))
        container.y = Math.max(0, Math.min(container.y, container.windowHeight - container.height))
    }

    onWindowWidthChanged: clampToBounds()
    onWindowHeightChanged: clampToBounds()

    // Max position based on current size
    property real maxPosX: windowWidth - width
    property real maxPosY: windowHeight - height

    // Default alias to add content inside container
    default property alias content: contentArea.data

    // Drag handle bar on top
    Rectangle {
        id: dragHandle
        height: Theme.spacing.s10
        width: parent.width
        color: Theme.colors.black
        radius: Theme.radius.sm
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        border.color: Theme.colors.black
        border.width: Theme.borders.b1
        z: 10

        HoverHandler { cursorShape: Qt.OpenHandCursor }
        DragHandler {
            id: moveDrag
            target: container
            dragThreshold: 0
            xAxis.minimum: 0
            xAxis.maximum: container.windowWidth  - container.width
            yAxis.minimum: 0
            yAxis.maximum: container.windowHeight - container.height
            cursorShape: active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            grabPermissions: PointerHandler.CanTakeOverFromAnything
        }

        // Window title
        Label {
            id: windowTitle
            visible: text !== ""
            font.bold: true
            font.pixelSize: Theme.typography.fontSize200
            color: Theme.colors.white500
            anchors {
                left: parent.left
                leftMargin: Theme.spacing.s4
                verticalCenter: parent.verticalCenter
            }
        }

        // Close button
        Rectangle {
            id: closeButton
            width: Theme.spacing.s6
            height: Theme.spacing.s6
            radius: Theme.radius.sm
            anchors {
                right: parent.right
                rightMargin: Theme.spacing.s4
                verticalCenter: parent.verticalCenter
            }
            color: closeMouseArea.containsMouse ? Theme.colors.error500 : Theme.colors.whiteA20
            border.color: Theme.colors.grey500
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

    BusyIndicator {
        id: spinner
        anchors.centerIn: parent
        running: false
        visible: running
    }

    // Resize handle (doesn't move; only resizes container)
    Rectangle {
        id: resizeHandle
        width: Theme.spacing.s4
        height: Theme.spacing.s4
        radius: Theme.radius.sm
        color: resizeDrag.active ? Theme.colors.whiteA10 : Theme.colors.whiteA20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.s1
        z: 100

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

        HoverHandler { cursorShape: Qt.SizeFDiagCursor }
        DragHandler {
            id: resizeDrag
            target: null
            cursorShape: Qt.SizeFDiagCursor
            dragThreshold: 0
            grabPermissions: PointerHandler.CanTakeOverFromAnything

            property real startW
            property real startH
            onActiveChanged: if (active) {
                startW = container.width
                startH = container.height
            }

            onActiveTranslationChanged: {
                const dx = resizeDrag.activeTranslation.x
                const dy = resizeDrag.activeTranslation.y

                container.width  = Math.min(
                    container.windowWidth  - container.x,
                    Math.max(container.minWidth,  startW + dx)
                )
                container.height = Math.min(
                    container.windowHeight - container.y,
                    Math.max(container.minHeight, startH + dy)
                )
            }
        }
    }
}
