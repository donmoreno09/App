Semantic z-index scale for component stacking order. Defined in `tokens/ElevationTokens.qml` and exposed via `Theme.elevation`.

[[_TOC_]]

## Example File

```qml
// tokens/ElevationTokens.qml

QtObject {
    // Core bands
    readonly property int z0:   0   // Base
    readonly property int z10: 10   // Raised
    readonly property int z20: 20   // Panels
    readonly property int z30: 30   // Popups
    readonly property int z40: 40   // Modals
    readonly property int z50: 50   // Toasts
    readonly property int z100: 100 // System / critical
    // ...
    
    // Semantic mappings
    readonly property int base:   z0
    readonly property int raised: z10
    readonly property int panel:  z20
    readonly property int popup:  z30
    readonly property int modal:  z40
    readonly property int toast:  z50
    readonly property int system: z100
}
```

## Example Usage

```qml
// Base layer
Rectangle {
    z: Theme.elevation.base
}

// Popup menu
Rectangle {
    z: Theme.elevation.popup
}

// Critical system blocker
Rectangle {
    z: Theme.elevation.system
}
```

## Notes

- Values are **integers** and apply only within the same parent.
- Negative bands (`nz10`, `nz20`) are available for backgrounds/underlays.
- Use **semantic roles** (`popup`, `modal`, `toast`) instead of raw numbers to keep consistency.

## Extend it

Add more bands or new semantic roles (e.g., `tooltip`, `fab`) as needed. Variants inherit automatically; override only if you want a variant-specific stacking scheme.
