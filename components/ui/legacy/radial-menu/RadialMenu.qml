import QtQuick
import Qt5Compat.GraphicalEffects

// Imports from legacy (left here for reference but should be removed later)
// import qml.controllers.radialmenucontroller 1.0
import qml.service.status 1.0
import qml.econtrollers 1.0
import raise.singleton.radialmenucontroller 1.0

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

    property url logoSrc: ""
    property bool logoGlowPulse: false

    property string buttonFont: "RobotoRegular"

    property bool ctrlReady: false


    property var lay

    Component.onCompleted: {
    }

    onBboxOut: (x,y) => {}

    // Code from legacy, it shows the connections to C++ (left here for reference but should be removed later)
    Connections {
        target: RadialMenuController
        function onReadyChanged(ctrl, ready){
            if(ready!==ctrlReady && ready)
            {
                ctrlReady = ready
                radialMenu.init()
                radialMenu.show(ready)
            }
        }

        // Part of legacy code but kept here for reference until otherwise either removed later or used
        // function onChangeServiceStatus(ctrl, elementName, status)
        // {
        //     let node = RadialMenuController.getNodeByName(elementName)
        //     updateButtonNotifyStatus(node, status)
        // }

        // function onChangeModuleStatus(ctrl, elementName, status)
        // {
        //     let node = RadialMenuController.getNodeByName(elementName)
        //     updateButtonStatus(node, status)
        // }

        function updateButtonNotifyStatus(node, status)
        {
            let state = parseNotifyStatus(status)

            if (node)
            {
                let btn  = currentButtons.filter((b) => b.nodeId === node.ID);
                if(btn.length>0)
                    btn[0].btnStateNotify = state
            }
        }

        function updateButtonStatus(node, status)
        {
            let state = parseStatus(status)
            if (node)
            {
                let btn  = currentButtons.filter((b) => b.nodeId === node.ID);
                if(btn.length>0)
                {
                    btn[0].checked = (state === RadialMenuArcButton.ButtonState.Selected) ? true : false
                }
            }
        }
    }

    Item {
        id: radialMenuDefault
        anchors.fill: parent
        anchors.centerIn: parent

        RadialMenuWidget.RadialMenuInnerBckg{
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

            onBackButtonClicked:(nodeId) => {
                                    radialMenu.handleBackButtonClicked(nodeId)
                                }
        }
    }

    function init()
    {
        ctrlReady = RadialMenuController.checkIsReady()

        if(ctrlReady)
        {
            var rootId = RadialMenuController.getRoot().ID
            changeLevel(rootId)
            radialMenu.x = parent.width/2 - radialMenu.width/2
            radialMenu.y = parent.height/2 - radialMenu.height/2
        }

        return ctrlReady
    }

    function createLevel(data)
    {
        parts = data.length
        angleStep = 360 / parts
        angles = []

        currentButtons = []


        let angle = 0
        angles.push(0)

        for (let i=0; i<parts; i++)
        {
            angle += angleStep
            angles.push(angle)
        }


        for (let i=0; i<angles.length-1; i++)
        {
            var autoExclusive = false
            var checkable = false

            switch(data[i].getCtrl()) {
              case EControllers.WmsMapController:
              {
                  autoExclusive = true
                  checkable = true
                  break
              }

              default:
              {
                  autoExclusive = false
                  checkable = true
              }

            }
            var params = {
                            "name": data[i].propertyTreeNode.NAME,
                            "displayName": data[i].getDisplayName(),
                            "nodeId": data[i].ID,
                            "btnStateNotify": parseNotifyStatus(data[i].getServiceStatus()),
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
            if (data[i].propertyTreeNode.IS_LEAF && checkable)
                btn.checkedChanged.connect(function(){handleButtonCheckedChanged(currentButtons[i])})
            currentButtons[i].checked = data[i].isActive()
            //currentButtons[i].toggle()



        }

    }

    function destroyLevel()
    {

        if(currentButtons.length > 0)
            for (let i=0; i<currentButtons.length; i++)
            {
                currentButtons[i].clicked.disconnect(function(){handleButtonClicked(currentButtons[i])})
                if(currentButtons[i].checkable)
                    currentButtons[i].checkedChanged.disconnect(function(){handleButtonCheckedChanged(currentButtons[i])})
                currentButtons[i].destroy()
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
        if (!node.propertyTreeNode.IS_LEAF)
        {
            changeLevel(w.nodeId)
            radialMenuInnerBckg.setBackParent(w.nodeId, w.name)
        }
        else
        {
            RadialMenuController.doAction(node.getCtrl(), w.name, w.checkable?w.checked:w.clicked)
            RadialMenuController.setNodeActive(node.ID, w.checkable?w.checked:false)
        }
    }


    function handleButtonCheckedChanged(w)
    {
        var node = RadialMenuController.getNode(w.nodeId)
        RadialMenuController.setNodeActive(node.ID, w.checked)
    }

    function handleBackButtonClicked(nodeId)
    {
        var node = RadialMenuController.getNode(nodeId)

        changeLevel(node.PARENT)
        var parent = RadialMenuController.getNode(node.PARENT)
        radialMenuInnerBckg.setBackParent(parent.ID, parent.propertyTreeNode.NAME, parent.propertyTreeNode.IS_ROOT)
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



}
