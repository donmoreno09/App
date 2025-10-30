import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.TrackPanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes


MapQuickItem {
    id: tir

    required property string operationCode
    required property geoCoordinate pos
    required property double cog
    required property string state

    // Index Data
    required property int index
    required property TirModel tirModel

    coordinate: tir.pos
    anchorPoint.x: sourceItem.width / 2
    anchorPoint.y: sourceItem.height / 2

    sourceItem: Item {
        id: tirRect
        width: 40
        height: 40
        opacity: tir.state === 'STALE' ? 0.5 : 1.0

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
            opacity: tir.state === 'STALE' ? 0.5 : 1.0
        }

        Text {
            id: tirLabel
            text: tir.operationCode
            font.pixelSize: 12
            color: "black"
            anchors.left: parent.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
        }

        TapHandler {
            id: tapHandler
            acceptedButtons: Qt.LeftButton
            onTapped: (event) => {
                SidePanelController.openOrRefresh(Routes.TirPanel)
                SelectedTrackState.select(tir.tirModel.getEditableTir(tir.index))
            }
        }
    }
}
