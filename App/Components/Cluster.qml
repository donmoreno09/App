import QtQuick 6.8

import App.Themes 1.0

Item {
    id: root

    property int  clusterNumber: 0
    property bool selected:     false
    property bool enabled:      true

    // NOTE: Adhoc for now.
    property bool isDark:       false

    signal clicked()

    readonly property int _circleSize: Theme.spacing.s8

    implicitWidth:  _circleSize
    implicitHeight: _circleSize

    readonly property string _state: {
        if (!root.enabled)  return "disabled"
        if (root.selected)  return "selected"
        if (_hovered)       return "hovered"
        return "default"
    }

    property bool _hovered: false

    readonly property color _circleFill: {
        switch (_state) {
        case "disabled": return root.isDark ? Theme.colors.whiteA30 : Theme.colors.blackA30
        case "hovered":  return root.isDark ? Theme.colors.grey25   : Theme.colors.secondary500
        case "selected": return root.isDark ? Theme.colors.grey50   : Theme.colors.secondary450
        default:         return root.isDark ? Theme.colors.white    : Theme.colors.secondary400
        }
    }

    readonly property color _textColor: {
        switch (_state) {
        case "disabled": return root.isDark ? Theme.colors.whiteA30 : Theme.colors.blackA30
        default:         return root.isDark ? Theme.colors.black500 : Theme.colors.white500
        }
    }

    Rectangle {
        id: circle

        width:  root._circleSize
        height: root._circleSize
        radius: width / 2

        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        color: root._circleFill

        Behavior on color        { ColorAnimation { duration: Theme.motion.interactiveMs; easing.type: Theme.motion.panelTransitionEasing } }
        Behavior on border.color { ColorAnimation { duration: Theme.motion.interactiveMs; easing.type: Theme.motion.panelTransitionEasing } }

        Text {
            anchors.centerIn: parent
            text:             root.clusterNumber
            color:            root._textColor
            font.family:      Theme.typography.familySans
            font.pixelSize:   Theme.typography.fontSize150
            font.weight:      Theme.typography.weightMedium

            Behavior on color { ColorAnimation { duration: Theme.motion.interactiveMs; easing.type: Theme.motion.panelTransitionEasing } }
        }
    }

    // Unused for now.
    // HoverHandler {
    //     enabled:          root.enabled
    //     cursorShape:      Qt.PointingHandCursor
    //     onHoveredChanged: root._hovered = root.enabled && hovered
    // }

    // TapHandler {
    //     enabled:         root.enabled
    //     acceptedButtons: Qt.LeftButton
    //     gesturePolicy:   TapHandler.ReleaseWithinBounds
    //     onTapped:        root.clicked()
    // }
}
