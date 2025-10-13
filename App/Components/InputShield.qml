import QtQuick 6.8

Item {
    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
    }

    PinchHandler {
        target: null
        grabPermissions: PointerHandler.CanTakeOverFromAnything
    }

    WheelHandler {
        grabPermissions: PointerHandler.CanTakeOverFromAnything
        acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                         ? PointerDevice.Mouse | PointerDevice.TouchPad
                         : PointerDevice.Mouse
    }

    DragHandler {
        target: null
        grabPermissions: PointerHandler.CanTakeOverFromAnything
    }
}
