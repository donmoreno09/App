import QtQuick 2.15

import ".."
import "../tokens"

BaseTheme {
    colors: ColorTokens {
        // Surfaces
        readonly property color background: "#FFFFFF" // Pure white base layer
        readonly property color surface: "#F5F5F5"    // Slightly elevated container
        readonly property color overlay: "#EAEAEA"    // Subtle dim/overlay layer

        // Text
        readonly property color text: "#202124"       // Dark gray for primary text
        readonly property color textMuted: "#5F6368"  // Medium gray for muted text

        // Primary role
        readonly property color primary: "#0A4C8B"       // Keep brand hue
        readonly property color primaryHover: "#0C5BA6"  // Slightly brighter for hover
        readonly property color primaryPressed: "#09406F"
        readonly property color primaryText: "white"     // White text on primary

        // Status colors
        readonly property color success: "#2E7D32"  // Deeper green for light bg contrast
        readonly property color warning: "#ED6C02"  // Rich amber
        readonly property color danger: "#D32F2F"   // Strong red
        readonly property color info: "#0288D1"     // Bright blue
    }

    typography: TypographyTokens { }

    spacing: SpacingTokens { }

    radius: RadiusTokens { }

    borders: BorderTokens { }

    elevation: ElevationTokens { }

    opacity: OpacityTokens { }

    icons: IconTokens { }

    effects: EffectTokens { }

    layout: LayoutTokens { }
}
