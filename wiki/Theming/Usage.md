[[_TOC_]]

## Importing

To use the theming system, import the `App.Themes` module:

```qml
import App.Themes 10

Rectangle {
    color: Theme.colors.background
    radius: Theme.radius.md
}
```

## Accessing Tokens

- Always go through the **Theme singleton** than directly accessing the `current` property like `Theme.current.colors.text`.
- Tokens are exposed as properties grouped by family (`colors`, `typography`, `spacing`, etc.).

Example:

```qml
Text {
    text: "Hello"
    color: Theme.colors.text
    font.pixelSize: Theme.typography.sizeBase
    font.weight: Theme.typography.weightSemibold
}
```

## Switching Variants at Runtime

To switch between variants, `Theme` exposes a `setTheme()` method:

```qml
Button {
    text: "Switch to Fincantieri Theme"
    onClicked: Theme.setTheme(Themes.Fincantieri)
}

Connections {
    target: Theme
    function onThemeChanged(variant) {
        console.log("Theme switched to", variant) // this is an enum integer value
    }
}
```

## Extending

Check [Creating a Variant](Creating-A-Variant.md) for creating new theme variants.
