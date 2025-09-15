/*!
  \qmltype TypographyTokens
  \inqmlmodule App.Themes
  \brief Typography design tokens for consistent, themeable text styling.

  These tokens wrap Qt's built-in text and font properties, providing a semantic,
  themeable layer. Use them to ensure consistent styling and allow easy overrides
  in different theme variants.

  The tokens were inspired from Tailwind.

  The usage of each token is given below (e.g. Text.font.family), for more
  information, see [Text QML Type](https://doc.qt.io/qt-6/qml-qtquick-text.html)
*/

import QtQuick 2.15

QtObject {
    // Font families — Text.font.family
    readonly property string familySans: "PP Fraktion Sans"
    readonly property string familyMono: "PP Fraktion Mono"

    // Base size and scale ratio (named font size steps derive from these)
    readonly property int  baseFontSize:   16     // dpi
    readonly property real fontScaleRatio: 1.15   // common ratio, reads well across steps

    // Font sizes (derived) — Text.font.pointSize
    readonly property int sizeXs:   Math.round(baseFontSize * Math.pow(fontScaleRatio, -2))  // = 12 (with scale ratio = 1.15)
    readonly property int sizeSm:   Math.round(baseFontSize * Math.pow(fontScaleRatio, -1))  // = 14 (with scale ratio = 1.15)
    readonly property int sizeBase: Math.round(baseFontSize * Math.pow(fontScaleRatio,  0))  // = 16 (with scale ratio = 1.15)
    readonly property int sizeLg:   Math.round(baseFontSize * Math.pow(fontScaleRatio,  1))  // = 18 (with scale ratio = 1.15)
    readonly property int sizeXl:   Math.round(baseFontSize * Math.pow(fontScaleRatio,  2))  // = 21 (with scale ratio = 1.15)
    readonly property int size2xl:  Math.round(baseFontSize * Math.pow(fontScaleRatio,  3))  // = 24 (with scale ratio = 1.15)
    readonly property int size3xl:  Math.round(baseFontSize * Math.pow(fontScaleRatio,  4))  // = 28 (with scale ratio = 1.15)

    // Font weights — Text.font.weight
    readonly property int weightThin:     Font.Thin
    readonly property int weightLight:    Font.Light
    readonly property int weightNormal:   Font.Normal
    readonly property int weightMedium:   Font.Medium
    readonly property int weightSemibold: Font.DemiBold
    readonly property int weightBold:     Font.Bold
    readonly property int weightBlack:    Font.Black

    // Letter spacing (px) — Text.font.letterSpacing
    // Negative tightens, positive spreads.
    readonly property real letterSpacingTighter: -0.5
    readonly property real letterSpacingTight:   -0.25
    readonly property real letterSpacingNormal:   0.0
    readonly property real letterSpacingWide:     0.25
    readonly property real letterSpacingWider:    0.5
    readonly property real letterSpacingWidest:   1.0

    // Word spacing (px) — Text.font.wordSpacing
    readonly property real wordSpacingTight:  -1.0
    readonly property real wordSpacingNormal:  0.0
    readonly property real wordSpacingWide:    1.0
    readonly property real wordSpacingWider:   2.0

    // Line height — Text.lineHeightMode + Text.lineHeight
    // Set mode using leadingMode; then bind a multiplier below.
    readonly property int  leadingMode:    Text.ProportionalHeight
    readonly property real leadingTight:   1.25
    readonly property real leadingNormal:  1.50
    readonly property real leadingRelaxed: 1.75
    readonly property real leadingLoose:   2.00

    // Text transform (capitalization) — Text.font.capitalization
    readonly property int transformNone:       Font.MixedCase
    readonly property int transformUppercase:  Font.AllUppercase
    readonly property int transformLowercase:  Font.AllLowercase
    readonly property int transformCapitalize: Font.Capitalize
    readonly property int transformSmallCaps:  Font.SmallCaps

    // Decoration flags
    // (Use these booleans for semantic defaults; override per use as needed.)
    readonly property bool decorationUnderline: true // Text.font.underline
    readonly property bool decorationStrikeout: true // Text.font.strikeout
    readonly property bool decorationBold:      true // Text.font.bold
    readonly property bool decorationItalic:    true // Text.font.italic

    // Elide (ellipsis handling) — Text.elide
    // Works only when wrapMode is Text.NoWrap and text overflows
    // available width; ignored if wrapping is enabled.
    readonly property int elideNone:   Text.ElideNone
    readonly property int elideLeft:   Text.ElideLeft
    readonly property int elideRight:  Text.ElideRight
    readonly property int elideMiddle: Text.ElideMiddle

    // Wrapping — Text.wrapMode
    readonly property int wrapNoWrap:                   Text.NoWrap
    readonly property int wrapWord:                     Text.WordWrap
    readonly property int wrapAnywhere:                 Text.WrapAnywhere
    readonly property int wrapAtWordBoundaryOrAnywhere: Text.WrapAtWordBoundaryOrAnywhere

    // Rendering — Text.antialiasing
    // Already enabled by default; only included here for consistency.
    readonly property bool antialiased: true
}
