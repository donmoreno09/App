import QtQuick 6.8

import App.Themes 1.0

Palette {
    window:            Theme.colors.background
    windowText:        Theme.colors.text
    base:              Theme.colors.surface
    alternateBase:     Theme.colors.grey25
    text:              Theme.colors.text
    placeholderText:   Theme.colors.placeholder
    button:            Theme.colors.surface
    buttonText:        Theme.colors.text
    highlight:         Theme.colors.primary
    highlightedText:   Theme.colors.white
    link:              Theme.colors.accent600
    linkVisited:       Theme.colors.accent700
    brightText:        Theme.colors.white
    light:             Theme.colors.grey100
    midlight:          Theme.colors.grey200
    mid:               Theme.colors.grey300
    dark:              Theme.colors.grey400
    shadow:            Theme.colors.grey600
    toolTipBase:       Theme.colors.surface
    toolTipText:       Theme.colors.text
    accent:            Theme.colors.accent

    inactive: ColorGroup {
        link:        Theme.colors.accent500
        highlight:   Theme.colors.primary400
    }

    disabled: ColorGroup {
        text:             Theme.colors.textMuted
        windowText:       Theme.colors.textMuted
        buttonText:       Theme.colors.textMuted
        placeholderText:  Theme.colors.grey300
        base:             Theme.colors.grey25
        button:           Theme.colors.grey25
        highlight:        Theme.colors.primary100
        highlightedText:  Theme.colors.text
    }
}
