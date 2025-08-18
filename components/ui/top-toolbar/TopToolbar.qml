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

    // -------------------------------
    // Language properties
    // -------------------------------
    property string handText: qsTr("Hand")
    property string cursorText: qsTr("Cursor")
    property string poiPointLabel: qsTr("Insert Point POI")
    property string poiAreaLabel: qsTr("Insert Area POI")
    property string rectangleText: qsTr("Rectangle")
    property string ellipseText: qsTr("Ellipse")
    property string polylineText: qsTr("Polyline")
    property string polygonText: qsTr("Polygon")

    function retranslateUi() {
        handText = qsTr("Hand")
        cursorText = qsTr("Cursor")
        poiPointLabel = qsTr("Insert Point POI")
        poiAreaLabel = qsTr("Insert Area POI")
        rectangleText = qsTr("Rectangle")
        ellipseText = qsTr("Ellipse")
        polylineText = qsTr("Polyline")
        polygonText = qsTr("Polygon")
    }

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
            icon: "../assets/hand.svg",
            label: handText
        },
        {
            id: "cursor",
            icon: "../assets/cursor.svg",
            label: cursorText
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
                { separator: true, label: topToolbar.poiPointLabel },
                ...PoiOptionsController.types.slice(4)
            ]
            tools[4].menu = [
                { separator: true, label: topToolbar.poiAreaLabel },
                ...PoiOptionsController.types.slice(0, 4)
            ]
            setStaticLayerToolbar()
        }
    }

    property var drawingTools: [
        { id: "rectangle", icon: "../assets/rectangle.svg", label: rectangleText },
        { id: "ellipse", icon: "../assets/ellipse.svg", label: ellipseText },
        { id: "polyline", icon: "../assets/polyline.svg", label: polylineText },
        { id: "polygon", icon: "../assets/polygon.svg", label: polygonText }
    ]

    function setCurrentTool(toolId) {
        topToolbar.currentToolId = toolId
        // ...existing switch logic (unchanged)...
    }

    function onPoiSelect(toolId, poiCategory, poiType) {
        var category = poiCategory.key
        var type = poiType.key

        if (toolId === "poi-area") {
            topToolbar.previousToolId = "rectangle"
            topToolbar.setCurrentTool("rectangle")
        } else if (toolId === "poi-point") {
            topToolbar.previousToolId = "poi-point"
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

    // -------------------------------
    // Language controller connection
    // -------------------------------
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating TopToolbar")
            topToolbar.retranslateUi()
            setStaticLayerToolbar()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
