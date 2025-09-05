# IconButton Component Documentation

## Overview

The IconButton component is a specialized implementation of the base `Button` component, optimized for icon-only or icon-with-text display in user interfaces. This component leverages QtQuick Controls' built-in `Button` capabilities to provide a consistent, themeable, and accessible icon button solution.

## Design Approach

### Why This Approach?

Instead of creating a completely new component from scratch, we decided to extend and configure the existing `Button` component for several strategic reasons:

1. **Leverage Built-in Functionality**: QtQuick Controls `Button` already provides comprehensive interaction states, accessibility features, keyboard navigation, and focus management.

2. **Consistency with Design System**: By using the same base component, icon buttons automatically inherit all the theming, variants, and behavioral patterns established in our design system.

3. **Reduced Maintenance**: No need to reimplement interaction logic, state management, or accessibility features that are already well-tested in the base component.

4. **Future-Proof**: Any improvements or bug fixes to the base `Button` component automatically benefit icon button implementations.

5. **Familiar API**: Developers already familiar with the base `Button` can immediately understand and use icon buttons without learning new patterns.

## Built-in Button Properties Utilized

The IconButton implementation takes advantage of these key built-in `Button` properties:

### Icon Properties
- **`icon.source`**: Path to the icon file (SVG, PNG, etc.)
- **`icon.width`**: Icon width in device-independent pixels
- **`icon.height`**: Icon height in device-independent pixels  
- **`icon.color`**: Icon tint color (works with SVG `currentColor`)

### Display Control
- **`display`**: Controls how icon and text are arranged
  - `AbstractButton.IconOnly`: Shows only the icon
  - `AbstractButton.TextUnderIcon`: Icon above text (vertical layout)
  - `AbstractButton.TextBesideIcon`: Icon beside text (horizontal layout)

### State Management
- **`enabled`**: Controls interactive state
- **`hovered`**: Indicates mouse hover state
- **`pressed`**: Indicates pressed/clicked state
- **`focused`**: Indicates keyboard focus state
- **`activeFocus`**: True when component has active keyboard focus

### Sizing Properties
- **`implicitWidth`**: Preferred width (can be overridden for fixed sizing)
- **`implicitHeight`**: Preferred height (can be overridden for fixed sizing)
- **`padding`**: Internal spacing around content

### Base Component Integration
- **`variant`**: Design variant (primary, secondary, ghost, danger, success)
- **`size`**: Size variant (sm, md, lg) from the base Button component
- **`radius`**: Corner radius for custom styling

## Implementation Properties

### Core Configuration

```qml
UI.Button {
    // Display mode - controls icon/text layout
    display: AbstractButton.IconOnly              // Icon only
    display: AbstractButton.TextUnderIcon         // Icon above text
    display: AbstractButton.TextBesideIcon        // Icon beside text (default)
    
    // Icon configuration
    icon.source: "icons/example.svg"              // Icon file path
    icon.width: Theme.icons.sizeLg                // Icon width (24px)
    icon.height: Theme.icons.sizeLg               // Icon height (24px)
    icon.color: Theme.colors.primaryText          // Icon color
    
    // Optional text (when not IconOnly)
    text: "Label"                                 // Button text
    
    // Sizing (for fixed-size icon buttons)
    implicitWidth: Theme.spacing.s10              // 40px
    implicitHeight: Theme.spacing.s10             // 40px
}
```

### Theming Integration

All sizing and colors use the established design token system:

- **Icon Sizes**: `Theme.icons.sizeSm` (16px), `Theme.icons.sizeMd` (20px), `Theme.icons.sizeLg` (24px)
- **Button Sizes**: `Theme.spacing.s8` (32px), `Theme.spacing.s10` (40px), `Theme.spacing.s12` (48px)
- **Colors**: `Theme.colors.text`, `Theme.colors.primaryText`, `Theme.colors.danger`, etc.
- **Radius**: `Theme.radius.md`, `Theme.radius.lg`, etc.

### State-Based Styling

The component automatically handles visual states through the base Button's built-in logic:

```qml
readonly property color _currentIconColor: {
    switch (currentState) {
        case "disabled": return Theme.colors.textMuted
        case "pressed": return Theme.colors.primary
        case "hovered": return Theme.colors.text
        default: return Theme.colors.text
    }
}
```

## Usage Examples

### 1. Basic Icon-Only Button

