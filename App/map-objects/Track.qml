import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapQuickItem {
    id: track

    required property string code
    required property geoCoordinate pos
    required property double cog
    required property int state
    required property int trackNumber

    coordinate: track.pos

    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40
        opacity: track.state === 1 ? 0.5 : 1.0

        // COG direction vector (track heading line)
        Rectangle {
            id: cogLine
            width: 2
            height: 40  // Length of the heading vector
            color: "black"
            x: trackRect.width / 2 - width / 2
            y: trackRect.height / 2 - height

            transform: Rotation {
                origin.x: cogLine.width / 2
                origin.y: cogLine.height
                angle: track.cog
            }
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.centerIn: parent
            source: "qrc:/App/assets/icons/track/smartport/" + track.code.substring(0,2) + "/" + track.code.substring(2,4) + "/" + track.code.substring(4,6) + "/" + track.code + ".svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: track.state === 1 ? 0.5 : 1.0
        }

        Text {
            id: trackLabel
            text: "T" + track.trackNumber.toString()
            font.pixelSize: 12
            color: "black"
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
        }
    }
}
