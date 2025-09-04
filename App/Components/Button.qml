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
    property int focusOutlineWidth: Theme.borders.outline2
    property int focusOffset: Theme.borders.offset2
    property color focusColor: Theme.colors.primary

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
            fontSize: Theme.typography.sizeSm
        },
        "md": {
            minHeight: Theme.spacing.s10,
            padding: Theme.spacing.s3,
            fontSize: Theme.typography.sizeBase
        },
        "lg": {
            minHeight: Theme.spacing.s12,
            padding: Theme.spacing.s4,
            fontSize: Theme.typography.sizeLg
        }
    })

    readonly property var _sizeStyles: _sizeVariants[size] || _sizeVariants["md"]

    readonly property var _variantStyles: ({
        "primary": {
            background: Theme.colors.primary,
            backgroundHover: Qt.darker(Theme.colors.primary, 1.2),
            backgroundPressed: Qt.darker(Theme.colors.primary, 1.4),
            backgroundDisabled: Theme.colors.textMuted,
            backgroundActive: Qt.darker(Theme.colors.primary, 1.1),
            border: Theme.borders.b0,
            borderColor: Theme.colors.primary,
            textColor: Theme.colors.primaryText,
            textColorDisabled: Theme.colors.primaryText
        },
        "secondary": {
            background: Theme.colors.surface,
            backgroundHover: Theme.colors.overlay,
            backgroundPressed: Theme.colors.background,
            backgroundDisabled: Theme.colors.textMuted,
            backgroundActive: Theme.colors.overlay,
            border: Theme.borders.b1,
            borderColor: Theme.colors.textMuted,
            borderColorDisabled: Theme.colors.textMuted,
            textColor: Theme.colors.text,
            textColorDisabled: Theme.colors.textMuted
        },
        "danger": {
            background: Theme.colors.danger,
            backgroundHover: Qt.darker(Theme.colors.danger, 1.1),
            backgroundPressed: Qt.darker(Theme.colors.danger, 1.2),
            backgroundDisabled: Theme.colors.textMuted,
            backgroundActive: Qt.darker(Theme.colors.danger, 1.1),
            border: Theme.borders.b0,
            borderColor: Theme.colors.danger,
            textColor: Theme.colors.primaryText,
            textColorDisabled: Theme.colors.primaryText
        },
        "ghost": {
            background: Theme.colors.transparent,
            backgroundHover: Theme.colors.overlay,
            backgroundPressed: Theme.colors.surface,
            backgroundDisabled: Theme.colors.overlay,
            backgroundActive: Theme.colors.overlay,
            border: Theme.borders.b1,
            borderColor: Theme.colors.textMuted,
            textColor: Theme.colors.text,
            textColorDisabled: Theme.colors.textMuted
        },
        "success": {
            background: Theme.colors.success,
            backgroundHover: Qt.darker(Theme.colors.success, 1.1),
            backgroundPressed: Qt.darker(Theme.colors.success, 1.2),
            backgroundDisabled: Theme.colors.textMuted,
            backgroundActive: Qt.darker(Theme.colors.success, 1.1),
            border: Theme.borders.b0,
            borderColor: Theme.colors.success,
            textColor: Theme.colors.primaryText,
            textColorDisabled: Theme.colors.primaryText
        }
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

        Rectangle {
            anchors.fill: parent
            anchors.margins: -root.focusOffset
            color: _currentBackground
            radius: root.radius + root.focusOutlineWidth
            border.width: focused ? root.focusOutlineWidth : 0
            border.color: Qt.lighter(_currentVariantStyle.borderColor, 1.6)
            visible: focused

            Behavior on border.width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
    }

    padding: _sizeStyles.padding
    topPadding: _sizeStyles.padding
    leftPadding: _sizeStyles.padding
    rightPadding: _sizeStyles.padding
    bottomPadding: _sizeStyles.padding
}
