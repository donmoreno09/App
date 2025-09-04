/*!
    \qmltype ColorTokens
    \inqmlmodule App.Themes
    \brief Defines the semantic color palette for a theme.

    ColorTokens contains all general-purpose colors used throughout the UI,
    expressed as semantic roles instead of raw hex values. This ensures
    consistent usage and makes swapping theme variants easier.

    Roles typically include:
    \list
        \li Surfaces: \c {background}, \c {surface}, \c {overlay}
        \li Text: \c {text}, \c {textMuted}
        \li Brand/Primary: \c {primary}, \c {primaryHover}, \c {primaryPressed}, \c {onPrimary}
        \li Status roles: \c {success}, \c {warning}, \c {danger}, \c {info}
    \endlist

    Variants of \l {BaseTheme} (e.g., \c {Fincantieri}) must instantiate
    this object and assign it to \c {BaseTheme.colors}.

    \note All properties should be \c {readonly} and immutable at runtime.
    \sa BaseTheme, TypographyTokens, SpacingTokens
*/

import QtQuick 2.15

QtObject {
    // Surfaces
    readonly property color background: "#0F1115" // App base layer; behind all content
    readonly property color surface: "#171A21"    // Elevated containers (cards, panels, sheets)
    readonly property color overlay: "#202630"    // Transparent/dim layer above background/surface
    readonly property color transparent: "transparent"

    // Text
    readonly property color text: "#E8EAED"
    readonly property color textMuted: "#A3A9B5"

    // Borders
    readonly property color border: "#232C36"

    // Primary role
    readonly property color primary: "#0A4C8B"
    readonly property color primaryHover: "#0C5BA6"
    readonly property color primaryPressed: "#09406F"
    readonly property color primaryText: "white" // "onPrimary" naming cannot work since Qt thinks it's a signal

    // Status colors
    readonly property color success: "#3BA55C"
    readonly property color warning: "#F9A62B"
    readonly property color danger: "#D83A3A"
    readonly property color info: "#4AA3E0"
}
