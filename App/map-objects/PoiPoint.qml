import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.SidePanel 1.0
import App.Features.MapTools 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapQuickItem {
    required property int index
    required property var model
    required property string id
    required property string label
    required property real latitude
    required property real longitude

    readonly property bool isEditing: ToolRegistry.pointTool.editable && id === ToolRegistry.pointTool.editable.id

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

            layer.enabled: isEditing
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "white"
                shadowBlur: 0.0            // 0 = sharp edge
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowScale: 1.12          // thickness of the border
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: svgIcon.bottom
            anchors.topMargin: Theme.spacing.s1
            width: text.width + Theme.spacing.s3
            height: text.height + Theme.spacing.s1
            radius: Theme.radius.sm
            color: Theme.colors.hexWithAlpha("#539E07", 0.6)
            border.color: Theme.colors.white
            border.width: isEditing ? Theme.borders.b1 : Theme.borders.b0

            Text {
                anchors.centerIn: parent
                id: text
                text: label
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.white
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }
    }

    TapHandler {
        enabled: !isEditing
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: {
            PoiModel.discardChanges()
            ToolRegistry.pointTool.editable = PoiModel.getEditablePoi(index)
            ToolRegistry.pointTool.setLatitude(latitude)
            ToolRegistry.pointTool.setLongitude(longitude)
            ToolRegistry.pointTool.mapInputted()
            ToolController.activeTool = ToolRegistry.pointTool
            SidePanelController.openOrRefresh(Routes.Poi)
        }
    }

    DragHandler {
        id: handler
        enabled: isEditing

        onTranslationChanged: {
            model.latitude = coordinate.latitude
            model.longitude = coordinate.longitude
            ToolRegistry.pointTool.setLatitude(latitude)
            ToolRegistry.pointTool.setLongitude(longitude)
            ToolRegistry.pointTool.mapInputted()
        }
    }
}
