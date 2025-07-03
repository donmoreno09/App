import QtQuick 6.8
import QtLocation 6.8
import raise.singleton.interactionmanager 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.selectionboxbus 1.0

BaseEditor {
    objectName: "SelectionEditor"

    width: parent.width
    height: parent.height
    z: 1000

    // disable selection when dragging an map object
    enabled: InteractionModeManager.currentSelectedShapeId === ""

    property bool  dragging:  false
    property point dragStart: Qt.point(0,0)
    property point dragEnd  : Qt.point(0,0)

    DragHandler {
        target: null
        acceptedButtons: Qt.LeftButton

        // this is called first than onActiveChanged which is called
        // when the mouse has already moved therefore the accurate
        // dragStart can be taken from PointerDevice.GrabPassive transition
        onGrabChanged: function (transition, eventPoint) {
            if (transition === PointerDevice.GrabPassive) {
                dragStart = eventPoint.position
                dragEnd = dragStart
                console.log("DRAG START:", JSON.stringify(dragStart))
            }
        }

        onActiveChanged: {
            dragging = active

            if (!dragging) {
                const topLeft = map.toCoordinate(Qt.point(Math.min(dragStart.x, dragEnd.x), Math.min(dragStart.y, dragEnd.y)))
                const bottomRight = map.toCoordinate(Qt.point(Math.max(dragStart.x, dragEnd.x), Math.max(dragStart.y, dragEnd.y)))

                console.log("[SelectionEditor.onReleased] ↖️", topLeft, " ↘️", bottomRight)
                SelectionBoxBus.selected(LayerManager.focusedLayerName(), topLeft, bottomRight, InteractionModeManager.currentMode)
            }
        }

        onTranslationChanged: {
            dragEnd = centroid.position
        }
    }

    TapHandler {
        onTapped: function (event) {
            SelectionBoxBus.deselected(LayerManager.focusedLayerName(), InteractionModeManager.currentMode)
        }
    }

    Rectangle {
        visible: dragging
        x: Math.min(dragStart.x, dragEnd.x)
        y: Math.min(dragStart.y, dragEnd.y)
        width : Math.abs(dragEnd.x - dragStart.x)
        height: Math.abs(dragEnd.y - dragStart.y)
        color: "#4488cc88"
        border.color: "blue"
        border.width: 1
        z: 1100
    }
}
