import QtQuick

Rectangle {

    id: basePanel

    property string name: ""
    property bool doPress: true

    property real _centerX: basePanel.x + basePanel.width/2  //internal Center X property
    property real _centerY: basePanel.y + basePanel.height/2 //internal Center Y property
    property real centerX: _centerX //exposed Center X property
    property real centerY: _centerY //exposed Center Y property

    signal pressed (PointerHandler handler, Item item)
    signal doublePressed (PointerHandler handler, Item item)
    signal longPressed (PointerHandler handler, Item item)


    TapHandler {
        id: basePanelTapHandler

        enabled: doPress

        gesturePolicy: TapHandler.ReleaseWithinBounds | TapHandler.WithinBounds

        onTapped:(eventPoint, deviceBtn)=> {basePanel.pressed(basePanelTapHandler, parent)}
        onSingleTapped:(eventPoint, deviceBtn)=> {}
        onDoubleTapped:(eventPoint, deviceBtn)=> {basePanel.doublePressed(basePanelTapHandler, parent)}
        onLongPressed:() => {basePanel.longPressed(basePanelTapHandler, parent)}

        onGrabChanged: (transition, eventPoint) => {
                       if (transition === PointerDevice.UngrabExclusive)
                           {}
                       }

        onTimeHeldChanged: () => {}

    }


    function saveCenter()
    {
        basePanel._centerX = basePanel.x + basePanel.width/2
        basePanel._centerY = basePanel.y + basePanel.height/2
    }

    function applyCenter(cX, cY)
    {
        basePanel._centerX = cX
        basePanel._centerY = cY
        basePanel.x = basePanel._centerX - basePanel.width/2
        basePanel.y = basePanel._centerY - basePanel.height/2

    }

    onXChanged: () => {

                    saveCenter()

                    if(basePanel.xOutLimit)
                    {
                        if (x >= xBRule.maximum)
                        {
                            //console.log("x out right", x)
                            basePanel.bboxOut(x,y)
                        }


                        if (x <= xBRule.minimum)
                        {
                            basePanel.bboxOut(x,y)
                            //console.log("x out left", x)

                        }

                    }



                }
    onYChanged: () => {

                    saveCenter()

                    if(basePanel.yOutLimit)
                        {

                        if (y >= yBRule.maximum)
                        {
                            basePanel.bboxOut(x,y)
                            //console.log("y out bottom", y)
                        }

                        if (y <= yBRule.minimum)
                        {
                            basePanel.bboxOut(x,y)
                            //console.log("y out top", y)
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

                         applyCenter(basePanel.centerX, basePanel.centerY)

                      }

    onCenterYChanged: () => {
                         applyCenter(basePanel.centerX, basePanel.centerY)
                      }


}
