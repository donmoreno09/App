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

    // Font sizes - Text.font.pointSize
    readonly property int fontSize100:  8   // font-size-100
    readonly property int fontSize125:  10  // font-size-125
    readonly property int fontSize150:  12  // font-size-150
    readonly property int fontSize175:  14  // font-size-175
    readonly property int fontSize200:  18  // font-size-200
    readonly property int fontSize250:  20  // font-size-250
    readonly property int fontSize300:  24  // font-size-300
    readonly property int fontSize400:  32  // font-size-400
    readonly property int fontSize500:  40  // font-size-500
    readonly property int fontSize600:  48  // font-size-600
    readonly property int fontSize800:  64  // font-size-800
    readonly property int fontSize900:  72  // font-size-900

     // Font weights — Text.font.weight
    readonly property int weightLight:     300  // weight-light
    readonly property int weightRegular:   390  // weight-regular
    readonly property int weightMedium:    450  // weight-medium
    readonly property int weightSemibold:  560  // weight-semibold
    readonly property int weightBold:      645  // weight-bold

     // Line height — Text.lineHeightMode + Text.lineHeight
     // Set mode using leadingMode; then bind a multiplier below.
    readonly property int  leadingMode:    Text.ProportionalHeight
    readonly property real lineHeightMono: 1.31  // 131% from design system
    readonly property real lineHeightSans: 1.22  // 122% from design system

     // TYPOGRAPHY STYLES - Semantic presets combining primitives
     // Each style combines: family + size + weight (no line height - use primitives)

     // HEADING STYLES

     // heading-100: family-sans + size-250 + weight-medium
    readonly property string heading100Family: familySans
    readonly property int heading100Size: fontSize250
    readonly property int heading100Weight: weightMedium

     // heading-150: family-sans + size-400 + weight-medium
    readonly property string heading150Family: familySans
    readonly property int heading150Size: fontSize400
    readonly property int heading150Weight: weightMedium

     // heading-200: family-sans + size-500 + weight-medium
    readonly property string heading200Family: familySans
    readonly property int heading200Size: fontSize500
    readonly property int heading200Weight: weightMedium

     // BODY SANS STYLES

     // body-sans-15: family-sans + size-125 + weight-regular
    readonly property string bodySans15Family: familySans
    readonly property int bodySans15Size: fontSize125
    readonly property int bodySans15Weight: weightRegular

     // body-sans-15-strong: family-sans + size-125 + weight-medium
    readonly property string bodySans15StrongFamily: familySans
    readonly property int bodySans15StrongSize: fontSize125
    readonly property int bodySans15StrongWeight: weightMedium

     // body-sans-25-light: family-sans + size-150 + weight-light
    readonly property string bodySans25LightFamily: familySans
    readonly property int bodySans25LightSize: fontSize150
    readonly property int bodySans25LightWeight: weightLight

     // body-sans-25: family-sans + size-150 + weight-regular
    readonly property string bodySans25Family: familySans
    readonly property int bodySans25Size: fontSize150
    readonly property int bodySans25Weight: weightRegular

     // body-sans-25-strong: family-sans + size-150 + weight-medium
    readonly property string bodySans25StrongFamily: familySans
    readonly property int bodySans25StrongSize: fontSize150
    readonly property int bodySans25StrongWeight: weightMedium

     // body-sans-50-light: family-sans + size-175 + weight-light
    readonly property string bodySans50LightFamily: familySans
    readonly property int bodySans50LightSize: fontSize175
    readonly property int bodySans50LightWeight: weightLight

     // body-sans-50: family-sans + size-175 + weight-regular
    readonly property string bodySans50Family: familySans
    readonly property int bodySans50Size: fontSize175
    readonly property int bodySans50Weight: weightRegular

     // body-sans-50-strong: family-sans + size-175 + weight-medium
    readonly property string bodySans50StrongFamily: familySans
    readonly property int bodySans50StrongSize: fontSize175
    readonly property int bodySans50StrongWeight: weightMedium

     // body-sans-100-light: family-sans + size-200 + weight-light
    readonly property string bodySans100LightFamily: familySans
    readonly property int bodySans100LightSize: fontSize200
    readonly property int bodySans100LightWeight: weightLight

     // body-sans-100: family-sans + size-200 + weight-regular
    readonly property string bodySans100Family: familySans
    readonly property int bodySans100Size: fontSize200
    readonly property int bodySans100Weight: weightRegular

     // body-sans-100-strong: family-sans + size-200 + weight-medium
    readonly property string bodySans100StrongFamily: familySans
    readonly property int bodySans100StrongSize: fontSize200
    readonly property int bodySans100StrongWeight: weightMedium

     // body-sans-150-light: family-sans + size-250 + weight-light
    readonly property string bodySans150LightFamily: familySans
    readonly property int bodySans150LightSize: fontSize250
    readonly property int bodySans150LightWeight: weightLight

     // body-sans-150: family-sans + size-250 + weight-regular
    readonly property string bodySans150Family: familySans
    readonly property int bodySans150Size: fontSize250
    readonly property int bodySans150Weight: weightRegular

     // body-sans-150-strong: family-sans + size-250 + weight-medium
    readonly property string bodySans150StrongFamily: familySans
    readonly property int bodySans150StrongSize: fontSize250
    readonly property int bodySans150StrongWeight: weightMedium

     // BODY MONO STYLES

     // body-mono-15: family-mono + size-125 + weight-regular
    readonly property string bodyMono15Family: familyMono
    readonly property int bodyMono15Size: fontSize125
    readonly property int bodyMono15Weight: weightRegular

     // body-mono-25-light: family-mono + size-150 + weight-regular
    readonly property string bodyMono25LightFamily: familyMono
    readonly property int bodyMono25LightSize: fontSize150
    readonly property int bodyMono25LightWeight: weightRegular

     // body-mono-25: family-mono + size-150 + weight-regular
    readonly property string bodyMono25Family: familyMono
    readonly property int bodyMono25Size: fontSize150
    readonly property int bodyMono25Weight: weightRegular

     // body-mono-25-strong: family-mono + size-150 + weight-medium
    readonly property string bodyMono25StrongFamily: familyMono
    readonly property int bodyMono25StrongSize: fontSize150
    readonly property int bodyMono25StrongWeight: weightMedium

     // body-mono-50-light: family-mono + size-175 + weight-regular
    readonly property string bodyMono50LightFamily: familyMono
    readonly property int bodyMono50LightSize: fontSize175
    readonly property int bodyMono50LightWeight: weightRegular

     // body-mono-50: family-mono + size-175 + weight-regular
    readonly property string bodyMono50Family: familyMono
    readonly property int bodyMono50Size: fontSize175
    readonly property int bodyMono50Weight: weightRegular

     // body-mono-50-strong: family-mono + size-175 + weight-medium
    readonly property string bodyMono50StrongFamily: familyMono
    readonly property int bodyMono50StrongSize: fontSize175
    readonly property int bodyMono50StrongWeight: weightMedium

     // body-mono-100-light: family-mono + size-200 + weight-regular
    readonly property string bodyMono100LightFamily: familyMono
    readonly property int bodyMono100LightSize: fontSize200
    readonly property int bodyMono100LightWeight: weightRegular

     // body-mono-100: family-mono + size-200 + weight-regular
    readonly property string bodyMono100Family: familyMono
    readonly property int bodyMono100Size: fontSize200
    readonly property int bodyMono100Weight: weightRegular

     // body-mono-100-strong: family-mono + size-200 + weight-medium
    readonly property string bodyMono100StrongFamily: familyMono
    readonly property int bodyMono100StrongSize: fontSize200
    readonly property int bodyMono100StrongWeight: weightMedium

     // body-mono-150-light: family-mono + size-250 + weight-regular
    readonly property string bodyMono150LightFamily: familyMono
    readonly property int bodyMono150LightSize: fontSize250
    readonly property int bodyMono150LightWeight: weightRegular

     // body-mono-150: family-mono + size-250 + weight-regular
    readonly property string bodyMono150Family: familyMono
    readonly property int bodyMono150Size: fontSize250
    readonly property int bodyMono150Weight: weightRegular

     // body-mono-150-strong: family-mono + size-250 + weight-medium
    readonly property string bodyMono150StrongFamily: familyMono
    readonly property int bodyMono150StrongSize: fontSize250
    readonly property int bodyMono150StrongWeight: weightMedium

     // body-mono-175-light: family-mono + size-300 + weight-medium
    readonly property string bodyMono175LightFamily: familyMono
    readonly property int bodyMono175LightSize: fontSize300
    readonly property int bodyMono175LightWeight: weightMedium

     // body-mono-175: family-mono + size-300 + weight-regular
    readonly property string bodyMono175Family: familyMono
    readonly property int bodyMono175Size: fontSize300
    readonly property int bodyMono175Weight: weightRegular

     // body-mono-175-strong: family-mono + size-300 + weight-medium
    readonly property string bodyMono175StrongFamily: familyMono
    readonly property int bodyMono175StrongSize: fontSize300
    readonly property int bodyMono175StrongWeight: weightMedium

     // body-mono-200-light: family-mono + size-400 + weight-medium
    readonly property string bodyMono200LightFamily: familyMono
    readonly property int bodyMono200LightSize: fontSize400
    readonly property int bodyMono200LightWeight: weightMedium

     // body-mono-200: family-mono + size-400 + weight-medium
    readonly property string bodyMono200Family: familyMono
    readonly property int bodyMono200Size: fontSize400
    readonly property int bodyMono200Weight: weightMedium

     // body-mono-200-strong: family-mono + size-400 + weight-medium
    readonly property string bodyMono200StrongFamily: familyMono
    readonly property int bodyMono200StrongSize: fontSize400
    readonly property int bodyMono200StrongWeight: weightMedium

     // body-mono-300-light: family-mono + size-600 + weight-light
    readonly property string bodyMono300LightFamily: familyMono
    readonly property int bodyMono300LightSize: fontSize600
    readonly property int bodyMono300LightWeight: weightLight

     // body-mono-300: family-mono + size-600 + weight-regular
    readonly property string bodyMono300Family: familyMono
    readonly property int bodyMono300Size: fontSize600
    readonly property int bodyMono300Weight: weightRegular

     // body-mono-300-strong: family-mono + size-600 + weight-medium
    readonly property string bodyMono300StrongFamily: familyMono
    readonly property int bodyMono300StrongSize: fontSize600
    readonly property int bodyMono300StrongWeight: weightMedium

     // UTILITY STYLES

     // button-100: family-sans + size-175 + weight-regular
    readonly property string button100Family: familySans
    readonly property int button100Size: fontSize175
    readonly property int button100Weight: weightRegular

     // link-25: family-sans + size-150 + weight-regular
    readonly property string link25Family: familySans
    readonly property int link25Size: fontSize150
    readonly property int link25Weight: weightRegular

     // link-50: family-sans + size-175 + weight-regular
    readonly property string link50Family: familySans
    readonly property int link50Size: fontSize175
    readonly property int link50Weight: weightRegular

     // link-100: family-sans + size-200 + weight-regular
    readonly property string link100Family: familySans
    readonly property int link100Size: fontSize200
    readonly property int link100Weight: weightRegular

     // kpi-title-100: family-sans + size-200 + weight-regular
    readonly property string kpiTitle100Family: familySans
    readonly property int kpiTitle100Size: fontSize200
    readonly property int kpiTitle100Weight: weightRegular

     // kpi-title-75: family-sans + size-125 + weight-regular
    readonly property string kpiTitle75Family: familySans
    readonly property int kpiTitle75Size: fontSize125
    readonly property int kpiTitle75Weight: weightRegular

     // notification-number-100: family-sans + size-125 + weight-regular
    readonly property string notificationNumber100Family: familySans
    readonly property int notificationNumber100Size: fontSize125
    readonly property int notificationNumber100Weight: weightRegular

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
    // readonly property int  leadingMode:    Text.ProportionalHeight
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
