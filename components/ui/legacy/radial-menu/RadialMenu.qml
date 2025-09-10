import QtQuick
import Qt5Compat.GraphicalEffects

// Imports from legacy (left here for reference but should be removed later)
// import qml.controllers.radialmenucontroller 1.0
import qml.service.status 1.0
import qml.econtrollers 1.0
import raise.singleton.radialmenucontroller 1.0
import raise.singleton.language 1.0

import "../radial-menu" as RadialMenuWidget
import "../js/QmlComponentFactory.js" as ComponentFactory
import "../basewidgets" as Widgets

Widgets.BaseScatter {
    id: radialMenu
    width: 300
    height: width

    name: "main"
    doTranslation: true
    doScale: false
    doRotation: true
    doPress: true
    minimizable: true
    xOutLimit: true
    yOutLimit: true
    isBboxOut: false
    isBboxOutX: false
    isBboxOutY: false
    isAnchorActive: false
    visible: false

    color: "transparent"

    property real defaultWidth: (width>0) ? width : 350
    property real defaultHeight: defaultWidth
    property real placeholderWidth: 40
    property real placeholderHeight: placeholderWidth
    property real placeholderCenterX: 0
    property real placeholderCenterY: 0

    property real r: width / 2.0
    property int parts: 8
    property real angleStep: 360 / parts
    property var angles: []
    property var currentButtons: []
    property real padding: 8
    property real arcWidth: 70

    // variables to track responsiveness to screen resize
    property real relativeX: 0.5 // as a percentage of parent.width
    property real relativeY: 0.5 // as a percentage of parent.height

    property url logoSrc: ""
    property bool logoGlowPulse: false

    property string buttonFont: "RobotoRegular"

    property var onOptionToggledCallback: null

    // Automatic retranslation properties
    property string buttonLogText: qsTr("BUTTON")

    // Auto-retranslate when language changes
    function retranslateUi() {
        buttonLogText = qsTr("BUTTON")
    }

    Connections {
        target: RadialMenuController

        function onReady(ready){
            if (ready)
            {
                radialMenu.init()
                radialMenu.show(ready)
            }
        }
    }

    Item {
        id: radialMenuDefault
        anchors.fill: parent
        anchors.centerIn: parent

        RadialMenuWidget.RadialMenuInnerBckg {
            id: radialMenuInnerBckg
            anchors.centerIn: parent
            padding: 4
            width: radialMenu.width - radialMenu.arcWidth*2 - radialMenu.padding*2 - padding*2
            height: radialMenu.height - radialMenu.arcWidth*2 - radialMenu.padding*2 - padding*2
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: "#f21f3154"
            logoSrc: radialMenu.logoSrc
            fontFamily: "RobotoMedium"
            imageGlowPulse: logoGlowPulse
            imageGlowPulseRunning: logoGlowPulse

            onBackButtonClicked: function (nodeId) {
                radialMenu.handleBackButtonClicked(nodeId)
            }
        }
    }

    function init()
    {
        var rootId = RadialMenuController.getRoot().id
        changeLevel(rootId)
        radialMenu.x = parent.width/2 - radialMenu.width/2
        radialMenu.y = parent.height/2 - radialMenu.height/2
    }

    function createLevel(data)
    {
        parts = data.length
        angleStep = 360 / parts
        angles = []

        currentButtons = []

        let angle = 0
        angles.push(0)

        for (let i = 0; i < parts; i++)
        {
            angle += angleStep
            angles.push(angle)
        }

        for (let i = 0; i < angles.length - 1; i++)
        {
            // Auto-exclusivity means that only one button remains checked.
            // If another button is checked, then the previous one will be unchecked.
            const parentNode = RadialMenuController.getNode(data[i].parent)
            const autoExclusive = (parentNode.propertyTreeNode.name === 'map')

            let checkable = true

            var params = {
                "name": data[i].propertyTreeNode.name,
                "displayName": data[i].displayName,
                "nodeId": data[i].id,
                "btnStateNotify": parseNotifyStatus(data[i].serviceStatus),
                "r": r,
                "fillColor": "#000000",
                "opacity": 0.6,
                "strokeColor": "transparent",
                "strokeWidth": 0,
                "begin": angles[i] + 0.30,
                "end": angles[i+1] - 0.30,
                "shapeAntialiasing": true,
                "arcWidth": arcWidth,
                "customPadding": padding,
                "autoExclusive": autoExclusive,
                "checkable": checkable,
                "fontFamily": buttonFont
            }

            var btn = ComponentFactory.create(radialMenuDefault, params, Qt.resolvedUrl("./RadialMenuArcButton.qml"))
            currentButtons.push(btn)
            btn.clicked.connect(function(){handleButtonClicked(currentButtons[i])})
            if (data[i].propertyTreeNode.isLeaf && checkable)
                btn.checkedChanged.connect(function(){handleButtonCheckedChanged(currentButtons[i])})
            currentButtons[i].checked = data[i].active
        }
    }

    function destroyLevel()
    {
        if (currentButtons.length > 0) {
            for (let i=0; i<currentButtons.length; i++)
            {
                currentButtons[i].clicked.disconnect(function(){handleButtonClicked(currentButtons[i])})
                if(currentButtons[i].checkable)
                    currentButtons[i].checkedChanged.disconnect(function(){handleButtonCheckedChanged(currentButtons[i])})
                currentButtons[i].destroy()
            }
        }

        currentButtons = []

    }

    function changeLevel(parentId)
    {
        var nodes = RadialMenuController.getChildren(parentId)
        if(nodes && nodes.length > 0)
        {
            destroyLevel()
            createLevel(nodes)
        }
    }

    function handleButtonClicked(w)
    {
        var node = RadialMenuController.getNode(w.nodeId)
        if (!node.propertyTreeNode.isLeaf)
        {
            changeLevel(w.nodeId)
            radialMenuInnerBckg.setBackParent(w.nodeId, w.name)
            if (radialMenu.onOptionToggledCallback) {
               radialMenu.onOptionToggledCallback("", false);
            }
        }
        else
        {
            RadialMenuController.trigger(w.name, w.checkable?w.checked:w.clicked)
            RadialMenuController.setNodeActive(node.id, w.checkable?w.checked:false)
            console.log(radialMenu.buttonLogText, node.id, ":", w.checked)

            if (w.checkable && radialMenu.onOptionToggledCallback) {
                radialMenu.onOptionToggledCallback(node.propertyTreeNode.name, w.checked);
            }
        }
    }


    // Toggle for leaf menu items.
    function handleButtonCheckedChanged(w)
    {
        var node = RadialMenuController.getNode(w.nodeId)
        RadialMenuController.setNodeActive(node.id, w.checked)
        console.log(node.id, ":", w.checked)

        if (radialMenu.onOptionToggledCallback) {
            radialMenu.onOptionToggledCallback(node.propertyTreeNode.name, w.checked);
        }
    }

    function handleBackButtonClicked(nodeId)
    {
        var node = RadialMenuController.getNode(nodeId)

        changeLevel(node.parent)
        var parent = RadialMenuController.getNode(node.parent)
        radialMenuInnerBckg.setBackParent(parent.id, parent.propertyTreeNode.name, parent.propertyTreeNode.isRoot)

        if (radialMenu.onOptionToggledCallback) {
                    radialMenu.onOptionToggledCallback("", false);
                }
    }

    function parseNotifyStatus(status)
    {
        let btnStatus = RadialMenuArcButton.ButtonStateNotify.None

        switch(status) {
        case EServiceStatus.CONNECTED:
            btnStatus = RadialMenuArcButton.ButtonStateNotify.Active
            break
        case EServiceStatus.DISCONNECTED:
            btnStatus = RadialMenuArcButton.ButtonStateNotify.Inactive
            break
        case EServiceStatus.CONNECTING:
            btnStatus = RadialMenuArcButton.ButtonStateNotify.Waiting
            break
        default:
            btnStatus = RadialMenuArcButton.ButtonStateNotify.None
        }

        return btnStatus
    }

    function parseStatus(status)
    {
        let btnStatus = RadialMenuArcButton.ButtonState.None

        switch(status) {
        case EServiceStatus.CLOSED:
            btnStatus = RadialMenuArcButton.ButtonState.Default
            break
        case EServiceStatus.ACTIVE:
            btnStatus = RadialMenuArcButton.ButtonState.Selected
            break
        default:
            btnStatus = RadialMenuArcButton.ButtonState.None
        }

        return btnStatus
    }

    function show(val)
    {
        if (radialMenu.isAnchorActive && val)
            radialMenu.unminimize()
        else
            radialMenu.visible = val
    }

    // Handle responsiveness when screen is resized
    onXChanged: updateRelativePosition()
    onYChanged: updateRelativePosition()

    function updateRelativePosition() {
        if (!isAnchorActive) { // only update if not collapsed
            relativeX = x / parent.width
            relativeY = y / parent.height
        }
    }

    function repositionFromRelative() {
        if (!isAnchorActive && visible) {
            x = relativeX * parent.width
            y = relativeY * parent.height
        }
    }

    Connections {
        target: parent
        function onWidthChanged() { repositionFromRelative() }
        function onHeightChanged() { repositionFromRelative() }
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            radialMenu.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
