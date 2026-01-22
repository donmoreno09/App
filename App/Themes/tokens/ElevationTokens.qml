/*!
    \qmltype ElevationTokens
    \inqmlmodule App.Themes
    \brief Semantic z-index scale for component stacking order.

    The elevation token family defines a small, semantic z-index scale
    (Tailwind-inspired) for controlling the stacking order of UI elements.
    It ensures consistent layering across the application and avoids
    arbitrary z-values.

    All values are integers and apply only to items sharing the same parent.
    For predictable global layering, place popups, modals, and overlays
    in a dedicated overlay host so these tokens apply uniformly.

    Use for:
    - \c {Item.z} to control stacking within a parent or overlay host.
    - Assigning semantic roles (e.g., popup, modal) instead of raw numbers.

    Example usage:
    \code
    Rectangle {
        z: Theme.elevation.modal
    }
    \endcode
*/

import QtQuick 2.15

QtObject {
    // Core bands (negative to high)
    // For more specific use-case, check the system role mappings below.
    readonly property int nz20: -20   // Background media (underlays)
    readonly property int nz10: -10   // Background decorations
    readonly property int z0:    0    // Base content
    readonly property int z10:  10    // Raised content (cards, sticky headers)
    readonly property int z20:  20    // Panels, open drawers
    readonly property int z30:  30    // Popovers, dropdowns, context menus
    readonly property int z40:  40    // Modals, sheets, overlays
    readonly property int z50:  50    // Toasts, global loaders/spinners
    readonly property int z60:  60    // Developer overlays, coach-marks (guide)

    // Highest priority layer in the application UI
    // Should be used for but not mandatory:
    // - Critical security warnings (e.g., session expired)
    // - Fatal error banners (e.g., connection lost)
    // - Maintenance locks or downtime notices
    // - Fullscreen blockers
    // Use rarely; reserved for truly blocking content.
    readonly property int z100: 100

    // Semantic role mappings
    readonly property int background: nz10
    readonly property int base:       z0
    readonly property int raised:     z10
    readonly property int panel:      z20
    readonly property int popup:      z30
    readonly property int modal:      z40
    readonly property int toast:      z50
    readonly property int system:     z100

    readonly property int layerShapes: 3
    readonly property int layerTracks: 5
}
