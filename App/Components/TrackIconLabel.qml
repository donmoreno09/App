import QtQuick 6.8

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    required property string text

    function _clamp(value, min, max) {
        return Math.max(min, Math.min(max, value))
    }

    function _norm(value, min, max) {
        if (max === min)
            return 0
        return (value - min) / (max - min)
    }

    readonly property real _labelHideZoom: 8
    readonly property real _zoomLevel: MapController.map ? MapController.map.zoomLevel : 8
    readonly property real _transitionFactor: _clamp(_norm(_zoomLevel, _labelHideZoom, _labelHideZoom + 1), 0, 1)

    implicitWidth: container.visible ? container.width : 0
    implicitHeight: container.visible ? container.height : 0
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.visible && root.text !== "" && _zoomLevel > _labelHideZoom
        scale: 0.85 + (_transitionFactor * 0.15) // from 0.85 -> 1.0
        color: Theme.colors.transparent

        width: Math.min(Theme.spacing.s16, Math.max(root.width, textComponent.implicitWidth + 8))
        height: textComponent.implicitHeight + 4

        Text {
            id: textComponent

            anchors.fill: parent
            anchors.margins: 4

            text: root.text
            font.pixelSize: Theme.typography.fontSize150
            color: MapController._currentPlugin.isDark ? Theme.colors.white : Theme.colors.black
            style: Text.Outline
            styleColor:MapController._currentPlugin.isDark ? Theme.colors.black : Theme.colors.white

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            maximumLineCount: 1
            elide: Text.ElideRight
        }
    }
}
