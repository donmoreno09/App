Numeric spacing scale for margins, paddings, and gaps. Defined in `tokens/SpacingTokens.qml` and exposed via `Theme.spacing`.

[[_TOC_]]

## Example File

```qml
// tokens/SpacingTokens.qml

QtObject {
    // Base unit (dp/px). Changing this rescales everything.
    readonly property int base: 4

    // Half-steps (small end)
    readonly property int s0_5: Math.round(base * 0.5)  // 2
    readonly property int s1_5: Math.round(base * 1.5)  // 6
    readonly property int s2_5: Math.round(base * 2.5)  // 10
    readonly property int s3_5: Math.round(base * 3.5)  // 14

    // Whole steps
    readonly property int s1:  base * 1   // 4
    readonly property int s2:  base * 2   // 8
    readonly property int s3:  base * 3   // 12
    readonly property int s4:  base * 4   // 16
    readonly property int s5:  base * 5   // 20
    readonly property int s6:  base * 6   // 24
    readonly property int s8:  base * 8   // 32
    readonly property int s10: base * 10  // 40
    readonly property int s12: base * 12  // 48
    readonly property int s16: base * 16  // 64
    // ...
}
```

## Example Usage

```qml
// Layout spacing
ColumnLayout {
    spacing: Theme.spacing.s4  // 16
    // ...
}

// Control padding
Button {
    padding: Theme.spacing.s3  // 12
}

// Anchor margins
Rectangle {
    anchors.margins: Theme.spacing.s2 // 8
}
```

## Notes

- Prefer a **small, consistent scale** to avoid magic numbers.
- Avoid mixing **anchors** on items that are inside a `Layout`, i.e. `ColumnLayout` or `RowLayout`, since they are **different** from `Column` or `Row` and act more like a flexbox in CSS.
- Tweaking `base` scales the entire system.

## Extend it

If you need more steps, add new `readonly property int` entries in `SpacingTokens.qml`. If you’re customizing a specific variant, only override the values you want to change.
