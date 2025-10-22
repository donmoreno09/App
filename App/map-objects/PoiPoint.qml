import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.SidePanel 1.0
import App.Features.MapTools 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapQuickItem {
    required property string id
    required property string label
    required property real latitude
    required property real longitude

    coordinate: QtPositioning.coordinate(latitude, longitude)
    anchorPoint.x: svgIcon.width / 2
    anchorPoint.y: svgIcon.height / 2

    sourceItem: Item {
        width: svgIcon.width
        height: svgIcon.height

        Image {
            id: svgIcon
            width: 24
            height: 24
            source: "qrc:/App/assets/icons/poi.svg"
            smooth: true
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: svgIcon.bottom
            anchors.topMargin: 4
            width: text.width + 12
            height: text.height + 4
            radius: 4
            color: Theme.colors.hexWithAlpha("#539E07", 0.6)
            border.color: "white"
            border.width: 1

            Text {
                anchors.centerIn: parent
                id: text
                text: label
                font.pixelSize: 12
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }
    }

    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: {
            ToolRegistry.pointTool.editingId = id
            ToolRegistry.pointTool.setLatitude(latitude)
            ToolRegistry.pointTool.setLongitude(longitude)
            ToolRegistry.pointTool.mapInputted()
            ToolController.activeTool = ToolRegistry.pointTool
            SidePanelController.openOrRefresh(Routes.Poi)
        }
    }
}
