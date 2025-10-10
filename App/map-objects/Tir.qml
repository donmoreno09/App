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

        TriangleHeading {
            heading: tir.cog
            centerItem: image
            gap: -10
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
