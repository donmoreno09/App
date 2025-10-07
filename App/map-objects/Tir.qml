import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapQuickItem {
    id: tir

    required property string operationCode
    required property geoCoordinate pos
    required property double cog
    required property int state

    coordinate: tir.pos

    sourceItem: Item {
        id: tirRect
        width: 40
        height: 40
        opacity: tir.state === 1 ? 0.5 : 1.0

        // COG direction vector (track heading line)
        Rectangle {
            id: cogLine
            width: 2
            height: 40  // Length of the heading vector
            color: "black"
            x: tirRect.width / 2 - width / 2
            y: tirRect.height / 2 - height

            transform: Rotation {
                origin.x: cogLine.width / 2
                origin.y: cogLine.height
                angle: tir.cog
            }
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.centerIn: parent
            source: "qrc:/App/assets/icons/track/smartport/smart_tir.svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: tir.state === 1 ? 0.5 : 1.0
        }

        Text {
            id: tirLabel
            text: tir.operationCode
            font.pixelSize: 12
            color: "black"
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
        }
    }
}
