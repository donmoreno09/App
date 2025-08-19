Semantic color roles for the theme (surfaces, text, brand/primary, status). Defined in `tokens/ColorTokens.qml` and exposed via `Theme.colors`.

[[_TOC_]]

## Example File

```qml
// tokens/ColorTokens.qml

QtObject {
    // Surfaces
    readonly property color background: "#0F1115"
    readonly property color surface: "#171A21"
    readonly property color overlay: "#202630"

    // Text
    readonly property color text: "#E8EAED"
    readonly property color textMuted: "#A3A9B5"

    // Other properties...
}
```

## Example Usage

```qml
Rectangle {
    color: Theme.colors.surface
}

Text {
    text: "Confirm"
    color: Theme.colors.success
}
```

## Extend it

If you need extra roles, add new `readonly property color` entries in `ColorTokens.qml`. If you're also extending for a variant, don't forget to override the new properties there as well.
