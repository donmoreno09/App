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
        anchorPoint.x: svgIcon.width / 2
        anchorPoint.y: svgIcon.height / 2

        sourceItem: Item {
            width: svgIcon.width
            height: svgIcon.height

            Image {
                id: svgIcon
                width: 24
                height: 24
                source: "qrc:/components/ui/assets/annotation.svg"
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: svgIcon.bottom
                anchors.topMargin: 4
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
            id: rectItem
            width: svgIcon.width
            height: svgIcon.height
            radius: (svgIcon.width + 12) / 2
            color: "white"
            border.color: "white"
            border.width: 4
        }
    }
}
