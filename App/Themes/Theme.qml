pragma Singleton

import QtQuick 2.15

import "tokens"
import "variants"

QtObject {
    // Testing purposes only, will be changed to dynamic theme object creation
    readonly property BaseTheme fincantieriTheme: Fincantieri { }
    readonly property BaseTheme fincantieriLightTheme: FincantieriLight { }

    property BaseTheme current: fincantieriTheme

    // Expose token families for direct access
    readonly property ColorTokens colors: current.colors
    readonly property TypographyTokens typography: current.typography
    readonly property SpacingTokens spacing: current.spacing
    readonly property RadiusTokens radius: current.radius
    readonly property BorderTokens borders: current.borders
}
