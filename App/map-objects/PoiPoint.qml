import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.MapModes 1.0

MapQuickItem {
    id: root
    z: Theme.elevation.z100 + (isEditing) ? 100 : 0

    readonly property bool isEditing: MapModeController.poi && id === MapModeController.poi.id

    coordinate: model.coordinate
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
        enabled: !isEditing && !MapModeController.isCreating
        gesturePolicy: TapHandler.ReleaseWithinBounds
        acceptedButtons: Qt.LeftButton
        onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))
    }

    DragHandler {
        id: handler
        enabled: isEditing

        onTranslationChanged: {
            model.coordinate = coordinate
            MapModeRegistry.editPointMode.coordChanged()
        }
    }
}
