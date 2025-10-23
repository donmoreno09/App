import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

Item {
    id: root

    required property Map map

    signal tapped(var event) // coord: QGeoCoordinate, point: QPointF

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds

        onTapped: function (event) {
            const point = map.mapFromItem(root, event.position)
            const coord = map.toCoordinate(point, false)
            root.tapped({ coord, point })
        }
    }

    function pointToGeo(point: point): geoCoordinate {
        const pInMap = map.mapFromItem(root, event.position)
        return map.toCoordinate(pInMap, false)
    }

    function geoToPoint(coord: geoCoordinate): point {
        return root.mapFromItem(map, map.fromCoordinate(coord, false))
    }
}
