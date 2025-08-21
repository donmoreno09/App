Stroke sizes for borders and focus outline rings. Defined in `tokens/BorderTokens.qml` and exposed via `Theme.borders`.

[[_TOC_]]

## Example File

```qml
// tokens/BorderTokens.qml

QtObject {
    // Border widths (dp)
    readonly property int b0: 0
    readonly property int b1: 1
    readonly property int b2: 2
    readonly property int b4: 4
    readonly property int b6: 6
    readonly property int b8: 8

    // Focus outline ring widths (dp)
    readonly property int outline0: 0
    readonly property int outline1: 1
    readonly property int outline2: 2
    readonly property int outline4: 4
    readonly property int outline6: 6
    readonly property int outline8: 8

    // Outline offsets (expand outward)
    readonly property int offset0: 0
    readonly property int offset1: 1
    readonly property int offset2: 2
    readonly property int offset4: 4
    // ...
}
```

## Example Usage

```qml
// Solid border
Rectangle {
    radius: Theme.radius.md
    border.width: Theme.borders.b2
    border.color: Theme.colors.textMuted
}

// Focus outline ring (overlay sibling)
Item {
    width: 220; height: 140

    // Control
    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.md
        color: Theme.colors.surface
        border.width: Theme.borders.b2
        border.color: Theme.colors.textMuted
    }

    // Outline ring
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        anchors.margins: -Theme.borders.offset2   // expand outward
        border.width: Theme.borders.outline2
        radius: Theme.radius.md + Theme.borders.outline2
        border.color: Theme.colors.primary
        visible: focused // or any condition
    }
}
```

## Notes

- QML has **no generic `outline` property**; implement rings as overlay siblings.
- `Rectangle.border.width` is an `int`; `Rectangle` supports **solid** borders only.
- For dashed/dotted borders, use `Shape`/`ShapePath` (tokens for patterns can be added later).
- Pair `outline*` with `offset*` to control ring thickness vs. outward expansion.

## Extend it

Add more widths, offsets, or pattern tokens as new `readonly` properties in `BorderTokens.qml`. Override in a variant only if you need different values.
