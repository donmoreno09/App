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

import QtQuick 6.8

QtObject {
    // -------------------------- // SEMANTICS // -------------------------- //

    // Surfaces
    readonly property color transparent: "transparent"
    readonly property color background: primary900 // App base layer; behind all content
    readonly property color surface: primary800    // Elevated containers (cards, panels, sheets)
    readonly property color overlay: grey500       // Transparent/dim layer above background/surface
    readonly property color glass: blackA10
    readonly property color glassWhite: whiteA10

    // Text
    readonly property color text: white500
    readonly property color textMuted: grey300

    // Borders
    readonly property color border: secondary500
    readonly property color glassBorder: whiteA20

    // -------------------------- // PRIMITIVES // -------------------------- //

    // Black
    readonly property color black500: "#000000"
    readonly property color blackA80: hexWithAlpha(black500, 0.8)
    readonly property color blackA60: hexWithAlpha(black500, 0.6)
    readonly property color blackA40: hexWithAlpha(black500, 0.4)
    readonly property color blackA20: hexWithAlpha(black500, 0.2)
    readonly property color blackA10: hexWithAlpha(black500, 0.1)
    readonly property color blackA5:  hexWithAlpha(black500, 0.05)
    readonly property color blackA0:  hexWithAlpha(black500, 0.0)

    // White
    readonly property color white500: "#FFFFFF"
    readonly property color whiteA80: hexWithAlpha(white500, 0.8)
    readonly property color whiteA60: hexWithAlpha(white500, 0.6)
    readonly property color whiteA40: hexWithAlpha(white500, 0.4)
    readonly property color whiteA20: hexWithAlpha(white500, 0.2)
    readonly property color whiteA10: hexWithAlpha(white500, 0.1)
    readonly property color whiteA5:  hexWithAlpha(white500, 0.05)
    readonly property color whiteA0:  hexWithAlpha(white500, 0.0)

    // Grey
    readonly property color grey700: "#000000"
    readonly property color grey600: "#000D1A"
    readonly property color grey500: "#757878"
    readonly property color grey400: "#8C8C8C"
    readonly property color grey300: "#A1A1A1"
    readonly property color grey200: "#B5B5B5"
    readonly property color grey100: "#CCCCCC"
    readonly property color grey50:  "#E1E1E1"
    readonly property color grey25:  "#F1F1F1"
    readonly property color greyA30: hexWithAlpha(grey500, 0.3)
    readonly property color greyA20: hexWithAlpha(grey500, 0.2)
    readonly property color greyA10: hexWithAlpha(grey500, 0.1)
    readonly property color greyA5:  hexWithAlpha(grey500, 0.05)

    // Primary
    readonly property color primary900: "#0F1115"
    readonly property color primary800: "#171A21"
    readonly property color primary700: "#002347"
    readonly property color primary600: "#002F61"
    readonly property color primary500: "#003A78"
    readonly property color primary400: "#29598C"
    readonly property color primary300: "#5278A3"
    readonly property color primary200: "#7A99B8"
    readonly property color primary100: "#A3B8CC"
    readonly property color primary50:  "#CCD6E0"
    readonly property color primaryA30: hexWithAlpha(primary500, 0.3)
    readonly property color primaryA20: hexWithAlpha(primary500, 0.2)
    readonly property color primaryA10: hexWithAlpha(primary500, 0.1)
    readonly property color primaryA5:  hexWithAlpha(primary500, 0.05)

    // Secondary
    readonly property color secondary700: "#000000"
    readonly property color secondary600: "#000D1A"
    readonly property color secondary500: "#001C35"
    readonly property color secondary400: "#294054"
    readonly property color secondary300: "#526375"
    readonly property color secondary200: "#7A8A94"
    readonly property color secondary100: "#A3ADB5"
    readonly property color secondary50:  "#CCD1D6"
    readonly property color secondaryA30: hexWithAlpha(secondary500, 0.3)
    readonly property color secondaryA20: hexWithAlpha(secondary500, 0.2)
    readonly property color secondaryA10: hexWithAlpha(secondary500, 0.1)
    readonly property color secondaryA5:  hexWithAlpha(secondary500, 0.05)

    // Accent
    readonly property color accent700: "#172B98"
    readonly property color accent600: "#1027C3"
    readonly property color accent500: "#0D27F2"
    readonly property color accent400: "#1A37FF"
    readonly property color accent300: "#3C66FF"
    readonly property color accent200: "#608FFF"
    readonly property color accent100: "#8DBAFF"
    readonly property color accent50:  "#B8D6FF"
    readonly property color accentA40: hexWithAlpha(accent500, 0.4)
    readonly property color accentA30: hexWithAlpha(accent500, 0.3)
    readonly property color accentA20: hexWithAlpha(accent500, 0.2)
    readonly property color accentA10: hexWithAlpha(accent500, 0.1)
    readonly property color accentA5:  hexWithAlpha(accent500, 0.05)

    // Success
    readonly property color success700: "#2D4D00"
    readonly property color success600: "#316600"
    readonly property color success500: "#3D7E00"
    readonly property color success400: "#449500"
    readonly property color success300: "#5CC500"
    readonly property color success200: "#7AF500"
    readonly property color success100: "#9AFF0D"
    readonly property color success50:  "#B8FF44"
    readonly property color successA40: hexWithAlpha(success500, 0.4)
    readonly property color successA30: hexWithAlpha(success500, 0.3)
    readonly property color successA20: hexWithAlpha(success500, 0.2)
    readonly property color successA10: hexWithAlpha(success500, 0.1)
    readonly property color successA5:  hexWithAlpha(success500, 0.05)

    // Error
    readonly property color error700: "#A32E2E"
    readonly property color error600: "#B73434"
    readonly property color error500: "#C83D3D"
    readonly property color error400: "#DC5757"
    readonly property color error300: "#F2AFAF"
    readonly property color error200: "#F8D0D0"
    readonly property color error100: "#FBE5E5"
    readonly property color error50:  "#FDF3F3"
    readonly property color errorA40: hexWithAlpha(error500, 0.4)
    readonly property color errorA30: hexWithAlpha(error500, 0.3)
    readonly property color errorA20: hexWithAlpha(error500, 0.2)
    readonly property color errorA10: hexWithAlpha(error500, 0.1)
    readonly property color errorA5:  hexWithAlpha(error500, 0.05)

    // Warning
    readonly property color warning700: "#963F0A"
    readonly property color warning600: "#B95204"
    readonly property color warning500: "#D37000"
    readonly property color warning400: "#D77E1A"
    readonly property color warning300: "#E09B4D"
    readonly property color warning200: "#E9B880"
    readonly property color warning100: "#F2D4B3"
    readonly property color warning50:  "#FBF1E6"
    readonly property color warningA40: hexWithAlpha(warning500, 0.4)
    readonly property color warningA30: hexWithAlpha(warning500, 0.3)
    readonly property color warningA20: hexWithAlpha(warning500, 0.2)
    readonly property color warningA10: hexWithAlpha(warning500, 0.1)
    readonly property color warningA5:  hexWithAlpha(warning500, 0.05)

    // Caution
    readonly property color caution700: "#754F0E"
    readonly property color caution600: "#8A6109"
    readonly property color caution500: "#A27900"
    readonly property color caution400: "#D3AE00"
    readonly property color caution300: "#F4DE00"
    readonly property color caution200: "#F7FF85"
    readonly property color caution100: "#F9FFC0"
    readonly property color caution50:  "#FDFFE7"
    readonly property color cautionA40: hexWithAlpha(caution500, 0.4)
    readonly property color cautionA30: hexWithAlpha(caution500, 0.3)
    readonly property color cautionA20: hexWithAlpha(caution500, 0.2)
    readonly property color cautionA10: hexWithAlpha(caution500, 0.1)
    readonly property color cautionA5:  hexWithAlpha(caution500, 0.05)

    // Helper functions
    function hexWithAlpha(hex: string, alpha: real): string {
        // hex: "#RGB" or "#RRGGBB"
        // alpha: 0..1
        if (typeof hex !== "string") {
            throw new Error(`hexWithAlpha: expected a string like '#RRGGBB', got  ${typeof hex} with value '${hex}'`);
        }

        let normalizedHex = hex.replace('#', '')
        if (normalizedHex.length === 3) normalizedHex = normalizedHex.split('').map((c) => c + c).join('');

        const normalizedAlpha = Math.max(0, Math.min(1, alpha));
        const alphaHex = Math.round(normalizedAlpha * 255).toString(16).padStart(2, '0').toUpperCase();

        return `#${alphaHex}${normalizedHex.toUpperCase()}`; // ARGB
    }
}
