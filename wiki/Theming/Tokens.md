[[_TOC_]]

The `tokens/` folder defines the **design tokens** of the theming system.

Each token family encapsulates a single type of design decision (e.g., colors, spacing, typography). Together, these families form the **contract** that every theme variant must implement.

## Purpose

- Centralize all reusable **visual values**.
- Prevent "magic numbers" or one-off styles in components.
- Make it easy to extend the system by adding new families without breaking existing variants.

Each family is implemented as its own QML file (e.g., `ColorTokens.qml`) containing `readonly property` definitions.

## Token Families

Current families include:

- **ColorTokens.qml**: All color roles (surface, text, primary, status, overlay, etc.).
- **TypographyTokens.qml**: Font sizes, weights, line-height, decoration.
- **SpacingTokens.qml**: Spacing scale (sm, md, lg, etc.).
- **RadiusTokens.qml**: Border radius sizes (sm, md, lg, full).
- **BorderTokens.qml**: Stroke widths and outline values.
- **ElevationTokens.qml**: Z levels.
- **OpacityTokens.qml**: Transparency presets.
- **IconTokens.qml**: Icon sizes.
- **EffectTokens.qml**: Filters, blurs, etc..

## Extending

Check [Creating A Token Family](Creating-A-Token-Family.md) for creating new token families.
