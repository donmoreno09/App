import QtQuick 6.8
import App.Themes 1.0

QtObject {
    required property color background
    required property color backgroundHover
    required property color backgroundPressed
    required property color backgroundDisabled
    required property color backgroundActive

    required property int border
    required property color borderColor
    property color borderColorDisabled: borderColor  // Optional override

    required property color textColor
    required property color textColorDisabled

    required property var sizeConfig
}
