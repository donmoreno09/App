Design tokens for visual effects (blur, shadows, color adjustments, masking). Defined in `tokens/EffectTokens.qml` and exposed via `Theme.effects`.

[[_TOC_]]

## Example File

```qml
// tokens/EffectTokens.qml

QtObject {
    // Blur presets
    readonly property real blurXs: 0.10
    readonly property real blurSm: 0.25
    readonly property real blurMd: 0.45
    readonly property real blurLg: 0.65
    readonly property real blurXl: 0.85

    // Shadow presets
    readonly property real shadowBlurSm: 0.20
    readonly property real shadowOpacitySm: 0.15
    readonly property real shadowOffsetYSm: 4

    // Brightness / Contrast
    readonly property real brightnessDisabled: -0.15
    readonly property real contrastMuted: -0.15

    // Saturation
    readonly property real saturationMuted: -0.40

    // Mask thresholds
    readonly property real maskRevealSoftMin: 0.20

    // Policy helpers
    readonly property bool useLayerEffectByDefault: true
}
```

## Example Usage

```qml
// Blur effect
MultiEffect {
    anchors.fill: parent
    source: someItem
    blur: Theme.effects.blurMd
}

// Drop shadow
MultiEffect {
    source: someItem
    shadowEnabled: true
    shadowBlur: Theme.effects.shadowBlurMd
    shadowOpacity: Theme.effects.shadowOpacityMd
    shadowVerticalOffset: Theme.effects.shadowOffsetYMd
}

// Disabled button brightness
MultiEffect {
    source: buttonContent
    brightness: Theme.effects.brightnessDisabled
}
```

## Notes

- Built for **Qt 6.8.x** with `MultiEffect`.
- Animate **intensities** (e.g., blur, brightness, contrast), but keep structural knobs (e.g., `blurMaxDefault`, `blurMultiplierDefault`) static.
- When moving to **Qt 6.9+**, consider adding `RectangularShadow` tokens for rounded-rect shadows.
- Effects here are **numeric presets only**; they do not implement the effects themselves.

## Extend it

Add new presets for blur, shadows, or adjustments as new `readonly` properties in `EffectTokens.qml`. Variants inherit automatically; override only if you want a variant-specific scheme.
