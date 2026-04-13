import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.SidePanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapQuickItem {
    id: root

    readonly property real craneLatitude: 45.47693790805344
    readonly property real craneLongitude: 12.242793773599008

    readonly property bool isSelected: SidePanelController.router.currentPath === Routes.MOCPoiStaticPanel

    coordinate: QtPositioning.coordinate(craneLatitude, craneLongitude)
    anchorPoint.x: svgIcon.width / 2
    anchorPoint.y: svgIcon.height / 2

    sourceItem: Item {
        width: svgIcon.width
        height: svgIcon.height

        Image {
            id: svgIcon
            width: 24
            height: 24
            source: "qrc:/App/assets/icons/poi-blue.svg"
            smooth: true
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true

            layer.enabled: isSelected
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "white"
                shadowBlur: 0.0            // 0 = sharp edge
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowScale: 1.12          // thickness of the border
            }
        }

        UI.ShapeLabel {
            text: "Crane"
            textColor: Theme.colors.white
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: svgIcon.bottom
            anchors.topMargin: Theme.spacing.s1
            rect.color: Theme.colors.hexWithAlpha(Theme.colors.primary500, 1)
            rect.border.color: Theme.colors.white
            rect.border.width: isSelected ? Theme.borders.b1 : Theme.borders.b0
        }
    }

    TapHandler {
        enabled: true
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: SidePanelController.openOrRefresh(Routes.MOCPoiStaticPanel)
    }
}
