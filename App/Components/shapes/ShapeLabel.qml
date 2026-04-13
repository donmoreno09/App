import QtQuick 6.8

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    required property string text
    required property string textColor

    readonly property real _labelHideZoom: 8
    readonly property real _zoomLevel: MapController.map ? MapController.map.zoomLevel : 8
    property alias rect: container

    implicitWidth: container.visible ? container.width : 0
    implicitHeight: container.visible ? container.height : 0
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: container

        visible: root.visible && root.text !== "" && _zoomLevel > _labelHideZoom
        width: textComponent.width + Theme.spacing.s3
        height: textComponent.height + Theme.spacing.s1
        radius: Theme.radius.sm

        Text {
            id: textComponent
            anchors.centerIn: parent
            text: root.text
            color: root.textColor
            font.pixelSize: Theme.typography.fontSize150
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }
}
