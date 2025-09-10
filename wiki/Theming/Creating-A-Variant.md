[[_TOC_]]

This guide explains how to add a new theme variant to the theming system.

## 1. Create the QML File

Add a new file under `Themes/variants/` named after your variant (e.g., `MyTheme.qml`).

## 2. Update CMakeLists

In `Themes/CMakeLists.txt`:

- Remove `MyTheme.qml` from `qt_add_qml_module(QML_FILES ...)`
- Add it instead to the `qml_files` set.

This ensures consistency within the CMakeLists file.

## 3. Define the Variant

Inside `MyTheme.qml`, inherit from `BaseTheme` and attach the required token families:

```qml
import ".."
import "../tokens"

BaseTheme {
    colors: ColorTokens { }

    typography: TypographyTokens { }

    spacing: SpacingTokens { }

    radius: RadiusTokens { }

    borders: BorderTokens { }

    elevation: ElevationTokens { }

    opacity: OpacityTokens { }

    icons: IconTokens { }

    effects: EffectTokens { }
}
```

### Overriding Values

Override only what you need. For example:

```qml
colors: ColorTokens {
    readonly property color text: "#202124"
    readonly property color textMuted: "#5F6368"
}
```

All other values that are not overridden use the default values.

## 4. Register in `Themes.qml`

Add your new variant to the `Variants` enum:

```qml
enum Variants {
    ...
    MyTheme   // <— new variant
}
```

## 5. Update Theme Loader

In `Theme.qml`, extend the switch inside `setTheme()`:

```qml
let url = ""
switch (variant) {
case Themes.MyTheme:
    url = Qt.resolvedUrl("variants/MyTheme.qml")
    break
...
}
```

## 6. Switch at Runtime

Import the `App.Themes` module and call `setTheme()`:

```qml
import App.Themes 1.0

Button {
    text: "Switch to MyTheme"
    onClicked: Theme.setTheme(Themes.MyTheme)
}
```