```qml
UI.Button {
    variant: "primary"
    display: AbstractButton.IconOnly
    
    icon.source: "icons/home.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: Theme.colors.primaryText
    
    implicitWidth: Theme.spacing.s10
    implicitHeight: Theme.spacing.s10
    
    onClicked: console.log("Home clicked")
}
```

### 2. Icon Button with Text (Vertical Layout)

```qml
UI.Button {
    variant: "primary"
    display: AbstractButton.TextUnderIcon
    
    icon.source: "icons/clipboard.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: Theme.colors.primaryText
    
    text: "Mission"
    
    onClicked: console.log("Mission clicked")
}
```

### 3. Small Icon Button for Toolbars

```qml
UI.Button {
    variant: "ghost"
    size: "sm"
    display: AbstractButton.IconOnly
    
    icon.source: "icons/settings.svg"
    icon.width: Theme.icons.sizeSm
    icon.height: Theme.icons.sizeSm
    icon.color: Theme.colors.text
    
    implicitWidth: Theme.spacing.s8
    implicitHeight: Theme.spacing.s8
    
    onClicked: console.log("Settings clicked")
}
```

### 4. Toggle State Icon Button

```qml
UI.Button {
    id: toggleBtn
    variant: isActive ? "success" : "secondary"
    display: AbstractButton.IconOnly
    
    property bool isActive: false
    
    icon.source: isActive ? "icons/pause.svg" : "icons/play.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: isActive ? Theme.colors.primaryText : Theme.colors.text
    
    implicitWidth: Theme.spacing.s10
    implicitHeight: Theme.spacing.s10
    
    onClicked: isActive = !isActive
}
```

### 5. Icon Button with Tooltip

```qml
UI.Button {
    variant: "danger"
    display: AbstractButton.IconOnly
    
    icon.source: "icons/delete.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    icon.color: Theme.colors.primaryText
    
    implicitWidth: Theme.spacing.s10
    implicitHeight: Theme.spacing.s10
    
    onClicked: console.log("Delete clicked")
    
    ToolTip {
        visible: parent.hovered
        text: "Delete Item"
        delay: 800
    }
}
```

### 6. Navigation Rail Icons

```qml
Column {
    spacing: Theme.spacing.s3
    
    Repeater {
        model: [
            { icon: "icons/dashboard.svg", tooltip: "Dashboard", active: true },
            { icon: "icons/map.svg", tooltip: "Map", active: false },
            { icon: "icons/settings.svg", tooltip: "Settings", active: false }
        ]
        
        UI.Button {
            variant: modelData.active ? "primary" : "ghost"
            display: AbstractButton.IconOnly
            
            icon.source: modelData.icon
            icon.width: Theme.icons.sizeLg
            icon.height: Theme.icons.sizeLg
            icon.color: modelData.active ? Theme.colors.primaryText : Theme.colors.text
            
            implicitWidth: Theme.spacing.s10
            implicitHeight: Theme.spacing.s10
            
            onClicked: console.log(modelData.tooltip + " clicked")
            
            ToolTip {
                visible: parent.hovered
                text: modelData.tooltip
                delay: 800
            }
        }
    }
}
```

## Best Practices

### Sizing Guidelines
- **Small (32px)**: Inline actions, compact toolbars
- **Medium (36px)**: Standard toolbar buttons
- **Large (40px)**: Primary navigation, prominent actions

### Icon Guidelines
- Use SVG format for scalability and theming support
- Ensure icons use `currentColor` for proper theming
- Keep icon content simple and recognizable at small sizes
- Maintain consistent visual weight across icon sets

### Accessibility
- Always provide meaningful tooltips for icon-only buttons
- Ensure sufficient color contrast in all states
- Test keyboard navigation (Tab, Space, Enter)
- Consider providing text alternatives for screen readers

### Performance
- Prefer vector icons (SVG) over raster images (PNG/JPG)
- Cache frequently used icons
- Use the theme's icon size tokens for consistency

## Integration with Design System

The IconButton approach seamlessly integrates with the existing design system:

- **Variants**: Inherits all button variants (primary, secondary, ghost, danger, success)
- **Theming**: Uses design tokens for all sizing, colors, and spacing
- **States**: Leverages built-in interaction states and transitions
- **Accessibility**: Benefits from established focus management and keyboard navigation
- **Testing**: Can be tested using the same patterns as regular buttons

This documentation should serve as a comprehensive guide for developers implementing icon buttons using our design system approach.
