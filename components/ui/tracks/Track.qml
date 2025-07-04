import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

MapQuickItem {
    id: item

    coordinate: QtPositioning.coordinate(modelData.pos[0], modelData.pos[1])
    anchorPoint.x: 40
    anchorPoint.y: 40

    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40


        // Semiretta di orientamento COG
        Rectangle {
            id: cogLine
            width: 2
            height: 40  // lunghezza della semiretta
            color: "black"
            x: trackRect.width / 2 - width / 2  // centrata orizzontalmente
            y: trackRect.height / 2 - height    // parte dal centro verticale e si estende verso l'alto

            transform: Rotation {
                origin.x: cogLine.width / 2
                origin.y: cogLine.height       // ruota intorno al punto di origine in basso
                angle: modelData.cog
            }
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.centerIn: parent
            source: "../../../assets/icons/track/smartport/"+modelData.code.substring(0,2)+"/"+modelData.code.substring(2,4)+"/"+modelData.code.substring(4,6)+"/"+modelData.code+".svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: modelData.state === 1 ? 0.5 : 1.0
        }

        Text {
            id: trackLabel
            text: "T"+qsTr(modelData.tracknumber.toString())
            font.pixelSize: 12
            color: "black"
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
        }
    }

    Component.onCompleted: {
        mapView.addMapItem(item)
    }

    Component.onDestruction: {
        mapView.removeMapItem(item)
    }
}
