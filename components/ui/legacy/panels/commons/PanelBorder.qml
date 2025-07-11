import QtQuick
import QtQuick.Controls
import "../../../qtds" as QTDSComponents


Item {
    id: trackPanelBorder

    property var target
    anchors.fill: target
    anchors.centerIn: target

    property int topLeftInnerStrokeWidth: 2
    property int topLeftOutherStrokeWidth: 4
    property int bottomRightInnerStrokeWidth: 2
    property int bottomRightOuterStrokeWidth: 4

    property color color: "#21518b"
    property color topLeftInnerStrokeColor: "#21518b"
    property color topLeftOuterStrokeColor: "#21518b"
    property color bottomRighInnerStrokeColor: "#21518b"
    property color bottomRighOuterStrokeColor: "#21518b"


    property real topLeftOuterStrokeMarginDelta: 2
    property real bottomRightOuterStrokeMarginDelta: 2



    QTDSComponents.BorderItem {
        id: topLeftCornerInner
        width: trackPanelBorder.width * .6
        height: trackPanelBorder.height * .7
        visible: true
        anchors.left: trackPanelBorder.left
        anchors.leftMargin: -8
        anchors.top: trackPanelBorder.top
        anchors.topMargin: -8
        capStyle: 16
        joinStyle: 1
        antialiasing: true
        drawLeft: true
        drawTop: true
        strokeWidth: topLeftInnerStrokeWidth
        drawBottom: false
        drawRight: false
        strokeColor: (!trackPanelBorder.color) ? topLeftInnerStrokeColor : trackPanelBorder.color
        topLeftRadius: 14
        topLeftBevel: true
    }

    QTDSComponents.BorderItem {
        id: topLeftCornerOuter
        width: trackPanelBorder.width * .3
        height: trackPanelBorder.height * .35
        anchors.left: trackPanelBorder.left
        anchors.leftMargin: topLeftCornerInner.anchors.leftMargin - topLeftOuterStrokeMarginDelta
        anchors.top: trackPanelBorder.top
        anchors.topMargin: topLeftCornerInner.anchors.topMargin - topLeftOuterStrokeMarginDelta
        capStyle: 32
        joinStyle: 1
        antialiasing: true
        drawLeft: true
        drawTop: true
        strokeWidth: topLeftOutherStrokeWidth
        drawBottom: false
        drawRight: false
        strokeColor: (!trackPanelBorder.color) ? topLeftOuterStrokeColor : trackPanelBorder.color
        topLeftRadius: 14
        topLeftBevel: true
        radius: 0
        visible: true
    }

    QTDSComponents.BorderItem {
        id: bottomRightCornerInner
        width: trackPanelBorder.width * .6
        height: trackPanelBorder.height * .7
        visible: true
        anchors.right: trackPanelBorder.right
        anchors.rightMargin: -8
        anchors.bottom: trackPanelBorder.bottom
        anchors.bottomMargin: -8
        capStyle: 16
        joinStyle: 1
        antialiasing: true
        strokeWidth: bottomRightInnerStrokeWidth
        drawTop: false
        drawLeft: false
        strokeColor: (!trackPanelBorder.color) ? bottomRighInnerStrokeColor : trackPanelBorder.color
        bottomRightRadius: 46
        bottomRightBevel: true
    }

    QTDSComponents.BorderItem {
        id: bottomRightCornerOuter
        width: trackPanelBorder.width * .3
        height: trackPanelBorder.height * .35
        visible: true
        anchors.right: trackPanelBorder.right
        anchors.rightMargin: bottomRightCornerInner.anchors.rightMargin - bottomRightOuterStrokeMarginDelta
        anchors.bottom: trackPanelBorder.bottom
        anchors.bottomMargin: bottomRightCornerInner.anchors.bottomMargin - bottomRightOuterStrokeMarginDelta
        capStyle: 32
        joinStyle: 1
        antialiasing: true
        strokeWidth: bottomRightOuterStrokeWidth
        drawTop: false
        drawLeft: false
        strokeColor: (!trackPanelBorder.color) ? bottomRighOuterStrokeColor : trackPanelBorder.color
        bottomRightRadius: 46
        bottomRightBevel: true
    }
}
