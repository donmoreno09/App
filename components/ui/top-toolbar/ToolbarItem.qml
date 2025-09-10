import QtQuick 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects
import "./utils.js" as ToolbarUtils

ToolButton {
    property TopToolbar toolbar
    property var tool

    id: toolBtn
    anchors.centerIn: parent
    width: 36
    height: 36

    background: Rectangle {
        color: {
            if (toolBtn.hovered) return "#404040"
            if (tool.id === toolbar.currentToolId || tool.id === toolbar.currentMode) return "#2a2a2a"

            return "transparent"
        }

        radius: 6
    }

    contentItem: Item {
        anchors.fill: parent

        Image {
            id: toolIcon
            source: tool.icon
            width: 16
            height: 16
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        ColorOverlay {
            anchors.fill: toolIcon
            source: toolIcon
            color: "#ffffff"
        }

        Text {
            text: ToolbarUtils.getToolIndex(toolbar.toolsModel, tool)
            font.pixelSize: 8
            color: "#ffffff"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 4
            anchors.bottomMargin: 2
        }
    }

    // Use onPressed for now to stop the flickering to previous tool bug
    onPressed: {
        toolbar.setCurrentTool(tool.id)

        // since items with menus are not interactive, we will only
        // set to revert to an interactive menu item
        if (tool && !tool.menu) toolbar.previousToolId = toolbar.currentToolId
    }
}
