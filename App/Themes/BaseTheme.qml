/*!
    \qmltype BaseTheme
    \inqmlmodule App.Themes
    \brief Defines the contract for a theme variant by declaring all required token families.

    BaseTheme is an abstract contract object for theme variants.
    Each variant (e.g., \c {Fincantieri}) must provide instances for
    all required token families. These token families are themselves
    QtObject instances containing readonly design tokens.

    \note Token objects should be readonly and not mutated at runtime.
    Extending the theme system requires adding new required properties here.

    \sa Theme, ColorTokens, TypographyTokens
*/

import QtQuick 2.15

import "tokens"

QtObject {
    required property ColorTokens colors

    required property TypographyTokens typography

    required property SpacingTokens spacing

    required property RadiusTokens radius

    required property BorderTokens borders

    required property ElevationTokens elevation

    required property OpacityTokens opacity

    required property IconTokens icons

    required property EffectTokens effects

    required property LayoutTokens layout

    required property MotionTokens motion
}
