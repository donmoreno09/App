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
    readonly property string familySans: "Inter, Noto Sans, Ubuntu, Cantarell, Segoe UI, Roboto, sans-serif"
    readonly property string familyMono: "JetBrains Mono, Fira Code, Menlo, Consolas, 'DejaVu Sans Mono', monospace"
    readonly property string familySerif: "Merriweather, Georgia, serif"

    // Font sizes (px) — Text.font.pixelSize
    readonly property int sizeXs:   12
    readonly property int sizeSm:   14
    readonly property int sizeBase: 16
    readonly property int sizeLg:   18
    readonly property int sizeXl:   20
    readonly property int size2xl:  24
    readonly property int size3xl:  30

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
    readonly property bool antialiased: true
}
