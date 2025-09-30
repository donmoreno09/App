pragma Singleton

import QtQuick 6.8
import App.Themes 1.0

QtObject {
    enum Variant {
        Primary,
        Secondary,
        Danger,
        Ghost,
        Success,
        Warning
    }

    readonly property var defaultSizeConfig: ({
        "sm": {
            minHeight: Theme.spacing.s8,
            padding: Theme.spacing.s2,
            fontSize: Theme.typography.fontSize150
        },
        "md": {
            minHeight: Theme.spacing.s10,
            padding: Theme.spacing.s3,
            fontSize: Theme.typography.fontSize175
        },
        "lg": {
            minHeight: Theme.spacing.s12,
            padding: Theme.spacing.s4,
            fontSize: Theme.typography.fontSize200
        }
    })

    property ButtonStyle _primary: ButtonStyle {
        background: Theme.colors.primary500
        backgroundHover: Theme.colors.primary600
        backgroundPressed: Theme.colors.primary700
        backgroundDisabled: Theme.colors.greyA20
        backgroundActive: Theme.colors.primary600
        border: Theme.borders.b0
        borderColor: Theme.colors.primary500
        textColor: Theme.colors.white500
        textColorDisabled: Theme.colors.whiteA60
        sizeConfig: defaultSizeConfig
    }

    property ButtonStyle _secondary: ButtonStyle {
        background: Theme.colors.secondary100
        backgroundHover: Theme.colors.secondary200
        backgroundPressed: Theme.colors.secondary300
        backgroundDisabled: Theme.colors.greyA20
        backgroundActive: Theme.colors.secondary200
        border: Theme.borders.b1
        borderColor: Theme.colors.grey400
        borderColorDisabled: Theme.colors.grey300
        textColor: Theme.colors.secondary700
        textColorDisabled: Theme.colors.grey400
        sizeConfig: defaultSizeConfig
    }

    property ButtonStyle _danger: ButtonStyle {
        background: Theme.colors.error500
        backgroundHover: Theme.colors.error600
        backgroundPressed: Theme.colors.error700
        backgroundDisabled: Theme.colors.greyA20
        backgroundActive: Theme.colors.error600
        border: Theme.borders.b0
        borderColor: Theme.colors.error500
        textColor: Theme.colors.white500
        textColorDisabled: Theme.colors.whiteA60
        sizeConfig: defaultSizeConfig
    }

    property ButtonStyle _ghost: ButtonStyle {
        background: Theme.colors.transparent
        backgroundHover: Theme.colors.greyA20
        backgroundPressed: Theme.colors.greyA30
        backgroundDisabled: Theme.colors.greyA5
        backgroundActive: Theme.colors.greyA20
        border: Theme.borders.b1
        borderColor: Theme.colors.grey300
        textColor: Theme.colors.grey700
        textColorDisabled: Theme.colors.grey400
        sizeConfig: defaultSizeConfig
    }

    property ButtonStyle _success: ButtonStyle {
        background: Theme.colors.success500
        backgroundHover: Theme.colors.success600
        backgroundPressed: Theme.colors.success700
        backgroundDisabled: Theme.colors.greyA20
        backgroundActive: Theme.colors.success600
        border: Theme.borders.b0
        borderColor: Theme.colors.success500
        textColor: Theme.colors.white500
        textColorDisabled: Theme.colors.whiteA60
        sizeConfig: defaultSizeConfig
    }

    property ButtonStyle _warning: ButtonStyle {
        background: Theme.colors.warning500
        backgroundHover: Theme.colors.warning600
        backgroundPressed: Theme.colors.warning700
        backgroundDisabled: Theme.colors.greyA20
        backgroundActive: Theme.colors.warning600
        border: Theme.borders.b0
        borderColor: Theme.colors.warning500
        textColor: Theme.colors.white500
        textColorDisabled: Theme.colors.whiteA60
        sizeConfig: defaultSizeConfig
    }

    function fromVariant(variant) : ButtonStyle {
        switch (variant) {
        case ButtonStyles.Primary: return _primary
        case ButtonStyles.Secondary: return _secondary
        case ButtonStyles.Danger: return _danger
        case ButtonStyles.Ghost: return _ghost
        case ButtonStyles.Success: return _success
        case ButtonStyles.Warning: return _warning
        default: {
            console.warn("Invalid ButtonStyle variant:", variant)
            return _primary
        }
        }
    }

    function getCurrentState(enabled, pressed, hovered, focused, active) {
        if (!enabled) return "disabled"
        if (pressed) return "pressed"
        if (hovered) return "hovered"
        if (focused) return "focused"
        if (active) return "active"
        return "normal"
    }

    function getBackgroundForState(style, state) {
        switch (state) {
        case "disabled": return style.backgroundDisabled
        case "pressed": return style.backgroundPressed
        case "hovered": return style.backgroundHover
        case "active": return style.backgroundActive
        default: return style.background
        }
    }

    function getBorderColorForState(style, state) {
        if (state === "disabled" && style.borderColorDisabled !== style.borderColor) {
            return style.borderColorDisabled
        }
        return style.borderColor
    }

    function getTextColorForState(style, enabled) {
        return enabled ? style.textColor : style.textColorDisabled
    }
}
