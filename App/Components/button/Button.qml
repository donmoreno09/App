import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Components 1.0 as UI
import App.Themes 1.0

Button {
    id: root

    property int variant: ButtonStyles.Primary
    property string size: "md"
    property int radius: Theme.radius.md
    property bool active: false

    property alias backgroundRect: backgroundRect

    property ButtonStyle _style: ButtonStyles.fromVariant(variant)

    readonly property var _currentSize: _style.sizeConfig[size] || _style.sizeConfig["md"]

    readonly property bool focused: visualFocus && enabled

    readonly property string currentState: ButtonStyles.getCurrentState(
        enabled, pressed, hovered, focused, active
    )

    readonly property color _currentBackground: ButtonStyles.getBackgroundForState(_style, currentState)
    readonly property color _currentBorderColor: ButtonStyles.getBorderColorForState(_style, currentState)
    readonly property color _currentTextColor: ButtonStyles.getTextColorForState(_style, enabled)

    flat: true
    focusPolicy: Qt.StrongFocus
    padding: _currentSize.padding

    background: Rectangle {
        id: backgroundRect
        implicitHeight: _currentSize.minHeight
        color: _currentBackground
        radius: root.radius
        border.width: _style.border
        border.color: _currentBorderColor

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Behavior on border.color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        UI.OutlineRect {
            visible: focused
            parentRadius: root.radius
        }
    }
}
