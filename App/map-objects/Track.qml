import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.TrackPanel 1.0


MapQuickItem {
    id: track

    required property string code
    required property geoCoordinate pos
    required property double cog
    required property string state
    required property int trackNumber

    // Index Data
    required property int index
    required property TrackModel trackModel


    coordinate: track.pos
    anchorPoint.x: sourceItem.width / 2
    anchorPoint.y: sourceItem.height / 2

    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40
        opacity: track.state === 'STALE' ? 0.5 : 1.0

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
            opacity: track.state === 'STALE' ? 0.5 : 1.0
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

        TapHandler {
            id: tapHandler
            acceptedButtons: Qt.LeftButton
            onTapped: (event) => {
                SidePanelController.openOrRefresh("trackpanel")
                SelectedTrackState.select(track.trackModel.getEditableTrack(track.index))
            }
        }
    }
}
