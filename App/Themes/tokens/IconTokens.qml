/*!
    \qmltype Icons
    \inqmlmodule App.Themes
    \brief Defines standard size tokens for icons.

    The \c {Icons} token family centralizes sizing values for icons across the UI.

    \note Only \b {sizes} are included in this family. Other aspects such as color,
    opacity, stroke widths, and mirroring are excluded by design because they are
    already covered by other token families (\c {Colors}, \c {Opacity}) or belong to
    component-level logic. This avoids duplication and ensures each token family
    has a clear and minimal scope.

    Decision rationale:
    - Icon colors are bound to \c {Theme.colors.*} tokens.
    - Icon opacity is bound to \c {Theme.opacity.*} tokens.
    - Variants (filled/outlined/duotone) and rendering details (e.g. prefer SVG over PNG)
      are component responsibilities, not design tokens.
    - Sizing, however, benefits from centralization to keep layout scales coherent and
      prevent arbitrary pixel values across the codebase.

    Usage:
    \code
    // Button with 24 dp (default) icon
    Button {
        icon.source: "qrc:/icons/add.svg"
        icon.width: Theme.icons.sizeLg
        icon.height: Theme.icons.sizeLg
    }
    \endcode
*/

import QtQuick 2.15

QtObject {
    // Sizes
    readonly property int sizeXs:   12
    readonly property int sizeSm:   16
    readonly property int sizeMd:   20
    readonly property int sizeLg:   24
    readonly property int sizeXl:   32
    readonly property int size2Xl:  40
    readonly property int size3Xl:  48

    // Semantic role mappings
    // (empty for now, feel free to add when needed)
    // Example: readonly property int button: sizeLg
}
