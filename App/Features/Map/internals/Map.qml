/*!
    \qmltype Map
    \inqmlmodule App.Features.Map
    \brief A Map component which imports map behaviours logic
           such as panning, zooming, etc. from Qt's MapView component.

    Qt's documentation actually does say to grab their MapView component
    and use it however we want. The main idea here is that instead of
    having a wrapper component like MapView, we instead integrate it
    into one Map component.

    For more information, check [MapView QML Type](https://doc.qt.io/qt-6/qml-qtlocation-mapview.html).
*/

import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import Qt.labs.animation 6.8

import App.Themes 1.0
import App.Features.MapTools 1.0

Map {
    id: map

    Component.onCompleted: resetPinchMinMax()

    tilt: tiltHandler.persistentTranslation.y / -5
    property bool pinchAdjustingZoom: false

    BoundaryRule on zoomLevel {
        id: br
        minimum: map.minimumZoomLevel
        maximum: map.maximumZoomLevel
    }

    onZoomLevelChanged: {
        br.returnToBounds();
        if (!pinchAdjustingZoom) resetPinchMinMax()
    }

    function resetPinchMinMax() {
        pinch.persistentScale = 1
        pinch.scaleAxis.minimum = Math.pow(2, map.minimumZoomLevel - map.zoomLevel + 1)
        pinch.scaleAxis.maximum = Math.pow(2, map.maximumZoomLevel - map.zoomLevel - 1)
    }

    PinchHandler {
        id: pinch
        target: null

        property real rawBearing: 0
        property geoCoordinate startCentroid

        onActiveChanged: if (active) {
            flickAnimation.stop()
            pinch.startCentroid = map.toCoordinate(pinch.centroid.position, false)
        } else {
            flickAnimation.restart(centroid.velocity)
            map.resetPinchMinMax()
        }

        onScaleChanged: (delta) => {
            map.pinchAdjustingZoom = true
            map.zoomLevel += Math.log2(delta)
            map.alignCoordinateToPoint(pinch.startCentroid, pinch.centroid.position)
            map.pinchAdjustingZoom = false
        }

        onRotationChanged: (delta) => {
            pinch.rawBearing -= delta
            // snap to 0° if we're close enough
            map.bearing = (Math.abs(pinch.rawBearing) < 5) ? 0 : pinch.rawBearing
            map.alignCoordinateToPoint(pinch.startCentroid, pinch.centroid.position)
        }

        grabPermissions: PointerHandler.TakeOverForbidden
    }

    WheelHandler {
        id: wheel

        // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
        // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
        // and we don't yet distinguish mice and trackpads on Wayland either
        acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                         ? PointerDevice.Mouse | PointerDevice.TouchPad
                         : PointerDevice.Mouse

        onWheel: (event) => {
            const loc = map.toCoordinate(wheel.point.position)
            switch (event.modifiers) {
                case Qt.NoModifier:
                    map.zoomLevel += event.angleDelta.y / 120
                    break
                case Qt.ShiftModifier:
                    map.bearing += event.angleDelta.y / 15
                    break
                case Qt.ControlModifier:
                    map.tilt += event.angleDelta.y / 15
                    break
            }
            map.alignCoordinateToPoint(loc, wheel.point.position)
        }
    }

    DragHandler {
        id: drag

        target: null

        onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)

        onActiveChanged: if (active) {
            flickAnimation.stop()
        } else {
            flickAnimation.restart(centroid.velocity)
        }
    }

    property vector3d animDest
    onAnimDestChanged: if (flickAnimation.running) {
        const delta = Qt.vector2d(animDest.x - flickAnimation.animDestLast.x, animDest.y - flickAnimation.animDestLast.y)
        map.pan(-delta.x, -delta.y)
        flickAnimation.animDestLast = animDest
    }

    Vector3dAnimation on animDest {
        id: flickAnimation

        property vector3d animDestLast

        from: Qt.vector3d(0, 0, 0)
        duration: 500
        easing.type: Easing.OutQuad

        function restart(vel) {
            stop()
            map.animDest = Qt.vector3d(0, 0, 0)
            animDestLast = Qt.vector3d(0, 0, 0)
            to = Qt.vector3d(vel.x / duration * 100, vel.y / duration * 100, 0)
            start()
        }
    }

    DragHandler {
        id: tiltHandler

        minimumPointCount: 2
        maximumPointCount: 2
        target: null
        xAxis.enabled: false
        grabPermissions: PointerHandler.TakeOverForbidden

        onActiveChanged: if (active) flickAnimation.stop()
    }

    InputHandler {
        id: inputHandler
        anchors.fill: parent
        map: map
        Component.onCompleted: ToolController.inputHandler = inputHandler
    }

    MapQuickItem {
        visible: ToolController.activeTool === ToolRegistry.pointTool && ToolRegistry.pointTool.editable == null
        onVisibleChanged: console.log("Preview is now", visible ? "active" : "hidden")
        z: Theme.elevation.z100

        coordinate: ToolRegistry.pointTool.coord
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2
        sourceItem: Rectangle {
            width: 12
            height: 12
            color: "white"
            radius: width / 2
            border.color: "blue"
            border.width: 2
        }
    }
}
