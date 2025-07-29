import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

ToolBar {
    id: topToolbar
    topPadding: 6
    bottomPadding: 6
    leftPadding: 6
    rightPadding: 6

    property string currentToolId: "cursor"
    property string previousToolId: "cursor"
    property string currentMode: "cursor"
    property alias toolsModel: toolsModel

    // POI-related variables
    property int currentPoiCategory: -1
    property int currentPoiType: -1

    function clearPoi() {
        currentPoiCategory = -1
        currentPoiType = -1
        if (hasTools(drawingTools)) {
            setStaticLayerToolbar()
        }
    }

    ListModel { id: toolsModel }

    function hasTools(tools) {
        let hasTools = false
        for (let i = 0; i < toolsModel.count; i++) {
            if (toolsModel.get(i).id === tools[0].id) {
                hasTools = true
                break
            }
        }
        return hasTools;
    }

    function setStaticLayerToolbar() {
        toolsModel.clear()
        for (const tool of tools) {
            toolsModel.append(tool)
        }
    }

    Component.onCompleted: {
        setStaticLayerToolbar()
    }

    property var tools: [
        {
            id: "hand",
            icon: "../assets/hand.svg"
        },
        {
            id: "cursor",
            icon: "../assets/cursor.svg"
        },
        { separator: true },
        {
            id: "poi-point",
            icon: "../assets/poi-pin.svg",
            menu: []
        },
        {
            id: "poi-area",
            icon: "../assets/poi-area.svg",
            menu: []
        },
        {
            id: "shapes",
            icon: "../assets/shapes.svg"
        }
    ]

    Connections {
        target: PoiOptionsController

        function onTypesChanged() {
            tools[3].menu = [
                { separator: true, label: "Insert Point POI" },
                // TODO: Reminder that both point and area POIs are in the same array
                //       Currently point POIs start from index 4
                ...PoiOptionsController.types.slice(4)
            ]
            tools[4].menu = [
                { separator: true, label: "Insert Area POI" },
                ...PoiOptionsController.types.slice(0, 4)
            ]
            setStaticLayerToolbar()
        }
    }

    property var drawingTools: [
        {
            id: "rectangle",
            icon: "../assets/rectangle.svg"
        },
        {
            id: "ellipse",
            icon: "../assets/ellipse.svg"
        },
        {
            id: "polyline",
            icon: "../assets/polyline.svg"
        },
        {
            id: "polygon",
            icon: "../assets/polygon.svg"
        }
    ]

    function setCurrentTool(toolId) {
        topToolbar.currentToolId = toolId

        switch (toolId) {
        case "hand":
            InteractionModeManager.currentMode = InteractionModeManager.Hand
            currentMode = "hand"
            clearPoi()
            break
        case "cursor":
            InteractionModeManager.currentMode = InteractionModeManager.Cursor
            currentMode = "cursor"
            clearPoi()
            break
        case "poi-point":
            currentMode = "poi-point"
            if (hasTools(drawingTools)) {
                for (let it = toolsModel.count; it >= tools.length; it--) {
                    toolsModel.remove(it)
                }
            }
            break
        case "point":
            InteractionModeManager.currentMode = InteractionModeManager.DrawPoint
            break
        case "poi-area":
            currentMode = "poi-area"
            break
        case "shapes":
            currentMode = "shapes"
            setCurrentTool("rectangle")
            break
        case "rectangle":
            if (!hasTools(drawingTools)) {
                toolsModel.append({ separator: true })
                for (const tool of drawingTools) {
                    toolsModel.append(tool)
                }
            }

            // do not add polyline for area poi mode
            if (currentMode === "poi-area") {
                for (let i = 0; i < toolsModel.count; i++) {
                    if (toolsModel.get(i).id === 'polyline') {
                        toolsModel.remove(i)
                        break
                    }
                }
            }

            // check if polyline's missing
            if (currentMode === "shapes") {
                let hasPolyline = false
                for (let ip = 0; ip < toolsModel.count; ip++) {
                    if (toolsModel.get(ip).id === 'polyline') {
                        hasPolyline = true
                        break
                    }
                }

                if (!hasPolyline) {
                    toolsModel.insert(toolsModel.count - 1, drawingTools[2])
                }
            }

            if (currentMode === "poi-point") {
                if (hasTools(drawingTools)) {
                    setStaticLayerToolbar()
                }
            }

            InteractionModeManager.currentMode = InteractionModeManager.DrawRectangle
            break
        case "ellipse":
            InteractionModeManager.currentMode = InteractionModeManager.DrawEllipse
            break
        case "polyline":
            InteractionModeManager.currentMode = InteractionModeManager.DrawPolyline
            break
        case "polygon":
            InteractionModeManager.currentMode = InteractionModeManager.DrawPolygon
            break
        default:
            console.warn("Unknown tool id:", toolId)
        }
    }

    function onPoiSelect(toolId, poiCategory, poiType) {
        // IMPORTANT: Save these data otherwise when UI is shifted around
        //            because of clearPoi(), poiCategory and poiType will be null
        var category = poiCategory.key
        var type = poiType.key

        if (toolId === "poi-area") {
            topToolbar.previousToolId = "rectangle" // trick to remain in this tool
            topToolbar.setCurrentTool("rectangle")
        } else if (toolId === "poi-point") {
            topToolbar.previousToolId = "poi-point" // trick to remain in this tool
            topToolbar.setCurrentTool("point")
        }

        topToolbar.currentPoiCategory = category
        topToolbar.currentPoiType = type
    }

    background: Rectangle {
        radius: 6
        color: "#f21f3154"
        border.color: "#404040"
        border.width: 1
    }

    contentItem: RowLayout {
        id: toolbarLayout
        spacing: 6

        Repeater {
            model: toolsModel
            delegate: Loader {
                id: toolLoader

                source: {
                    const tool = toolsModel.get(index)
                    if (!tool) return ""
                    if (tool.separator) return Qt.resolvedUrl("./ToolbarSeparator.qml")
                    if (tool.menu) return Qt.resolvedUrl("./ToolbarMenuItem.qml")
                    return Qt.resolvedUrl("./ToolbarItem.qml")
                }

                onLoaded: {
                    item.toolbar = topToolbar
                    item.tool = toolsModel.get(index)
                }
            }
        }
    }
}
