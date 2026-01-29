import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Item {
    id: root

    required property color color
    required property color iconColor
    required property var iconSource
    required property double heading

    property alias headingArrow: headingArrow

    property string labelText: ""

    signal tapped()

    width: 26
    height: 26
    opacity: root.state === 'STALE' ? 0.5 : 1.0

    TriangleHeading {
        id: headingArrow
        heading: root.heading
        centerItem: marker
        triFill: root.color
    }

    Rectangle {
        id: marker
        anchors.fill: parent
        anchors.centerIn: parent
        radius: Theme.radius.circle(width, height)
        color: root.color
        border.color: root.iconColor
        border.width: 1

        ToolButton {
            background: null
            icon.source: root.iconSource
            icon.color: root.iconColor
            icon.width: parent.width * 0.6
            icon.height: parent.height * 0.6
            icon.cache: true
            anchors.centerIn: parent
            onClicked: root.tapped()
        }
    }

    Text {
        id: trackLabel
        visible: root.labelText !== ""
        text: root.labelText
        font.pixelSize: 12
        color: "black"
        anchors.left: parent.right
        anchors.leftMargin: parent.width / 4
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.Wrap
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.tapped()
    }
}
