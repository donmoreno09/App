import QtQuick 2.15

import ".."
import "../tokens"

BaseTheme {
    colors: ColorTokens {
        // Surfaces
        readonly property color background: primary900 // App base layer; behind all content
        readonly property color surface: primary800    // Elevated containers (cards, panels, sheets)
        readonly property color overlay: grey500       // Transparent/dim layer above background/surface
        readonly property color glass: blackA10
        readonly property color glassWhite: whiteA10

        // Semantics
        readonly property color input: whiteA5
        readonly property color placeholder: whiteA60

        // Text
        readonly property color text: white500
        readonly property color textMuted: whiteA60

        // Accent
        readonly property color accent700: "#2438D1"
        readonly property color accent600: "#2C4BE4"
        readonly property color accent500: "#3C66EF"
        readonly property color accent400: "#6591F5"
        readonly property color accent300: "#97B7F9"
        readonly property color accent200: "#C1D2FC"
        readonly property color accent100: "#DCE5FD"
        readonly property color accent50:  "#F0F4FE"
        readonly property color accentA40: hexWithAlpha(accent500, 0.4)
        readonly property color accentA30: hexWithAlpha(accent500, 0.3)
        readonly property color accentA20: hexWithAlpha(accent500, 0.2)
        readonly property color accentA10: hexWithAlpha(accent500, 0.1)
        readonly property color accentA5:  hexWithAlpha(accent500, 0.05)

        // Success
        readonly property color success700: "#458406"
        readonly property color success600: "#539E07"
        readonly property color success500: "#67CA00"
        readonly property color success400: "#93FB20"
        readonly property color success300: "#B3FF53"
        readonly property color success200: "#D2FF92"
        readonly property color success100: "#E9FFC5"
        readonly property color success50:  "#F5FFE4"
        readonly property color successA40: hexWithAlpha(success500, 0.4)
        readonly property color successA30: hexWithAlpha(success500, 0.3)
        readonly property color successA20: hexWithAlpha(success500, 0.2)
        readonly property color successA10: hexWithAlpha(success500, 0.1)
        readonly property color successA5:  hexWithAlpha(success500, 0.05)

        // Error
        readonly property color error700: "#F41B1B"
        readonly property color error600: "#F53333"
        readonly property color error500: "#F64D4D"
        readonly property color error400: "#FD6C6C"
        readonly property color error300: "#FFA2A2"
        readonly property color error200: "#FFC8C8"
        readonly property color error100: "#FFE1E1"
        readonly property color error50:  "#FEF2F2"
        readonly property color errorA40: hexWithAlpha(error500, 0.4)
        readonly property color errorA30: hexWithAlpha(error500, 0.3)
        readonly property color errorA20: hexWithAlpha(error500, 0.2)
        readonly property color errorA10: hexWithAlpha(error500, 0.1)
        readonly property color errorA5:  hexWithAlpha(error500, 0.05)

        // Warning
        readonly property color warning700: "#965000"
        readonly property color warning600: "#C86A00"
        readonly property color warning500: "#FA8500"
        readonly property color warning400: "#FB911A"
        readonly property color warning300: "#FCAA4D"
        readonly property color warning200: "#FDC280"
        readonly property color warning100: "#FEDAB3"
        readonly property color warning50:  "#FFF3E6"
        readonly property color warningA40: hexWithAlpha(warning500, 0.4)
        readonly property color warningA30: hexWithAlpha(warning500, 0.3)
        readonly property color warningA20: hexWithAlpha(warning500, 0.2)
        readonly property color warningA10: hexWithAlpha(warning500, 0.1)
        readonly property color warningA5:  hexWithAlpha(warning500, 0.05)

        // Caution
        readonly property color caution700: "#CE8800"
        readonly property color caution600: "#EFB103"
        readonly property color caution500: "#FFCF26"
        readonly property color caution400: "#FFDF43"
        readonly property color caution300: "#FFF087"
        readonly property color caution200: "#FFF9C2"
        readonly property color caution100: "#FEFCE8"
        readonly property color caution50:  "#FFFEF0"
        readonly property color cautionA40: hexWithAlpha(caution500, 0.4)
        readonly property color cautionA30: hexWithAlpha(caution500, 0.3)
        readonly property color cautionA20: hexWithAlpha(caution500, 0.2)
        readonly property color cautionA10: hexWithAlpha(caution500, 0.1)
        readonly property color cautionA5:  hexWithAlpha(caution500, 0.05)
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

    motion: MotionTokens { }
}
