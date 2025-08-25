import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls

import App.Themes 1.0
import App.Components 1.0
import App.Features.TitleBar 1.0
import App.Features.SideRail 1.0
import App.Features.SidePanel 1.0

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

    TitleBar {
        id: titleBar
        height: 68
        anchors.left: sideRail.right
        anchors.right: parent.right

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "white"
            border.width: 2
        }
    }

    SideRail {
        id: sideRail
        width: 80
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "blue"
            border.width: 2
        }
    }

    SidePanel {
        id: sidePanel
        width: 490
        anchors.top: titleBar.bottom
        anchors.left: sideRail.right
        anchors.bottom: parent.bottom

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "orange"
            border.width: 2
        }
    }
}
