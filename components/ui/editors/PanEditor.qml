import QtQuick 6.8
import QtPositioning 6.8
import QtLocation 6.8

BaseEditor {
    objectName: "PanEditor"

    MouseArea {
        id: panEditor
        anchors.fill: parent
        drag.target: null

        property real lastX
        property real lastY

        onPressed: (mouse) => {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: (mouse) => {
            let dx = mouse.x - lastX
            let dy = mouse.y - lastY

            let metersPerPixel = 156543.03 * Math.cos(map.center.latitude * Math.PI / 180) / Math.pow(2, map.zoomLevel)
            let deltaLon = (dx * metersPerPixel) / (111320 * Math.cos(map.center.latitude * Math.PI / 180))
            let deltaLat = (dy * metersPerPixel) / 110540

            let newLat = map.center.latitude + deltaLat
            let newLon = map.center.longitude - deltaLon

            map.center = QtPositioning.coordinate(newLat, newLon)

            console.log("[PanArea] panning x: " + mouse.x + " y: " + mouse.y)

            lastX = mouse.x
            lastY = mouse.y
        }
    }
}
