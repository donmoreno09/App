import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import ".."

BaseMode {
    signal topLeftChanged()
    signal bottomRightChanged()

    function rectToPoints(rect /* { topLeft: coordinate, bottomRight: coordinate } */) {
        const lat1 = rect.topLeft.latitude
        const lon1 = rect.topLeft.longitude
        const lat2 = rect.bottomRight.latitude
        const lon2 = rect.bottomRight.longitude

        return [
            { x: lon1, y: lat1 }, // top-left
            { x: lon2, y: lat1 }, // top-right
            { x: lon2, y: lat2 }, // bottom-right
            { x: lon1, y: lat2 }, // bottom-left
            { x: lon1, y: lat1 }  // close polygon
        ]
    }
}
