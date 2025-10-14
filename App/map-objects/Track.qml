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
    anchorPoint.x: sourceItem.width / 2
    anchorPoint.y: sourceItem.height / 2

    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40
        opacity: track.state === 1 ? 0.5 : 1.0

        TriangleHeading {
            heading: track.cog
            centerItem: image
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
