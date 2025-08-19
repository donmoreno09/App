Standard opacity scale in fixed 5% steps for consistent transparency. Defined in `tokens/OpacityTokens.qml` and exposed via `Theme.opacity`.

[[_TOC_]]

## Example File

```qml
// tokens/OpacityTokens.qml

QtObject {
    // Core scale
    readonly property real o0:    0.00
    readonly property real o5:    0.05
    readonly property real o10:   0.10
    readonly property real o25:   0.25
    readonly property real o50:   0.50
    readonly property real o75:   0.75
    readonly property real o100:  1.00
    // ... (full 5% increments available)

    // Semantic role mappings (extend as needed)
}
```

## Example Usage

```qml
// Item transparency
Rectangle {
    opacity: Theme.opacity.o75
}

// Semi-transparent overlay
Rectangle {
    color: Theme.colors.overlay
    opacity: Theme.opacity.o50
}
```

## Notes

- Scale covers **0.00 → 1.00** in **5% increments**.
- Use tokens instead of raw numbers to keep transparency consistent across the UI.
- Semantic roles (e.g., `disabled`, `hoverOverlay`) can be added on top of the scale when needed.

## Extend it

Add semantic mappings inside `OpacityTokens.qml` for common cases (e.g., `disabled: o50`, `scrim: o75`) so designs can change per variant without touching component logic.
