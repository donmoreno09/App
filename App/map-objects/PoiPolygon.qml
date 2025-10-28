import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.MapModes 1.0

MapItemGroup {
    id: root
    z: Theme.elevation.z100 + (isEditing) ? 100 : 0

    property bool isDraggingHandle: false

    MapPolygon {
        id: polygon
        color: "#22448888"
        border.color: "green"
        border.width: 2
        path: coordinates
        z: root.z
    }

    Text {
        anchors.centerIn: polygon
        text: label
        font.pixelSize: 12
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }
}
