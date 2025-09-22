import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

QtObject {
    // Default, unchanging:
    readonly property color background: Theme.colors.input
    readonly property color borderColorDisabled: Theme.colors.textMuted
    readonly property color textColor: Theme.colors.text
    readonly property color textColorDisabled: Theme.colors.textMuted
    readonly property color placeholderTextColor: Theme.colors.placeholder
    readonly property color placeholderTextColorDisabled: Theme.colors.textMuted
    readonly property color iconColor: Theme.colors.accent
    readonly property color iconColorDisabled: Theme.colors.textMuted

    // Variant properties:
    required property string msgIconSource
    required property color borderColor
    required property color borderColorFocused
}
