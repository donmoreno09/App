import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapItemGroup {
    id: root

    required property var history
    required property geoCoordinate pos
    required property string state

    property int lineWidth: 2
    property real staleOpacityLine: 0.3
    property real freshOpacityLine: 0.7
    property real zBase: -1

    MapPolyline {
        id: historyLine

        property var _path: {
            if (!root.history || !root.history.length)
                return []
            var points = root.history.map(t => QtPositioning.coordinate(t[0], t[1], t[2]))
            points.push(root.pos)
            return points
        }

        path: _path
        line.width: root.lineWidth
        line.color: "black"
        opacity: root.state === "STALE" ? root.staleOpacityLine : root.freshOpacityLine
        antialiasing: true
        visible: _path.length > 1
        z: root.zBase
    }

    // start point marker
    MapQuickItem {
        id: startMarker
        coordinate: historyLine._path.length ? historyLine._path[0] : QtPositioning.coordinate()
        visible: historyLine._path.length > 0
        anchorPoint.x: 6; anchorPoint.y: 6
        z: root.zBase + 0.01

        sourceItem: Rectangle {
            width: 12; height: 12; radius: 6
            color: "#2ecc71"
            border.color: "black"; border.width: 1
            opacity: root.state === "STALE" ? 0.5 : 1.0
        }
    }
}
