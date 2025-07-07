import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

MapQuickItem {
    id: trackMapItem

    signal requestPanel(var trackData, var marker)
    signal testSignal()

    coordinate: QtPositioning.coordinate(modelData.pos[0], modelData.pos[1])
    anchorPoint.x: 40
    anchorPoint.y: 40

    property point panelAnchor: Qt.point(0, 0)

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

        TapHandler {
            id: tapHandler
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onTapped: {
                console.log("[TrackPanel] TapHandler tapped on track!")
                trackMapItem.requestPanel(modelData, trackMapItem)
                trackMapItem.testSignal()
                console.log("[TrackPanel] post")

            }
        }
    }

    Component.onCompleted: {
        console.log("[Track.qml] istanziato, tracknumber: " + modelData.tracknumber)
        mapView.addMapItem(trackMapItem)
    }

    Component.onDestruction: {
        console.log("[Track.qml] distrutto")
        mapView.removeMapItem(trackMapItem)
    }
}
