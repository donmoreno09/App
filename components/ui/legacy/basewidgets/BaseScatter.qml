import QtQuick
import Qt.labs.animation

import "../basewidgets" as Widgets
import "../js/QmlComponentFactory.js" as ComponentFactory

Widgets.BaseKinetic {
    id: baseScatter

    property string name: ""

    property bool doPress: false

    property bool doScale: false
    property real minScale: 0.5
    property real maxScale: 8


    property bool doTranslation: false
    property bool doTranslationX: true
    property bool doTranslationY: true

    property bool doRotation: false
    property real minRotation: -Infinity
    property real maxRotation: Infinity

    property bool kinetic: true
    property real kineticFriction: 4.0
    property real kineticPulseFactor: 1.0
    property real kineticThreshold: 1.0
    kIsActive: kinetic
    kPulseFactor: kineticPulseFactor
    kFrictionFactor: kineticFriction
    kThresholdFactor: kineticThreshold

    property bool minimizable: false
    property bool isAnchorActive: false
    property var anchor: null
    property bool isMinimized: false
    property int collapsedOrientation: -1 // store last collapsed edge
    property real anchorRelativeOffset: 0.5 // percentage (0.0 = left/top, 1.0 = right/bottom)


    property bool xOutLimit: true
    property bool yOutLimit: true

    property real xOutMinLimit
    property real xOutMaxLimit

    property real yOutMinLimit
    property real yOutMaxLimit

    property real deltaOutLimit: 50
    property bool isBboxOut: false
    property bool isBboxOutX: false
    property bool isBboxOutY: false

    property string backgroundImage

    property real _centerX: baseScatter.x + baseScatter.width/2  //internal Center X property
    property real _centerY: baseScatter.y + baseScatter.height/2 //internal Center Y property
    property real centerX: _centerX //exposed Center X property
    property real centerY: _centerY //exposed Center Y property

    property var afterAnchorPos: [parent.width/2, parent.height/2]

    property alias xBboxRule: xBRule
    property alias yBboxRule: yBRule


    signal pressed (PointerHandler handler, Item item)
    signal doublePressed (PointerHandler handler, Item item)
    signal longPressed (PointerHandler handler, Item item)

    signal transformScale(PointerHandler handler, Item item, real delta)
    signal transformRotation(PointerHandler handler, Item item, real delta)
    signal move(PointerHandler handler, Item item, vector2d delta)
    signal bboxOut(real x, real y)
    signal minimized(bool val)



    Component.onCompleted: {

        setBBOXLimits()

    }

    Connections {
        target: parent
        function onWidthChanged(){
            setBBOXLimits()
        }

        function onHeightChanged(){
            setBBOXLimits()
        }

    }

    BoundaryRule on x {
           id: xBRule
           minimum: -Infinity
           maximum:  Infinity

       }

    BoundaryRule on y {
           id: yBRule
           minimum: -Infinity
           maximum:  Infinity

       }

    Image {
        id: baseScatterBckgImage
        enabled: baseScatter.backgroundImage && baseScatter.backgroundImage.length !== 0
        source: baseScatter.backgroundImage
        anchors.fill: parent
    }



    TapHandler {
        id: baseScatterTapHandler

        enabled: doPress

        gesturePolicy: TapHandler.ReleaseWithinBounds | TapHandler.WithinBounds

        onTapped:(eventPoint, deviceBtn)=> {baseScatter.pressed(baseScatterTapHandler, parent)}
        onSingleTapped:(eventPoint, deviceBtn)=> {}
        onDoubleTapped:(eventPoint, deviceBtn)=> {baseScatter.doublePressed(baseScatterTapHandler, parent)}
        onLongPressed:() => {baseScatter.longPressed(baseScatterTapHandler, parent)}

        onGrabChanged: (transition, eventPoint) => {
                       if (transition === PointerDevice.UngrabExclusive)
                           {}
                       }

        onTimeHeldChanged: () => {}

    }

    PinchHandler {
        id: baseScatterPinchHandler

        grabPermissions: PointerHandler.CanTakeOverFromAnything | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.CanTakeOverFromItems
        minimumPointCount: 2

        dragThreshold: 0

        rotationAxis.enabled: doRotation
        rotationAxis.minimum: minRotation
        rotationAxis.maximum: maxRotation

        scaleAxis.enabled: doScale
        scaleAxis.minimum: minScale
        scaleAxis.maximum: maxScale

        xAxis.enabled: doTranslation && doTranslationX
        yAxis.enabled: doTranslation && doTranslationY

        onScaleChanged: (delta) => {
                            if (baseScatter.doScale)
                                baseScatter.transformScale(baseScatterPinchHandler, parent, delta)
                        }
        onRotationChanged: (delta) => {
                               if (baseScatter.doRotation)
                                    baseScatter.transformRotation(baseScatterPinchHandler, parent, delta)
                           }
        onTranslationChanged: (delta) => {
                                  if (baseScatter.doTranslation)
                                    baseScatter.move(baseScatterPinchHandler, parent, delta)
                              }

        onGrabChanged: (transition, eventPoint) => {}

    }

    DragHandler {
        id: baseScatterDragHandler
//        target: null
        dragThreshold: 0

        grabPermissions: PointerHandler.CanTakeOverFromAnything | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.CanTakeOverFromItems
        enabled: doTranslation

        xAxis.enabled: doTranslation && doTranslationX
        yAxis.enabled: doTranslation && doTranslationY

        xAxis.minimum: -Infinity
        xAxis.maximum: Infinity

        yAxis.minimum: -Infinity
        yAxis.maximum: Infinity



//        onActiveChanged: if(active) {
//
//                         }
//                         else
//                         {
//                         }

        onTranslationChanged: (delta) => {
//                                  parent.x += delta.x
//                                  parent.y += delta.y

                                  kTranslationChange(delta, parent.x, parent.y)
                                  baseScatter.move(baseScatterDragHandler, parent, delta)


                              }
        onGrabChanged: (transition, eventPoint) => {

                           kGrabChange(transition, eventPoint, parent.x, parent.y)

                       }



    }

    function show(val)
    {
        baseScatter.visible = val
    }

    function setBBOXLimits(){

        if (baseScatter.xOutLimit)
        {
            baseScatterDragHandler.xAxis.minimum = (!baseScatter.xOutMinLimit) ? - baseScatter.width / 2  - baseScatter.deltaOutLimit: baseScatter.xOutMinLimit
            baseScatterDragHandler.xAxis.maximum = (!baseScatter.xOutMaxLimit) ? parent.width - baseScatter.width / 2 + baseScatter.deltaOutLimit: baseScatter.xOutMaxLimit

            xBRule.minimum = baseScatterDragHandler.xAxis.minimum
            xBRule.maximum = baseScatterDragHandler.xAxis.maximum

        }


        if (baseScatter.yOutLimit)
        {
            baseScatterDragHandler.yAxis.minimum = (!baseScatter.yOutMinLimit) ? - baseScatter.height / 2 - baseScatter.deltaOutLimit: baseScatter.yOutMinLimit
            baseScatterDragHandler.yAxis.maximum = (!baseScatter.yOutMaxLimit) ? parent.height - baseScatter.height / 2 + baseScatter.deltaOutLimit: baseScatter.yOutMaxLimit

            yBRule.minimum = baseScatterDragHandler.yAxis.minimum
            yBRule.maximum = baseScatterDragHandler.yAxis.maximum
        }

    }

    function saveCenter()
    {
        baseScatter._centerX = baseScatter.x + baseScatter.width/2
        baseScatter._centerY = baseScatter.y + baseScatter.height/2
    }

    function applyCenterX(cX)
    {
        baseScatter._centerX = cX
        baseScatter.x = baseScatter._centerX - baseScatter.width/2

    }

    function applyCenterY(cY)
    {
        baseScatter._centerY = cY
        baseScatter.y = baseScatter._centerY - baseScatter.height/2

    }


    function reposBeforeAnchor()
    {
        if (baseScatter._centerX > parent.width)
        {

            baseScatter.applyCenterX(parent.width)
            baseScatter.applyCenterY(baseScatter._centerY)

        }

        if (baseScatter._centerX < 0)
        {
            baseScatter.applyCenterX(0)
            baseScatter.applyCenterY(baseScatter._centerY)

        }

        if (baseScatter._centerY > parent.height)
        {
            baseScatter.applyCenterY(parent.height)
            baseScatter.applyCenterX(baseScatter._centerX)
        }

        if (baseScatter._centerY < 0)
        {
            baseScatter.applyCenterY(0)
            baseScatter.applyCenterX(baseScatter._centerX)


        }
    }

    function reposAfterAnchor(pos=null, center=null)
    {
        let p = afterAnchorPos
        if (pos!==null)
            p = [pos[0] + baseScatter.width/2, pos[1] + baseScatter.height/2]
        else if (center!==null)
            p = center

        baseScatter.isBboxOut = false
        baseScatter.isBboxOutX = false
        baseScatter.isBboxOutY = false
        baseScatter.applyCenterX(p[0])
        baseScatter.applyCenterY(p[1])


    }

    function handleAnchorPressed(evtHandler, w)
    {
        baseScatter.unminimize()
    }

    function activeAnchor(val, orientation=null)
    {

        if (val)
        {
            var params = {
                "name": "scatterAnchor_"+baseScatter.name,
                "label": baseScatter.name
            }
            var anchor = ComponentFactory.create(parent, params, Qt.resolvedUrl("./BaseScatterAnchor.qml"))
            baseScatter.anchor = anchor
            anchor.pressed.connect(handleAnchorPressed)
            anchor.centerX = baseScatter._centerX
            anchor.centerY = baseScatter._centerY
            anchor.dispose(orientation)

        }
        else{
                baseScatter.destroyAnchor()



        }

        baseScatter.isAnchorActive = val


    }

    function destroyAnchor()
    {
        if (baseScatter.anchor!==null)
        {
            baseScatter.anchor.pressed.disconnect(handleAnchorPressed)
            baseScatter.anchor.destroy()
            baseScatter.anchor = null
        }


    }

    function unminimize(pos=null)
    {
        baseScatter.activeAnchor(false)
        baseScatter.show(true)
        baseScatter.reposAfterAnchor(pos)
        baseScatter.isMinimized = false
        baseScatter.minimized(false)
    }

    function minimize(orientation)
    {

        //baseScatter.kReset()
        baseScatter.reposBeforeAnchor()
        baseScatter.collapsedOrientation = orientation

        switch (orientation) {
        case BaseScatterAnchor.Orientation.Bottom:
        case BaseScatterAnchor.Orientation.Top:
            baseScatter.anchorRelativeOffset = (baseScatter._centerX) / parent.width;
            break;
        case BaseScatterAnchor.Orientation.Left:
        case BaseScatterAnchor.Orientation.Right:
            baseScatter.anchorRelativeOffset = (baseScatter._centerY) / parent.height;
            break;
        }

        baseScatter.activeAnchor(true, orientation)
        baseScatter.show(false)
        baseScatter.isMinimized = true
        baseScatter.minimized(true)
    }

    onXChanged: () => {


                    saveCenter()
                    if(baseScatter.visible)
                    {
                            if(baseScatter.xOutLimit)
                            {
                                let orientation = null
                                if (x >= xBRule.maximum)
                                {
                                    baseScatter.bboxOut(x,y)
                                    baseScatter.isBboxOutX = true
                                    baseScatter.isBboxOut = true
                                    orientation = BaseScatterAnchor.Orientation.Right
                                }


                                else if (x <= xBRule.minimum)
                                {
                                    baseScatter.bboxOut(x,y)
                                    baseScatter.isBboxOutX = true
                                    baseScatter.isBboxOut = true
                                    orientation = BaseScatterAnchor.Orientation.Left

                                }

                                else
                                {
                                    baseScatter.isBboxOutX = false
                                    if (!baseScatter.isBboxOutY)
                                        baseScatter.isBboxOut = false
                                }

                                if (baseScatter.isBboxOutX && baseScatter.minimizable && !baseScatter.isAnchorActive)
                                    baseScatter.minimize(orientation)


                            }
                    }





                }
    onYChanged: () => {


                    saveCenter()

                    if (baseScatter.visible)
                    {
                        if(baseScatter.yOutLimit)
                            {
                                let orientation = null

                                if (y >= yBRule.maximum)
                                {
                                    baseScatter.bboxOut(x,y)
                                    baseScatter.isBboxOutY = true
                                    baseScatter.isBboxOut = true
                                    orientation = BaseScatterAnchor.Orientation.Bottom
                                }

                                else if (y <= yBRule.minimum)
                                {
                                    baseScatter.bboxOut(x,y)
                                    baseScatter.isBboxOutY = true
                                    baseScatter.isBboxOut = true
                                    orientation = BaseScatterAnchor.Orientation.Top
                                }

                                else
                                {
                                    baseScatter.isBboxOutY = false
                                    if (!baseScatter.isBboxOutX)
                                        baseScatter.isBboxOut = false
                                }

                                if (baseScatter.isBboxOutY && baseScatter.minimizable && !baseScatter.isAnchorActive)
                                    baseScatter.minimize(orientation)

                        }
                    }



                }

    onWidthChanged: () => {

                        saveCenter()

                    }

    onHeightChanged: () => {
                         saveCenter()
                     }

    onCenterXChanged: () => {

                         applyCenterX(baseScatter.centerX)

                      }

    onCenterYChanged: () => {
                         applyCenterY(baseScatter.centerY)
                      }

    function realignAnchor() {
        if (!baseScatter.isAnchorActive || !baseScatter.anchor)
            return;

        switch (baseScatter.collapsedOrientation) {
        case BaseScatterAnchor.Orientation.Right:
            baseScatter.anchor.centerX = parent.width;
            baseScatter.anchor.centerY = baseScatter.anchorRelativeOffset * parent.height;
            break;
        case BaseScatterAnchor.Orientation.Left:
            baseScatter.anchor.centerX = 0;
            baseScatter.anchor.centerY = baseScatter.anchorRelativeOffset * parent.height;
            break;
        case BaseScatterAnchor.Orientation.Bottom:
            baseScatter.anchor.centerX = baseScatter.anchorRelativeOffset * parent.width;
            baseScatter.anchor.centerY = parent.height;
            break;
        case BaseScatterAnchor.Orientation.Top:
            baseScatter.anchor.centerX = baseScatter.anchorRelativeOffset * parent.width;
            baseScatter.anchor.centerY = 0;
            break;
        }
    }

    Connections {
        target: baseScatter.parent
        function onWidthChanged() { realignAnchor() }
        function onHeightChanged() { realignAnchor() }
    }


}
