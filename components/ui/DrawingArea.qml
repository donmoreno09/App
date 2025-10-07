import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import QtQuick.Shapes 6.8
import raise.singleton.interactionmanager 1.0

Item {
    property Map map
    property alias loader: loader

    readonly property var editorMap: ({
        [InteractionModeManager.Hand]          : Qt.resolvedUrl("./editors/PanEditor.qml"),
        [InteractionModeManager.Cursor]        : Qt.resolvedUrl("./editors/SelectionEditor.qml"),
        [InteractionModeManager.DrawPoint]     : Qt.resolvedUrl("./editors/PointEditor.qml"),
        [InteractionModeManager.DrawRectangle] : Qt.resolvedUrl("./editors/RectangleEditor.qml"),
        [InteractionModeManager.DrawEllipse]   : Qt.resolvedUrl("./editors/EllipseEditor.qml"),
        [InteractionModeManager.DrawPolyline]  : Qt.resolvedUrl("./editors/PolylineEditor.qml"),
        [InteractionModeManager.DrawPolygon]   : Qt.resolvedUrl("./editors/PolygonEditor.qml")
    })

    Loader {
        id: loader
        anchors.fill: parent
        source: editorMap[InteractionModeManager.currentMode]
        onLoaded: {
            if (!item) return

            item.map = map
            item.wms = root
            map.addMapItemGroup(item)
        }
    }
}
