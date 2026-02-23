import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapQuickItem {
    id: root

    required property MapPolyline line
    required property string state

    coordinate: line.path.length ? line.path[0] : QtPositioning.coordinate()
    visible: line.path.length > 0
    anchorPoint.x: 6
    anchorPoint.y: 6

    sourceItem: Rectangle {
        width: 12; height: 12; radius: 6
        color: "#2ecc71"
        border.color: "black"; border.width: 1
        opacity: root.state === "STALE" ? 0.5 : 1.0
    }
}
