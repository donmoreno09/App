import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls

import App.Themes 1.0
import App.Components 1.0

ApplicationWindow {
    width: 1400
    height: 800
    visible: true
    title: qsTr("IRIDESS FE")

    GlobalBackground {
        id: globalBackground
        anchors.fill: parent
        visible: false
    }

    GlobalBackgroundConsumer {
        x: 20
        y: 40
        width: 400
        height: 400
    }
}
