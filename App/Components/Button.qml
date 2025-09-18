/*!
    \qmltype Button
    \inqmlmodule DesignSystem
    \brief Base button component with variant support and theme integration.

    The Button component provides a foundation for all button-like controls in the design system.
    It supports visual variants (primary, secondary, danger, etc.) and delegates content layout
    to its children, making it highly flexible and composable.

    Key features:
    - Variant-based styling using design tokens
    - Full state management (hover, focus, pressed, disabled)
    - Content-agnostic design (supports any children)
    - Accessibility support with keyboard navigation
    - Theme integration with automatic state transitions
*/

import QtQuick 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

Button {
    id: root

    property alias backgroundRect: backgroundRect
    property bool active: false

    property string variant: "primary"
    property string size: "md"
    property int radius: Theme.radius.md

    readonly property bool focused: visualFocus && enabled

    readonly property string currentState: {
        if (!enabled) return "disabled"
        if (pressed) return "pressed"
        if (hovered) return "hovered"
        if (focused) return "focused"
        if (active) return "active"
        return "normal"
    }

    readonly property var _sizeVariants: ({
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

    readonly property var _sizeStyles: _sizeVariants[size] || _sizeVariants["md"]

    readonly property var _variantStyles: ({
        "primary": {
            background: Theme.colors.primary500,
            backgroundHover: Theme.colors.primary600,
            backgroundPressed: Theme.colors.primary700,
            backgroundDisabled: Theme.colors.greyA20,
            backgroundActive: Theme.colors.primary600,
            border: Theme.borders.b0,
            borderColor: Theme.colors.primary500,
            textColor: Theme.colors.white500,
            textColorDisabled: Theme.colors.whiteA60
        },
        "secondary": {
            background: Theme.colors.secondary100,
            backgroundHover: Theme.colors.secondary200,
            backgroundPressed: Theme.colors.secondary300,
            backgroundDisabled: Theme.colors.greyA20,
            backgroundActive: Theme.colors.secondary200,
            border: Theme.borders.b1,
            borderColor: Theme.colors.grey400,
            borderColorDisabled: Theme.colors.grey300,
            textColor: Theme.colors.secondary700,
            textColorDisabled: Theme.colors.grey400
        },
        "danger": {
            background: Theme.colors.error500,
            backgroundHover: Theme.colors.error600,
            backgroundPressed: Theme.colors.error700,
            backgroundDisabled: Theme.colors.greyA20,
            backgroundActive: Theme.colors.error600,
            border: Theme.borders.b0,
            borderColor: Theme.colors.error500,
            textColor: Theme.colors.white500,
            textColorDisabled: Theme.colors.whiteA60
        },
        "ghost": {
            background: Theme.colors.transparent,
            backgroundHover: Theme.colors.greyA20,
            backgroundPressed: Theme.colors.greyA30,
            backgroundDisabled: Theme.colors.greyA5,
            backgroundActive: Theme.colors.greyA20,
            border: Theme.borders.b0,
            borderColor: Theme.colors.grey300,
            textColor: Theme.colors.grey700,
            textColorDisabled: Theme.colors.grey400
        },
        "success": {
            background: Theme.colors.success500,
            backgroundHover: Theme.colors.success600,
            backgroundPressed: Theme.colors.success700,
            backgroundDisabled: Theme.colors.greyA20,
            backgroundActive: Theme.colors.success600,
            border: Theme.borders.b0,
            borderColor: Theme.colors.success500,
            textColor: Theme.colors.white500,
            textColorDisabled: Theme.colors.whiteA60
        },
        "warning": {
            background: Theme.colors.warning500,
            backgroundHover: Theme.colors.warning600,
            backgroundPressed: Theme.colors.warning700,
            backgroundDisabled: Theme.colors.greyA20,
            backgroundActive: Theme.colors.warning600,
            border: Theme.borders.b0,
            borderColor: Theme.colors.warning500,
            textColor: Theme.colors.white500,
            textColorDisabled: Theme.colors.whiteA60
        },
    })

    readonly property var _currentVariantStyle: _variantStyles[variant] || _variantStyles["primary"]

    readonly property color _currentBackground: {
        switch (currentState) {
            case "disabled": return _currentVariantStyle.backgroundDisabled
            case "pressed": return _currentVariantStyle.backgroundPressed
            case "hovered": return _currentVariantStyle.backgroundHover
            case "active": return _currentVariantStyle.backgroundActive
            default: return _currentVariantStyle.background
        }
    }

    readonly property color _currentBorderColor: {
        if (currentState === "disabled" && _currentVariantStyle.borderColorDisabled) {
            return _currentVariantStyle.borderColorDisabled
        }
        return _currentVariantStyle.borderColor
    }

    flat: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        id: backgroundRect
        color: _currentBackground
        radius: root.radius
        border.width: _currentVariantStyle.border
        border.color: _currentBorderColor

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        OutlineRect { visible: focused }
    }

    padding: _sizeStyles.padding
}
