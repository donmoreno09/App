import QtQuick 6.8
import QtQuick.Effects 6.8

import App.Themes 1.0

Item {
    id: root

    required property string source
    required property real radius

    Image {
        id: avatar
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: roundMask
        anchors.fill: parent
        radius: root.radius
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: avatar
        maskEnabled: true
        maskSource: ShaderEffectSource {
            sourceItem: roundMask
            hideSource: true
        }
    }
}
