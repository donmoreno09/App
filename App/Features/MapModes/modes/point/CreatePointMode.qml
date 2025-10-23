import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0

PointMode {
    id: root

    // Properties
    property geoCoordinate coord: QtPositioning.coordinate()

    // Input handlers
    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds

        onTapped: function (event) {
            const point = map.mapFromItem(root, event.position)
            coord = map.toCoordinate(point, false)
        }
    }

    MapQuickItem {
        id: mapPoint

        coordinate: coord
        z: Theme.elevation.z100
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2
        sourceItem:  Image {
            id: svgIcon
            width: 24
            height: 24
            source: "qrc:/App/assets/icons/poi.svg"
            smooth: true
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "white"
                shadowBlur: 0.0            // 0 = sharp edge
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowScale: 1.12          // thickness of the border
            }
        }

        DragHandler {
            onTranslationChanged: {
                coord = mapPoint.coordinate
            }
        }
    }
}
