The theming system provides a **design-token–based layer** on top of Qt’s built-in styles. It ensures consistency, flexibility, and runtime switching between multiple theme variants.

## Goals

- Centralize **all visual decisions** (colors, typography, spacing, etc.) in tokens.  
- Enable **runtime switching** between themes.  
- Make extending the design system easy: add new token families, or define new variants.  
- Prevent scattered "magic numbers" or one-off styles in the codebase.

## Structure

```
Themes/
├─ Theme.qml         # Singleton: theme manager & variant switcher
├─ Themes.qml        # Singleton: enum of theme variants
├─ BaseTheme.qml     # Contract: defines required token families
├─ tokens/           # Each design token family as its own QML file
└─ variants/         # Theme implementations
```

> **Why "variants" and not "themes"?**  
> The collision is **not** with the folder name. It’s between **`Themes.qml` (which defines a QML type named `Themes`)** and any **`enum Themes { ... }`** you might declare.  
> QML would treat the file-defined type name `Themes` and an enum named `Themes` as conflicting identifiers.  
> We therefore declare `enum Variants { ... }` instead, and name the folder `variants/` to mirror that concept (concrete implementations of those variants).
