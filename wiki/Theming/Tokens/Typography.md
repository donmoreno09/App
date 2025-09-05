Semantic tokens for fonts and text styling (families, sizes, weights, spacing, line‑height, transforms, elide/wrap). Defined in `tokens/TypographyTokens.qml` and exposed via `Theme.typography`.

[[_TOC_]]

## Example File

```qml
// tokens/TypographyTokens.qml

QtObject {
    // Families — Text.font.family
    readonly property string familySans:  "Segoe UI"
    readonly property string familyMono:  "Consolas"
    readonly property string familySerif: "Georgia"

    // Sizing (derived from base + ratio) — Text.font.pixelSize
    readonly property int  baseFontSize:   16
    readonly property real fontScaleRatio: 1.15
    readonly property int sizeSm:   Math.round(baseFontSize * Math.pow(fontScaleRatio, -1)) // ≈14
    readonly property int sizeBase: Math.round(baseFontSize)                                 // 16
    readonly property int sizeLg:   Math.round(baseFontSize * Math.pow(fontScaleRatio,  1)) // ≈18
    // ...

    // Weights — Text.font.weight
    readonly property int weightNormal:   Font.Normal
    readonly property int weightSemibold: Font.DemiBold
    readonly property int weightBold:     Font.Bold
    // ...

    // Spacing — Text.font.letterSpacing / wordSpacing (px)
    readonly property real letterSpacingNormal: 0.0
    readonly property real letterSpacingTight: -0.25
    readonly property real wordSpacingWide:    1.0
    // ...

    // Line height — set mode + multiplier
    readonly property int  leadingMode:   Text.ProportionalHeight
    readonly property real leadingNormal: 1.5
    // ...

    // Transform — Text.font.capitalization
    readonly property int transformUppercase:  Font.AllUppercase
    readonly property int transformNone:       Font.MixedCase
    // ...

    // Elide — Text.elide
    readonly property int elideRight:  Text.ElideRight
    readonly property int elideNone:   Text.ElideNone

    // Wrap — Text.wrapMode
    readonly property int wrapNoWrap:  Text.NoWrap
    readonly property int wrapWord:    Text.WordWrap

    // Rendering
    readonly property bool antialiased: true
}
```

## Example Usage

```qml
// Family + size + weight
Text {
    text: "Heading"
    font.family: Theme.typography.familySans
    font.pixelSize: Theme.typography.sizeLg
    font.weight: Theme.typography.weightSemibold
}

// Letter spacing and line height
Text {
    text: longParagraph
    lineHeightMode: Theme.typography.leadingMode
    lineHeight: Theme.typography.leadingNormal
    font.letterSpacing: Theme.typography.letterSpacingTight
}

// Elide (works only with NoWrap + overflow)
Text {
    width: 200
    elide: Theme.typography.elideRight
    wrapMode: Theme.typography.wrapNoWrap
    text: veryLongTitle
}

// Wrapping
Text {
    wrapMode: Theme.typography.wrapWord
    text: multilineBody
}

// Transform
Text {
    text: "label"
    font.capitalization: Theme.typography.transformUppercase
}
```

## Notes

- **Sizing:** All named sizes derive from `baseFontSize` and `fontScaleRatio`. Adjust these two to scale the whole system.
- **Line height:** Set `lineHeightMode` (e.g., `Text.ProportionalHeight`) and then bind a **multiplier** (e.g., `1.5`).
- **Elide:** Takes effect only when `wrapMode` is `Text.NoWrap` **and** the text exceeds available width.
- **Wrapping:** `wrapWord` wraps at boundaries; `wrapAnywhere` is more aggressive.
- **Decorations:** If you expose boolean defaults (underline/italic/etc.), treat them as **defaults**. Override per use as needed.
- **Antialiasing:** `Text.antialiasing` is already enabled by Qt; the token is provided for completeness/consistency.

## Extend it

If you need more steps or semantics, add new `readonly` properties in `TypographyTokens.qml`. If you’re also customizing a specific variant, override those properties there.
