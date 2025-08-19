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

    Example usage:
    \code
    Button {
        variant: "primary"
        Text {
            text: "Submit"
            color: Theme.colors.primaryText
            anchors.centerIn: parent
        }
    }

    Button {
        variant: "ghost"
        Row {
            anchors.centerIn: parent
            spacing: Theme.spacing.s2
            Image {
                source: "qrc:/icons/settings.svg"
                width: Theme.icons.sizeSm
                height: Theme.icons.sizeSm
            }
            Text {
                text: "Settings"
                color: Theme.colors.text
            }
        }
    }
    \endcode

    \sa IconButton, MapToolButton, NavRailItem
*/

import QtQuick 2.15
import App.Themes 1.0

Item {
    id: root

    // Public API
    property string variant: "primary"
    property string size: "md"
    property bool disabled: false

    // Read-only state properties
    readonly property bool hovered: mouseArea.containsMouse && !disabled
    readonly property bool pressed: mouseArea.pressed && !disabled
    readonly property bool focused: focusScope.activeFocus && !disabled

    // Computed current state for easier state management
    readonly property string currentState: {
        if (disabled) return "disabled"
        if (pressed) return "pressed"
        if (hovered) return "hovered"
        if (focused) return "focused"
        return "normal"
    }

    // Signals
    signal clicked()
    signal pressAndHold()

    // Size using clean approach - no binding loops
    implicitWidth: Math.max(background.implicitWidth, _sizeStyles.minWidth)
    implicitHeight: Math.max(background.implicitHeight, _sizeStyles.height)

    // REMOVED: These lines were causing binding loops
    // width: implicitWidth
    // height: implicitHeight

    // Size configuration
    readonly property var _sizeVariants: ({
        "sm": {
            minWidth: 64,
            height: 32,
            padding: Theme.spacing.s2,
            fontSize: Theme.typography.sizeSm
        },
        "md": {
            minWidth: 80,
            height: 40,
            padding: Theme.spacing.s3,
            fontSize: Theme.typography.sizeBase
        },
        "lg": {
            minWidth: 96,
            height: 48,
            padding: Theme.spacing.s4,
            fontSize: Theme.typography.sizeLg
        }
    })

    readonly property var _sizeStyles: _sizeVariants[size] || _sizeVariants["md"]

    // Variant style definitions
    readonly property var _variantStyles: ({
        "primary": {
            background: Theme.colors.primary,
            backgroundHover: Theme.colors.primaryHover,
            backgroundPressed: Theme.colors.primaryPressed,
            backgroundDisabled: Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, Theme.opacity.o50),
            border: Theme.borders.b0,
            borderColor: "transparent",
            textColor: Theme.colors.primaryText,
            textColorDisabled: Qt.rgba(Theme.colors.primaryText.r, Theme.colors.primaryText.g, Theme.colors.primaryText.b, Theme.opacity.o50)
        },
        "secondary": {
            background: Theme.colors.surface,
            backgroundHover: Theme.colors.overlay,
            backgroundPressed: Theme.colors.background,
            backgroundDisabled: Qt.rgba(Theme.colors.surface.r, Theme.colors.surface.g, Theme.colors.surface.b, Theme.opacity.o50),
            border: Theme.borders.b1,
            borderColor: Theme.colors.textMuted,
            borderColorDisabled: Qt.rgba(Theme.colors.textMuted.r, Theme.colors.textMuted.g, Theme.colors.textMuted.b, Theme.opacity.o30),
            textColor: Theme.colors.text,
            textColorDisabled: Theme.colors.textMuted
        },
        "danger": {
            background: Theme.colors.danger,
            backgroundHover: Qt.darker(Theme.colors.danger, 1.1),
            backgroundPressed: Qt.darker(Theme.colors.danger, 1.2),
            backgroundDisabled: Qt.rgba(Theme.colors.danger.r, Theme.colors.danger.g, Theme.colors.danger.b, Theme.opacity.o50),
            border: Theme.borders.b0,
            borderColor: "transparent",
            textColor: "white",
            textColorDisabled: Qt.rgba(1, 1, 1, Theme.opacity.o50)
        },
        "ghost": {
            background: "transparent",
            backgroundHover: Qt.rgba(Theme.colors.overlay.r, Theme.colors.overlay.g, Theme.colors.overlay.b, Theme.opacity.o20),
            backgroundPressed: Qt.rgba(Theme.colors.surface.r, Theme.colors.surface.g, Theme.colors.surface.b, Theme.opacity.o50),
            backgroundDisabled: "transparent",
            border: Theme.borders.b0,
            borderColor: "transparent",
            textColor: Theme.colors.text,
            textColorDisabled: Theme.colors.textMuted
        },
        "success": {
            background: Theme.colors.success,
            backgroundHover: Qt.darker(Theme.colors.success, 1.1),
            backgroundPressed: Qt.darker(Theme.colors.success, 1.2),
            backgroundDisabled: Qt.rgba(Theme.colors.success.r, Theme.colors.success.g, Theme.colors.success.b, Theme.opacity.o50),
            border: Theme.borders.b0,
            borderColor: "transparent",
            textColor: "white",
            textColorDisabled: Qt.rgba(1, 1, 1, Theme.opacity.o50)
        }
    })

    readonly property var _currentVariantStyle: _variantStyles[variant] || _variantStyles["primary"]

    // Helper functions for state-based styling
    function _getBackgroundColor(state) {
        switch (state) {
            case "disabled": return _currentVariantStyle.backgroundDisabled
            case "pressed": return _currentVariantStyle.backgroundPressed
            case "hovered": return _currentVariantStyle.backgroundHover
            default: return _currentVariantStyle.background
        }
    }

    function _getBorderColor(state) {
        if (state === "disabled" && _currentVariantStyle.borderColorDisabled) {
            return _currentVariantStyle.borderColorDisabled
        }
        return _currentVariantStyle.borderColor
    }

    function _getBorderWidth() {
        return _currentVariantStyle.border
    }

    // Public methods
    function forceActiveFocus() {
        focusScope.forceActiveFocus()
    }

    // Focus scope for keyboard navigation
    FocusScope {
        id: focusScope
        anchors.fill: parent

        Keys.onSpacePressed: {
            if (!disabled) {
                clicked()
            }
        }

        Keys.onReturnPressed: {
            if (!disabled) {
                clicked()
            }
        }
    }

    // Background rectangle with clean implicit sizing
    Rectangle {
        id: background
        anchors.fill: parent

        // Clean implicit size - no binding to content
        implicitWidth: _sizeStyles.minWidth
        implicitHeight: _sizeStyles.height

        color: _getBackgroundColor(root.currentState)
        radius: Theme.radius.md
        border.width: _getBorderWidth()
        border.color: _getBorderColor(root.currentState)

        opacity: root.currentState === "disabled" ? (Theme.opacity.o50 || 0.5) : 1.0

        // Smooth state transitions
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    // Focus indicator - separate ring outside the button
    Rectangle {
        id: focusIndicator
        anchors.fill: parent
        anchors.margins: -Theme.borders.offset2

        color: "transparent"
        radius: Theme.radius.md + Theme.borders.outline2
        border.width: focused ? Theme.borders.outline2 : 0
        border.color: Theme.colors.primary

        visible: focused

        Behavior on border.width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    // Content container - clean approach with no binding loops
    Item {
        id: contentContainer
        anchors {
            fill: parent
            margins: _sizeStyles.padding
        }

        // Remove implicit size bindings to avoid loops
        // The container will size based on its anchors and content will flow naturally
    }

    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent

        enabled: !disabled
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            focusScope.forceActiveFocus()
            root.clicked()
        }

        onPressAndHold: {
            root.pressAndHold()
        }
    }

    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: {
        // Try to find text in children for accessibility
        for (let i = 0; i < children.length; i++) {
            if (children[i].text !== undefined) {
                return children[i].text
            }
        }
        return "Button"
    }
    Accessible.description: `${variant} button`
    Accessible.onPressAction: {
        if (!disabled) {
            clicked()
        }
    }

    // Reparent children to content container for proper layout
    onChildrenChanged: {
        for (let i = 0; i < children.length; i++) {
            const child = children[i]
            // Skip internal elements
            if (child !== background && child !== focusIndicator &&
                child !== contentContainer && child !== mouseArea && child !== focusScope) {
                child.parent = contentContainer
            }
        }
    }

    // Validation and warnings
    Component.onCompleted: {
        if (!_variantStyles.hasOwnProperty(variant)) {
            console.warn(`Button: Unknown variant '${variant}'. Available variants: ${Object.keys(_variantStyles).join(', ')}`)
        }
        if (!_sizeVariants.hasOwnProperty(size)) {
            console.warn(`Button: Unknown size '${size}'. Available sizes: ${Object.keys(_sizeVariants).join(', ')}`)
        }
    }
}
