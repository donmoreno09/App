/*!
    \qmltype SpacingTokens
    \inqmlmodule App.Themes
    \brief Numeric spacing scale for margins, paddings, and gaps.

    The spacing token family provides a small, numeric scale (Tailwind-inspired)
    to eliminate magic numbers in layouts. All values are calculated from a single
    base unit, so changing the scale globally is easy.

    Use for:
    - \c {Layout.spacing} and \c {Layout.margins} (\c {RowLayout} \c {ColumnLayout} \c {GridLayout})
    - Control paddings (e.g., \c {Control.padding}, \c {paddingLeft}, ...)
    - Anchor margins (e.g., \c {anchors.margins})

    Example usage:
    \code
    ColumnLayout {
        spacing: Theme.spacing.s4   // 16px
    }
    \endcode

    Notes:
    - Avoid mixing anchors on items managed by a Layout.
    - Keep the scale minimal; only add steps if truly needed.
*/

import QtQuick 2.15

QtObject {
    id: spacing

    // Base unit (device-independent pixels). Adjusting this changes the whole scale.
    readonly property int base: 4

    // Half-steps (small end only)
    readonly property int s0_5: Math.round(base * 0.5)   // 2px
    readonly property int s1_5: Math.round(base * 1.5)   // 6px
    readonly property int s2_5: Math.round(base * 2.5)   // 10px
    readonly property int s3_5: Math.round(base * 3.5)   // 14px

    // Whole steps
    readonly property int s1:   base * 1                 // 4px
    readonly property int s2:   base * 2                 // 8px
    readonly property int s3:   base * 3                 // 12px
    readonly property int s4:   base * 4                 // 16px
    readonly property int s5:   base * 5                 // 20px
    readonly property int s6:   base * 6                 // 24px
    readonly property int s8:   base * 8                 // 32px
    readonly property int s10:  base * 10                // 40px
    readonly property int s12:  base * 12                // 48px
    readonly property int s16:  base * 16                // 64px
}
