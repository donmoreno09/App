/*!
    \qmltype OpacityTokens
    \inqmlmodule App.Themes
    \brief Defines a standard opacity scale for consistent transparency across the UI.

    This token family standardizes opacity values in fixed 5%
    increments (0.00–1.00), providing a single source of truth
    for transparency across the application.

    It exists to prevent scattering arbitrary numeric values
    throughout the codebase, to give designers and developers
    predictable steps they can reference, and to allow semantic
    roles to be themed without changing component logic.

    While Qt allows setting opacity directly on items and colors,
    having this token family makes it easier to maintain visual
    consistency and adapt values per theme variant.
*/

import QtQuick 2.15

QtObject {
    // Core scale
    readonly property real o0:    0.00
    readonly property real o5:    0.05
    readonly property real o10:   0.10
    readonly property real o15:   0.15
    readonly property real o20:   0.20
    readonly property real o25:   0.25
    readonly property real o30:   0.30
    readonly property real o35:   0.35
    readonly property real o40:   0.40
    readonly property real o45:   0.45
    readonly property real o50:   0.50
    readonly property real o55:   0.55
    readonly property real o60:   0.60
    readonly property real o65:   0.65
    readonly property real o70:   0.70
    readonly property real o75:   0.75
    readonly property real o80:   0.80
    readonly property real o85:   0.85
    readonly property real o90:   0.90
    readonly property real o95:   0.95
    readonly property real o100:  1.00

    // Semantic role mappings
    // (empty for now, feel free to add when needed)
}
