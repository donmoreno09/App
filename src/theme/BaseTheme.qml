/*!
    \qmltype BaseTheme
    \inqmlmodule App.Themes
    \brief Defines the contract for a theme variant by declaring all required token families.

    BaseTheme is an abstract contract object for theme variants.
    Each variant (e.g., \c {Fincantieri}) must provide instances for
    all required token families. These token families are themselves
    QtObject instances containing readonly design tokens.

    Required token families:
    \list
        \li \c {colors}         – Semantic colors and states (background, surface, text, primary, etc.)
        \li \c {typography}     – Font sizes, weights, families (body, title, caption, etc.)
        \li \c {spacing}        – Spacing scale for margins, paddings, and gaps
        \li \c {radius}         – Corner radius presets
        \li \c {borderoutline}  – Border widths, styles, focus ring colors
        \li \c {elevation}      – Shadow presets and z-index roles
        \li \c {opacity}        – Common opacity levels (opaque, muted, disabled, overlay)
        \li \c {iconography}    – Icon sizes and stroke weights
        \li \c {filtereffect}   – Predefined visual effects (blur, brightness, dimming)
    \endlist

    \note Token objects should be readonly and not mutated at runtime.
    Extending the theme system requires adding new required properties here.

    \sa Theme, ColorTokens, TypographyTokens
*/

import QtQuick 2.15

QtObject {
    required property QtObject colors

    required property QtObject typography

    required property QtObject spacing

    required property QtObject radius

    required property QtObject borderoutline

    required property QtObject elevation

    required property QtObject opacity

    required property QtObject iconography

    required property QtObject filtereffect
}
