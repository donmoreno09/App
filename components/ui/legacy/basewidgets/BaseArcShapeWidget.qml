import QtQuick
import QtQuick.Shapes

import Qt5Compat.GraphicalEffects


import "../basewidgets" as Widgets


Widgets.BaseArcShape {
    id: baseShapeWidget

    containsMode: Shape.FillContains

    property bool doPress: false

    signal pressed (PointerHandler handler, Item item)
    signal doublePressed (PointerHandler handler, Item item)
    signal longPressed (PointerHandler handler, Item item)

    TapHandler {
        id: baseShapeWidgetTapHandler

        enabled: doPress

        gesturePolicy: TapHandler.ReleaseWithinBounds | TapHandler.WithinBounds

        grabPermissions: PointerHandler.ApprovesTakeOverByHandlersOfSameType

        onTapped:(eventPoint, deviceBtn)=> {baseShapeWidget.pressed(baseShapeWidgetTapHandler, parent)}
        onSingleTapped:(eventPoint, deviceBtn)=> {}
        onDoubleTapped:(eventPoint, deviceBtn)=> {baseShapeWidget.doublePressed(baseShapeWidgetTapHandler, parent)}
        onLongPressed:() => {baseShapeWidget.longPressed(baseShapeWidgetTapHandler, parent)}

        onGrabChanged: (transition, eventPoint) => {
                       if (transition === PointerDevice.UngrabExclusive)
                           {}
                       }

        onTimeHeldChanged: () => {}

    }

}
