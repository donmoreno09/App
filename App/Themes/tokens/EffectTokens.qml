/*!
    \qmltype EffectsTokens
    \inqmlmodule App.Themes
    \brief Design tokens for visual effects (blur, shadows, color adjustments, masking).

    This family standardizes numeric presets for QtQuick.Effects usage.
    It does NOT implement components. Bind these values in your controls.

    Key guidance:
    - Qt 6.8.x: use MultiEffect for shadows, blurs, masking, and color tweaks.
    - Animate intensities (e.g., blur, brightness, contrast, saturation, colorization).
    - Keep structural knobs static (blurMax, blurMultiplier, autoPaddingEnabled).
    - When upgrading to Qt 6.9+, consider adding RectangularShadow tokens for rounded-rect shadows.
*/

import QtQml 2.15

QtObject {
    // Blur (used in MultiEffect.blur [0..1])
    readonly property real blurXs: 0.10
    readonly property real blurSm: 0.25
    readonly property real blurMd: 0.45
    readonly property real blurLg: 0.65
    readonly property real blurXl: 0.85

    // Structural
    // Used in MultiEffect.blurMax / blurMultiplier / autoPaddingEnabled
    readonly property int  blurMaxDefault:        32
    readonly property real blurMultiplierDefault: 1.00
    readonly property bool autoPaddingEnabledDefault: true

    // Lower quality to reach larger radii at lower cost
    // Used in MultiEffect.blurMultiplier
    readonly property real blurMultiplierBackdrop: 0.50

    // Shadow intensities
    // Used in MultiEffect.shadowBlur
    readonly property real shadowBlurSm: 0.20
    readonly property real shadowBlurMd: 0.45
    readonly property real shadowBlurLg: 0.70

    // Shadow opacity
    // Used in MultiEffect.shadowOpacity
    readonly property real shadowOpacitySm: 0.15
    readonly property real shadowOpacityMd: 0.25
    readonly property real shadowOpacityLg: 0.35

    // Shadow offsets
    // Used in MultiEffect.shadowHorizontalOffset / shadowVerticalOffset
    readonly property real shadowOffsetXSm: 0
    readonly property real shadowOffsetYSm: 4
    readonly property real shadowOffsetXMd: 0
    readonly property real shadowOffsetYMd: 8
    readonly property real shadowOffsetXLg: 0
    readonly property real shadowOffsetYLg: 12

    // Brightness adjustment
    // Used in MultiEffect.brightness
    readonly property real brightnessDisabled:   -0.15
    readonly property real brightnessEmphasis:    0.08
    readonly property real glassBrightness:       0.15

    // Contrast adjustment
    // Used in MultiEffect.contrast
    readonly property real contrastMuted:        -0.15
    readonly property real contrastEmphasis:      0.08

    // Saturation adjustment
    // Used in MultiEffect.saturation
    readonly property real saturationMuted:      -0.40
    readonly property real saturationEmphasis:    0.10
    readonly property real glassSaturation:       0.25

    // Colorization intensity
    // Used in MultiEffect.colorization / colorizationColor
    readonly property real glassColorization:     0.00

    // Mask thresholds
    // Used in MultiEffect.maskThresholdMin / maskThresholdMax / maskSpreadAtMin
    readonly property real maskRevealSoftMin:       0.20
    readonly property real maskRevealSoftMax:       1.00
    readonly property real maskRevealSoftSpreadMin: 0.20

    readonly property real maskRevealHardMin:       0.00
    readonly property real maskRevealHardMax:       1.00
    readonly property real maskRevealHardSpreadMin: 0.00

    // Policy helpers
    // Used in component defaults
    readonly property bool useLayerEffectByDefault: true
    readonly property real backdropTextureScale:    0.50
}
