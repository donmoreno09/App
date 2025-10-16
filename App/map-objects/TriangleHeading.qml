import QtQuick 6.8
import QtQuick.Shapes

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    required property real heading
    required property Item centerItem

    property real gap: 1
    property real triBase: 14
    property real triHeight: 10
    property color triFill: Theme.colors.accent
    property color triStroke: Theme.colors.black
    property real triStrokeWidth: 0
    property real baseRotationDeg: 0

    readonly property real longestSize: centerItem.width > centerItem.height ? centerItem.width : centerItem.height
    readonly property real orbitRadius: longestSize/2 + gap + triHeight/2

    anchors.fill: parent
    transformOrigin: Item.Center
    rotation: baseRotationDeg + heading - (MapController.map ? MapController.map.bearing : 0)

    Item {
        width: triBase
        height: triHeight
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -orbitRadius

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: triStrokeWidth
                strokeColor: triStroke
                fillColor: triFill

                // bottom-left -> bottom-right -> apex -> close
                startX: 0;           startY: triHeight
                PathLine { x: triBase;     y: triHeight }
                PathLine { x: triBase/2;   y: 0 }
                PathLine { x: 0;           y: triHeight }
            }
        }
    }
}
