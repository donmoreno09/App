/*!
    \qmltype ButtonGroup
    \inqmlmodule App.Components
    \brief A simple container component for grouping buttons with consistent styling and layout.

    ButtonGroup provides a styled container that groups Button components together, creating
    the toolbar appearance from your Figma designs. It's purely a visual container - you
    compose it with your existing Button components to create the exact layout you need.

    Key features:
    - Simple container with background and rounded corners matching Figma design
    - No complex logic - just provides consistent styling and layout
    - Works with any Button configuration (icons, text, variants, etc.)
    - Flexible content - you control exactly what buttons go inside
    - Theme-integrated styling using your existing design tokens

    Example usage (recreating your Figma toolbar):
    \code
    ButtonGroup {
        UI.Button {
            icon.source: "qrc:/App/assets/icons/map.svg"
            icon.width: Theme.icons.sizeLg
            icon.height: Theme.icons.sizeLg
            display: AbstractButton.IconOnly
            variant: "primary"
        }

        UI.Button {
            icon.source: "qrc:/App/assets/icons/home.svg"
            icon.width: Theme.icons.sizeLg
            icon.height: Theme.icons.sizeLg
            display: AbstractButton.IconOnly
            variant: "ghost"
        }
    }
    \endcode
*/

import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Rectangle {
    id: root

    // Container styling properties
    property color containerColor: Theme.colors.surface
    property int containerRadius: Theme.radius.lg
    property int spacing: Theme.spacing.s1
    property int padding: Theme.spacing.s2

    // Default container appearance matching your Figma design
    color: containerColor
    radius: containerRadius

    // Subtle border for definition
    border.width: Theme.borders.b1
    border.color: Qt.lighter(containerColor, 1.2)

    // Size to content with padding
    implicitWidth: buttonRow.implicitWidth + (padding * 2)
    implicitHeight: buttonRow.implicitHeight + (padding * 2)

    // Simple horizontal row layout for buttons
    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: root.spacing
    }

    // Default property - buttons get added to the row automatically
    default property alias children: buttonRow.children
}
