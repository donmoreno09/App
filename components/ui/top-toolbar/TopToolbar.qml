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
        console.log("=== RETRANSLATE UI CALLED ===")
        handText = qsTr("Hand")
        cursorText = qsTr("Cursor")
        poiPointLabel = qsTr("Insert Point POI")
        poiAreaLabel = qsTr("Insert Area POI")
        rectangleText = qsTr("Rectangle")
        ellipseText = qsTr("Ellipse")
        polylineText = qsTr("Polyline")
        polygonText = qsTr("Polygon")
        console.log("Translated labels:", {
            hand: handText,
            cursor: cursorText,
            poiPoint: poiPointLabel,
            poiArea: poiAreaLabel
        })

        // Re-trigger POI translation when language changes
        if (PoiOptionsController.types && PoiOptionsController.types.length > 0) {
            console.log("Re-translating POI types after language change")
            onTypesChanged()
        }
    }

    function clearPoi() {
        console.log("=== CLEAR POI CALLED ===")
        console.log("Before clear - currentPoiCategory:", currentPoiCategory, "currentPoiType:", currentPoiType)
        currentPoiCategory = -1
        currentPoiType = -1
        console.log("After clear - currentPoiCategory:", currentPoiCategory, "currentPoiType:", currentPoiType)
        if (hasTools(drawingTools)) {
            console.log("Has drawing tools, setting static layer toolbar")
            setStaticLayerToolbar()
        }
    }

    ListModel { id: toolsModel }

    function hasTools(tools) {
        let hasTools = false
        console.log("=== CHECKING HAS TOOLS ===")
        console.log("Checking for tools:", tools.length > 0 ? tools[0].id : "empty tools array")
        console.log("Current toolsModel count:", toolsModel.count)

        for (let i = 0; i < toolsModel.count; i++) {
            console.log("toolsModel[" + i + "]:", JSON.stringify(toolsModel.get(i)))
            if (toolsModel.get(i).id === tools[0].id) {
                hasTools = true
                console.log("Found matching tool at index", i)
                break
            }
        }
        console.log("hasTools result:", hasTools)
        return hasTools;
    }

    function setStaticLayerToolbar() {
        console.log("=== SET STATIC LAYER TOOLBAR ===")
        console.log("Before clear - toolsModel count:", toolsModel.count)
        toolsModel.clear()
        console.log("After clear - toolsModel count:", toolsModel.count)

        console.log("Adding tools to model:")
        for (const tool of tools) {
            console.log("Adding tool:", JSON.stringify(tool))
            toolsModel.append(tool)
        }
        console.log("Final toolsModel count:", toolsModel.count)
    }

    Component.onCompleted: {
        console.log("=== COMPONENT COMPLETED ===")
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

    // Translation function for POI categories and values
    function translatePoiCategory(categoryName) {
        const categoryTranslations = {
            "Buildings": qsTr("Buildings"),
            "Docking": qsTr("Docking"),
            "Terminals": qsTr("Terminals"),
            "Container Area": qsTr("Container Area"),
            "Gates": qsTr("Gates"),
            "Structures": qsTr("Structures"),
            "Cranes": qsTr("Cranes")
        }
        return categoryTranslations[categoryName] || categoryName
    }

    function translatePoiValue(valueName) {
        const valueTranslations = {
            // Buildings
            "Office": qsTr("Office"),
            "Fuel station": qsTr("Fuel station"),
            "Mechanical workshop": qsTr("Mechanical workshop"),
            "Maintenance Building": qsTr("Maintenance Building"),
            "Worksite": qsTr("Worksite"),
            // Docking
            "Dock A": qsTr("Dock A"),
            "Dock B": qsTr("Dock B"),
            // Terminals
            "Container Terminal": qsTr("Container Terminal"),
            "Ro-Ro Terminal": qsTr("Ro-Ro Terminal"),
            // Container Area
            "Trailer Container Area": qsTr("Trailer Container Area"),
            "Container Storage Area": qsTr("Container Storage Area"),
            // Gates
            "Security Gate": qsTr("Security Gate"),
            "Terminal Gate": qsTr("Terminal Gate"),
            // Structures
            "Control Tower": qsTr("Control Tower"),
            "Bridge": qsTr("Bridge"),
            "Tunnel": qsTr("Tunnel"),
            // Cranes
            "Ship-to-Shore Crane": qsTr("Ship-to-Shore Crane"),
            "Mobile Crane": qsTr("Mobile Crane")
        }
        return valueTranslations[valueName] || valueName
    }

    function translatePoiType(type) {
        console.log("Translating type:", JSON.stringify(type))

        // Translate the category name
        let translatedType = {
            key: type.key,
            name: translatePoiCategory(type.name),
            values: []
        }

        // Translate each value
        if (type.values) {
            translatedType.values = type.values.map(value => ({
                key: value.key,
                value: translatePoiValue(value.value)
            }))
        }

        console.log("Translated to:", JSON.stringify(translatedType))
        return translatedType
    }

    Connections {
        target: PoiOptionsController
        function onTypesChanged() {
            console.log("=== POI TYPES CHANGED ===")
            console.log("PoiOptionsController.types full array:")
            console.log("Types count:", PoiOptionsController.types.length)

            // Log original data structure (keep for debugging)
            for (let i = 0; i < PoiOptionsController.types.length; i++) {
                let type = PoiOptionsController.types[i]
                console.log("Original Type[" + i + "]:", JSON.stringify(type))
            }

            // Translate all types
            let translatedTypes = PoiOptionsController.types.map(type => translatePoiType(type))
            console.log("All types translated")

            console.log("Creating point menu (slice 4+):")
            let pointTypes = translatedTypes.slice(4)
            console.log("Point types count:", pointTypes.length)

            console.log("Creating area menu (slice 0-3):")
            let areaTypes = translatedTypes.slice(0, 4)
            console.log("Area types count:", areaTypes.length)

            tools[3].menu = [
                { separator: true, label: topToolbar.poiPointLabel },
                ...pointTypes
            ]
            tools[4].menu = [
                { separator: true, label: topToolbar.poiAreaLabel },
                ...areaTypes
            ]

            console.log("Final tools[3].menu with translations:", JSON.stringify(tools[3].menu))
            console.log("Final tools[4].menu with translations:", JSON.stringify(tools[4].menu))

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
        console.log("=== SET CURRENT TOOL ===")
        console.log("Setting tool from", topToolbar.currentToolId, "to", toolId)
        topToolbar.currentToolId = toolId
        // ...existing switch logic (unchanged)...
    }

    function onPoiSelect(toolId, poiCategory, poiType) {
        console.log("=== POI SELECT ===")
        console.log("toolId:", toolId)
        console.log("poiCategory:", JSON.stringify(poiCategory))
        console.log("poiType:", JSON.stringify(poiType))

        var category = poiCategory.key
        var type = poiType.key

        console.log("Extracted category:", category)
        console.log("Extracted type:", type)

        if (toolId === "poi-area") {
            console.log("POI area selected, setting tool to rectangle")
            topToolbar.previousToolId = "rectangle"
            topToolbar.setCurrentTool("rectangle")
        } else if (toolId === "poi-point") {
            console.log("POI point selected, setting tool to point")
            topToolbar.previousToolId = "poi-point"
            topToolbar.setCurrentTool("point")
        }

        topToolbar.currentPoiCategory = category
        topToolbar.currentPoiType = type
        console.log("Final POI state - category:", topToolbar.currentPoiCategory, "type:", topToolbar.currentPoiType)
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
                    console.log("Tool loaded at index", index, ":", JSON.stringify(toolsModel.get(index)))
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
            console.log("=== LANGUAGE CHANGED ===")
            console.log("Language changed signal received - auto-retranslating TopToolbar")
            topToolbar.retranslateUi()
            // setStaticLayerToolbar() is now called inside retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("=== LANGUAGE LOAD FAILED ===")
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
