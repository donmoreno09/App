# Switcher Component Documentation

## Table of Contents
1. [Overview](#overview)
2. [Design Approach](#design-approach)
3. [Features](#features)
4. [API Reference](#api-reference)
5. [Usage Examples](#usage-examples)
6. [Accessibility](#accessibility)
7. [Styling](#styling)
8. [Integration Patterns](#integration-patterns)
9. [Best Practices](#best-practices)

## Overview

The Switcher component provides a clean, responsive navigation interface that allows users to switch between multiple related views or states within the same page. Built on top of the existing UI.Button component, it ensures consistency with the application's design system while providing specialized tab navigation functionality.

## Design Approach

### Why This Approach?

**Component Composition Over Reinvention**
- Leverages existing `UI.Button` component for consistency
- Inherits all button behaviors (hover, focus, animations) automatically
- Reduces code duplication and maintenance burden

**Responsive by Design**
- Uses `RowLayout` with `fillWidth` for automatic space distribution
- Graceful degradation with minimum width constraints
- Adapts to different screen sizes without breaking

**Accessibility First**
- Built-in keyboard navigation (arrow keys, tab focus)
- Screen reader support with proper role announcements
- Follows WCAG guidelines for interactive components

**Theme Integration**
- Seamless integration with existing Theme system
- Consistent spacing, colors, and typography
- Maintains design system coherence

## Features

- ✅ **Flexible Model-Based Configuration** - Define tabs with simple string arrays
- ✅ **Responsive Layout** - Automatically distributes space between tabs
- ✅ **Keyboard Navigation** - Full arrow key and tab key support
- ✅ **Screen Reader Accessible** - Proper announcements for assistive technology
- ✅ **Theme Integrated** - Uses existing design tokens and spacing
- ✅ **Component Composition** - Built on proven UI.Button foundation
- ✅ **Signal-Based Communication** - Clean event handling with `itemClicked`
- ✅ **Visual States** - Clear active/inactive button differentiation

## API Reference

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | `var` | `[]` | Array of strings defining the tab labels |
| `currentIndex` | `int` | `0` | Currently selected tab index |

### Signals

| Signal | Parameters | Description |
|--------|------------|-------------|
| `itemClicked` | `int index` | Emitted when a tab is clicked or activated via keyboard |

### Methods

*No public methods - component manages state internally*

### Accessibility Properties

| Property | Value | Description |
|----------|-------|-------------|
| `Accessible.role` | `Accessible.TabList` | Identifies component as tab navigation |
| `Accessible.name` | `"Navigation tabs"` | Screen reader announcement for container |

## Usage Examples

### Basic Usage

```qml
import App.Components 1.0 as UI

UI.Switcher {
    id: basicSwitcher
    model: ["Overview", "Details", "Settings"]
    
    onItemClicked: function(index) {
        console.log("Switched to:", model[index])
    }
}
```

### With Content Switching

```qml
ColumnLayout {
    UI.Switcher {
        id: switcher
        Layout.alignment: Qt.AlignHCenter
        model: ["Info", "Settings", "Data"]
    }
    
    StackLayout {
        Layout.fillWidth: true
        currentIndex: switcher.currentIndex
        
        // Info content
        Rectangle {
            color: Theme.colors.info100
            Text { text: "Information Panel" }
        }
        
        // Settings content  
        Rectangle {
            color: Theme.colors.primary100
            Column {
                UI.Toggle { leftLabel: "Enable feature" }
                UI.Toggle { leftLabel: "Auto-save" }
            }
        }
        
        // Data content
        Rectangle {
            color: Theme.colors.success100
            Text { text: "Data visualization here" }
        }
    }
}
```

### Programmatic Control

```qml
UI.Switcher {
    id: controlledSwitcher
    model: ["First", "Second", "Third"]
    currentIndex: 1  // Start on second tab
}

UI.Button {
    text: "Jump to Last Tab"
    onClicked: {
        controlledSwitcher.currentIndex = controlledSwitcher.model.length - 1
    }
}
```

### Two-Item Toggle Pattern

```qml
UI.Switcher {
    model: ["List View", "Grid View"]
    Layout.alignment: Qt.AlignHCenter
    
    onItemClicked: function(index) {
        viewMode = (index === 0) ? "list" : "grid"
    }
}
```

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| `Tab` | Focus the switcher component |
| `←` (Left Arrow) | Move to previous tab |
| `→` (Right Arrow) | Move to next tab |
| `Home` | *Future: Jump to first tab* |
| `End` | *Future: Jump to last tab* |

### Screen Reader Support

The component provides rich accessibility information:

- **Container**: Announced as *"Navigation tabs"*
- **Individual tabs**: Announced as *"Settings, 2 of 4"* (label + position)
- **State changes**: Screen readers announce when selection changes

### Testing Accessibility

**Windows**: Enable Narrator (Windows + Ctrl + Enter)
**macOS**: Enable VoiceOver (Cmd + F5)
**Testing**: Navigate to component and verify proper announcements

## Styling

### Theme Integration

The Switcher automatically uses your application's theme tokens:

```qml
// Spacing
spacing: Theme.spacing.s1
Layout.margins: 4

// Colors  
border.color: Theme.colors.secondary500
primary: Theme.colors.primary500

// Border radius
radius: Theme.radius.md (container)
radius: Theme.radius.sm (buttons)
```

### Visual States

- **Active Tab**: `variant: "primary"` (blue background, white text)
- **Inactive Tab**: `variant: "ghost"` (transparent background, normal text)
- **Focus State**: Automatic focus indication from UI.Button
- **Hover State**: Inherited from UI.Button component

### Customization

The component appearance is controlled by the Theme system:

```javascript
// To customize colors, modify your theme:
Theme.colors.primary500 = "#your-active-color"
Theme.colors.secondary500 = "#your-border-color"
```

## Integration Patterns

### With StackLayout (Recommended)

```qml
ColumnLayout {
    UI.Switcher { id: switcher; model: [...] }
    StackLayout { 
        currentIndex: switcher.currentIndex
        // Your content pages here
    }
}
```

### With State Machine

```qml
UI.Switcher {
    id: switcher
    model: ["State1", "State2", "State3"]
    onItemClicked: stateMachine.state = model[index]
}
```

### With Data Binding

```qml
UI.Switcher {
    model: dataModel.availableTabs
    currentIndex: dataModel.currentTabIndex
    onItemClicked: dataModel.setCurrentTab(index)
}
```

## Best Practices

### ✅ Do's

- **Keep labels short** - Aim for 1-2 words per tab
- **Use consistent terminology** - Match labels to content purpose
- **Limit tab count** - 2-6 tabs work best for usability
- **Bind to content** - Always show related content for active tab
- **Test keyboard navigation** - Ensure arrow keys work correctly

### ❌ Don'ts  

- **Don't use for primary navigation** - Use for content sections, not pages
- **Avoid long labels** - They cause responsive issues on small screens
- **Don't nest switchers** - Creates confusing navigation hierarchy
- **Don't skip accessibility testing** - Always verify screen reader compatibility
- **Don't modify internal structure** - Use provided API and properties

### Performance Tips

- **Lazy load content** - Use Loaders for heavy content in StackLayout
- **Minimize tab changes** - Frequent switching can impact performance
- **Use appropriate content containers** - StackLayout is usually optimal

### Responsive Considerations

```qml
// Good: Responsive layout
UI.Switcher {
    Layout.fillWidth: true
    model: ["Short", "Labels", "Work", "Best"]
}

// Avoid: Fixed widths that might not fit
UI.Switcher {
    width: 400  // Could overflow on small screens
    model: ["Very Long Labels", "That Might Not Fit"]
}
```

---

**Component Status**: ✅ Production Ready  
**Version**: 1.0  
**Last Updated**: January 2025
