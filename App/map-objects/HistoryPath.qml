import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapPolyline {
    id: root
    z: -1

    required property var history
    required property geoCoordinate pos
    required property string state

    property int lineWidth: 2
    property real staleOpacityLine: 0.3
    property real freshOpacityLine: 0.7

    line.width: root.lineWidth
    line.color: "black"
    opacity: root.state === "STALE" ? root.staleOpacityLine : root.freshOpacityLine
    antialiasing: true
    visible: path.length > 1
    path: {
        if (!root.history || !root.history.length)
            return []
        var points = root.history.map(t => QtPositioning.coordinate(t[0], t[1], t[2]))
        points.push(root.pos)
        return points
    }
}
