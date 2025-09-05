Standard size tokens for icons. Defined in `tokens/IconTokens.qml` and exposed via `Theme.icons`.

[[_TOC_]]

## Example File

```qml
// tokens/IconTokens.qml

QtObject {
    // Sizes
    readonly property int sizeXs:   12
    readonly property int sizeSm:   16
    readonly property int sizeMd:   20
    readonly property int sizeLg:   24
    readonly property int sizeXl:   32
    readonly property int size2Xl:  40
    readonly property int size3Xl:  48

    // Semantic mappings (extend if needed)
    // Example: readonly property int button: sizeLg
}
```

## Example Usage

```qml
// Button with default 24dp icon
Button {
    icon.source: "qrc:/icons/add.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
}

// Extra small icon in a label
Row {
    spacing: Theme.spacing.s2
    Image {
        source: "qrc:/icons/info.svg"
        width: Theme.icons.sizeXs
        height: Theme.icons.sizeXs
    }
    Text {
        text: "Info"
    }
}
```

## Notes

- Only **sizes** are defined here. Unless there are other tokens specific to icons which make sense to be here.
- Color -> `Theme.colors.*`
- Opacity -> `Theme.opacity.*`
- Stroke widths, mirroring, or icon style (filled/outlined) belong to components, not tokens.
- Keeping sizes centralized avoids arbitrary values in layouts.

## Extend it

Add semantic mappings or other tokens as `required` properties when it seems fit. Variants inherit automatically; override only if you want a variant-specific scheme.
