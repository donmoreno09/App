import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

import "../../models/shapes.js" as ShapeModel
import "../../"

BaseShape {
    id: root

    MapQuickItem {
        id: mapItem

        coordinate: ShapeModel.toQtCoordinate(modelData.geometry.coordinate, QtPositioning)
        anchorPoint.x: 20
        anchorPoint.y: 20

        sourceItem: Rectangle {
            id: rectItem

            width: 40
            height: 40
            radius: 2
            color: root.color
            border.color: root.bgColor
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: modelData.label
                font.pixelSize: 12
                color: "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }

        ShapeTapHandler {}

        ShapeDragHandler {
            handleTranslationChange: function () {
                const newModelData = JSON.parse(JSON.stringify(modelData))
                newModelData.geometry.coordinate.x = mapItem.coordinate.longitude
                newModelData.geometry.coordinate.y = mapItem.coordinate.latitude
                root.syncModelData(newModelData)
            }

            onReleased: {
                root.modified()
            }
        }
    }

    MapQuickItem {
        id: highlight
        visible: InteractionModeManager.currentSelectedShapeId === modelData.id
        z: mapItem.z - 1

        coordinate: mapItem.coordinate
        anchorPoint.x: mapItem.anchorPoint.x
        anchorPoint.y: mapItem.anchorPoint.y

        sourceItem: Rectangle {
            width: rectItem.width
            height: rectItem.height
            radius: rectItem.radius
            color: "transparent"
            border.color: "white"
            border.width: rectItem.width + 10
        }
    }
}
