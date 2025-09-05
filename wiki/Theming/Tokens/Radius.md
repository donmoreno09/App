Corner radius scale and helpers for rounded shapes (uniform, per‑corner, pill, circle). Defined in `tokens/RadiusTokens.qml` and exposed via `Theme.radius`.

[[_TOC_]]

## Example File

```qml
// tokens/RadiusTokens.qml

QtObject {
    // Core scale (dp)
    readonly property int none: 0
    readonly property int xs:   2
    readonly property int sm:   4
    readonly property int md:   8
    readonly property int lg:   12
    readonly property int xl:   16
    readonly property int x2l:  24
    readonly property int x3l:  32

    // Specials
    function full(height) {
        // Pill radius: height / 2
        return Math.max(0, Math.floor(height / 2))
    }

    function circle(width, height) {
        // Perfect circle: min(w, h) / 2
        return Math.max(0, Math.floor(Math.min(width, height) / 2))
    }
}
```

## Example Usage

```qml
// Uniform
Rectangle {
    radius: Theme.radius.md
}

// Per-corner (Qt 6.7+)
Rectangle {
    topLeftRadius: Theme.radius.lg
    topRightRadius: Theme.radius.lg
    bottomLeftRadius: Theme.radius.none
    bottomRightRadius: Theme.radius.none
}

// Pill
Rectangle {
    width: 160; height: 32
    radius: Theme.radius.full(height) // 16
}

// Circle avatar
Rectangle {
    width: 64; height: 64
    radius: Theme.radius.circle(width, height) // 32
    clip: true // needed to mask children
}
```

## Notes

- **Clipping:** Rounded `Rectangle` does **not** clip children by default; set `clip: true` when content must not overflow.
- **Per‑corner radii:** Available on Qt 6.7+ (`topLeftRadius`, etc.).
- **Scale rhythm:** Values follow a 4px rhythm; prefer tokens over ad‑hoc numbers.

## Extend it

Add more steps as new `readonly property int`, or add helpers. Variants inherit automatically; override only if a variant needs different values.
