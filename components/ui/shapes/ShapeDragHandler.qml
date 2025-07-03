import QtQuick 2.15

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

DragHandler {
    id: handler

    property var handleTranslationChange // : () => void
    property bool dragEnabled: true // initially true unless set otherwise

    signal grabbed()
    signal dragged()
    signal released()

    enabled: dragEnabled && InteractionModeManager.currentSelectedShapeId === modelData.id

    // this is called first than onActiveChanged
    // which is called when the mouse has already moved
    onGrabChanged: function (transition, eventPoint) {
        if (transition === PointerDevice.GrabPassive) {
            grabbed()
        }
    }

    onActiveChanged: {
        if (!active) released()
        else dragged()
    }

    onTranslationChanged: {
        handleTranslationChange()
    }
}
