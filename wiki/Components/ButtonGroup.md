# ButtonGroup Component Documentation

## Table of Contents
1. [Overview](#overview)
2. [Decision Process](#decision-process)
3. [Why Qt's Built-in ButtonGroup](#why-qts-built-in-buttongroup)
4. [Basic Usage](#basic-usage)
5. [Selection Modes](#selection-modes)
6. [Integration with UI.Button](#integration-with-uibutton)
7. [Complete Examples](#complete-examples)
8. [Best Practices](#best-practices)
9. [Common Patterns](#common-patterns)
10. [Troubleshooting](#troubleshooting)

## Overview

Our team has chosen to use Qt's built-in `ButtonGroup` component from `QtQuick.Controls` for managing button selection behavior across the application. This component provides reliable, platform-standard button grouping functionality without requiring custom implementation.

### Key Benefits
- **Proven reliability**: Battle-tested Qt component
- **Platform compliance**: Follows native OS button group patterns
- **Zero maintenance**: No custom selection logic to debug or maintain
- **Maximum flexibility**: Works with any button type and layout
- **Performance optimized**: Native Qt implementation

## Decision Process

### Analysis Conducted
1. **Component Research**: Analyzed what button groups are and their common use cases
2. **Material UI Evaluation**: Studied Material UI patterns for UX best practices
3. **Architecture Comparison**: Evaluated custom vs. built-in component approaches
4. **Implementation Complexity**: Assessed maintenance burden of custom solutions

### Approaches Considered

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **Custom Container Component** | Figma-specific styling, Integrated visual design | Limited flexibility, Custom logic to maintain, Only works for toolbar cases | ❌ Rejected |
| **Model-driven Component** | Declarative API, Automatic button creation | Less flexible, Recreates Button functionality, Complex for mixed content | ❌ Rejected |
| **Qt's Built-in ButtonGroup** | Proven reliability, Maximum flexibility, Zero maintenance, Platform standard | Requires manual container styling when needed | ✅ **Chosen** |

### Key Decision Factors
- **Flexibility**: Need to support various layouts (horizontal, vertical, grid, scattered)
- **Maintenance**: Prefer zero custom selection logic to debug
- **Standards**: Leverage Qt's proven, platform-compliant implementations
- **Simplicity**: Minimal API that developers can easily understand

## Why Qt's Built-in ButtonGroup

### Technical Advantages
- **Non-visual component**: Pure selection logic without imposed visual constraints
- **Automatic state management**: Handles exclusive/multiple selection automatically
- **Event system**: Provides reliable signals for selection changes
- **Dynamic management**: Add/remove buttons at runtime without issues
- **Memory efficient**: Optimized native implementation

### Business Benefits
- **Faster development**: No custom component development time
- **Lower risk**: Uses Qt's tested, stable component
- **Better maintainability**: Less code to maintain and debug
- **Team familiarity**: Standard Qt patterns that all developers know

## Basic Usage

### Import Required
```qml
import QtQuick.Controls 6.8
```

### Basic ButtonGroup Declaration
```qml
ButtonGroup {
    id: myButtonGroup
    exclusive: true  // or false for multiple selection
}
```

### Attaching Buttons
```qml
UI.Button {
    text: "Option 1"
    checkable: true
    ButtonGroup.group: myButtonGroup
}
```

## Selection Modes

### Exclusive Selection (Radio Button Behavior)
Only one button can be selected at a time.

```qml
ButtonGroup {
    id: exclusiveGroup
    exclusive: true
}

UI.Button {
    text: "Option A"
    checkable: true
    checked: true  // Initially selected
    ButtonGroup.group: exclusiveGroup
}

UI.Button {
    text: "Option B"
    checkable: true
    ButtonGroup.group: exclusiveGroup
}
```

### Multiple Selection (Checkbox Behavior)
Multiple buttons can be selected simultaneously.

```qml
ButtonGroup {
    id: multipleGroup
    exclusive: false
}

UI.Button {
    text: "Feature 1"
    checkable: true
    checked: true
    ButtonGroup.group: multipleGroup
}

UI.Button {
    text: "Feature 2"
    checkable: true
    ButtonGroup.group: multipleGroup
}
```

## Integration with UI.Button

### Icon Buttons with Selection
```qml
ButtonGroup {
    id: toolbarGroup
    exclusive: true
}

UI.Button {
    icon.source: "qrc:/App/assets/icons/map.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    display: AbstractButton.IconOnly
    variant: "ghost"
    checkable: true
    checked: true  // Initially selected
    ButtonGroup.group: toolbarGroup
    
    implicitWidth: Theme.spacing.s10
    implicitHeight: Theme.spacing.s10
    
    ToolTip {
        visible: parent.hovered
        text: "Map View"
        delay: 800
    }
}

UI.Button {
    icon.source: "qrc:/App/assets/icons/home.svg"
    icon.width: Theme.icons.sizeLg
    icon.height: Theme.icons.sizeLg
    display: AbstractButton.IconOnly
    variant: "ghost"
    checkable: true
    ButtonGroup.group: toolbarGroup
    
    implicitWidth: Theme.spacing.s10
    implicitHeight: Theme.spacing.s10
    
    ToolTip {
        visible: parent.hovered
        text: "Home View"
        delay: 800
    }
}
```

### Text Buttons with Selection
```qml
ButtonGroup {
    id: viewModeGroup
    exclusive: true
}

UI.Button {
    text: "List View"
    variant: "secondary"
    checkable: true
    checked: true
    ButtonGroup.group: viewModeGroup
}

UI.Button {
    text: "Grid View"
    variant: "secondary"
    checkable: true
    ButtonGroup.group: viewModeGroup
}

UI.Button {
    text: "Detail View"
    variant: "secondary"
    checkable: true
    ButtonGroup.group: viewModeGroup
}
```

## Complete Examples

### Example 1: Navigation Toolbar (Exclusive Selection)
```qml
import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    // Navigation ButtonGroup - only one view can be active
    ButtonGroup {
        id: navigationGroup
        exclusive: true
        
        onCheckedButtonChanged: {
            if (checkedButton) {
                console.log("Navigation changed to:", checkedButton.tooltip)
            }
        }
    }
    
    // Visual container for toolbar styling
    Rectangle {
        width: buttonRow.width + (Theme.spacing.s2 * 2)
        height: buttonRow.height + (Theme.spacing.s2 * 2)
        color: Theme.colors.surface
        radius: Theme.radius.lg
        border.width: Theme.borders.b1
        border.color: Qt.lighter(Theme.colors.surface, 1.2)
        
        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: Theme.spacing.s1
            
            UI.Button {
                icon.source: "qrc:/App/assets/icons/map.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: "ghost"
                checkable: true
                checked: true  // Initially selected
                ButtonGroup.group: navigationGroup
                
                property string tooltip: "Map View"
                implicitWidth: Theme.spacing.s10
                implicitHeight: Theme.spacing.s10
                
                ToolTip {
                    visible: parent.hovered
                    text: parent.tooltip
                    delay: 800
                }
            }
            
            UI.Button {
                icon.source: "qrc:/App/assets/icons/home.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: "ghost"
                checkable: true
                ButtonGroup.group: navigationGroup
                
                property string tooltip: "Home Base"
                implicitWidth: Theme.spacing.s10
                implicitHeight: Theme.spacing.s10
                
                ToolTip {
                    visible: parent.hovered
                    text: parent.tooltip
                    delay: 800
                }
            }
        }
    }
}
```

### Example 2: Feature Toggles (Multiple Selection)
```qml
import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

Column {
    spacing: Theme.spacing.s4
    
    Text {
        text: "Feature Settings"
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightSemibold
        color: Theme.colors.text
    }
    
    // Feature toggles - multiple can be active
    ButtonGroup {
        id: featureGroup
        exclusive: false
        
        onClicked: function(button) {
            console.log("Feature toggled:", button.text, button.checked ? "ON" : "OFF")
        }
    }
    
    UI.Button {
        text: "Auto-save"
        variant: "secondary"
        checkable: true
        checked: true  // Initially enabled
        ButtonGroup.group: featureGroup
    }
    
    UI.Button {
        text: "Notifications"
        variant: "secondary"
        checkable: true
        ButtonGroup.group: featureGroup
    }
    
    UI.Button {
        text: "Dark Mode"
        variant: "secondary"
        checkable: true
        checked: true  // Initially enabled
        ButtonGroup.group: featureGroup
    }
}
```

### Example 3: Multiple ButtonGroups
```qml
import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

Column {
    spacing: Theme.spacing.s6
    
    // Group 1: View Mode (Exclusive)
    ColumnLayout {
        spacing: Theme.spacing.s2
        
        Text {
            text: "View Mode"
            font.pixelSize: Theme.typography.sizeLg
            color: Theme.colors.text
        }
        
        ButtonGroup {
            id: viewGroup
            exclusive: true
        }
        
        Row {
            spacing: Theme.spacing.s2
            
            UI.Button {
                text: "List"
                variant: "secondary"
                size: "sm"
                checkable: true
                checked: true
                ButtonGroup.group: viewGroup
            }
            
            UI.Button {
                text: "Grid"
                variant: "secondary" 
                size: "sm"
                checkable: true
                ButtonGroup.group: viewGroup
            }
            
            UI.Button {
                text: "Details"
                variant: "secondary"
                size: "sm"
                checkable: true
                ButtonGroup.group: viewGroup
            }
        }
    }
    
    // Group 2: Tools (Exclusive)
    ColumnLayout {
        spacing: Theme.spacing.s2
        
        Text {
            text: "Active Tool"
            font.pixelSize: Theme.typography.sizeLg
            color: Theme.colors.text
        }
        
        ButtonGroup {
            id: toolGroup
            exclusive: true
        }
        
        Row {
            spacing: Theme.spacing.s1
            
            UI.Button {
                icon.source: "qrc:/App/assets/icons/send.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: "ghost"
                checkable: true
                ButtonGroup.group: toolGroup
                implicitWidth: Theme.spacing.s10
                implicitHeight: Theme.spacing.s10
            }
            
            UI.Button {
                icon.source: "qrc:/App/assets/icons/plus.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: "ghost"
                checkable: true
                checked: true  // Initially selected
                ButtonGroup.group: toolGroup
                implicitWidth: Theme.spacing.s10
                implicitHeight: Theme.spacing.s10
            }
            
            UI.Button {
                icon.source: "qrc:/App/assets/icons/minus.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: "ghost"
                checkable: true
                ButtonGroup.group: toolGroup
                implicitWidth: Theme.spacing.s10
                implicitHeight: Theme.spacing.s10
            }
        }
    }
}
```

## Best Practices

### 1. Always Set `checkable: true`
Buttons must be checkable to work with ButtonGroup selection.

```qml
UI.Button {
    text: "Option"
    checkable: true  // ← Required for selection behavior
    ButtonGroup.group: myGroup
}
```

### 2. Use Meaningful Group IDs
```qml
// ✅ Good - descriptive names
ButtonGroup { id: navigationModeGroup }
ButtonGroup { id: sortOrderGroup }

// ❌ Avoid - generic names
ButtonGroup { id: group1 }
ButtonGroup { id: buttonGroup }
```

### 3. Handle Selection Events
```qml
ButtonGroup {
    id: myGroup
    exclusive: true
    
    onCheckedButtonChanged: {
        if (checkedButton) {
            // Handle selection change
            handleSelectionChange(checkedButton)
        }
    }
    
    onClicked: function(button) {
        // Handle button click (fires for all buttons)
        console.log("Button clicked:", button.text)
    }
}
```

### 4. Initial Selection for Exclusive Groups
Always set an initial selection for exclusive groups.

```qml
ButtonGroup {
    id: exclusiveGroup
    exclusive: true
}

UI.Button {
    text: "Default Option"
    checkable: true
    checked: true  // ← Set initial selection
    ButtonGroup.group: exclusiveGroup
}
```

### 5. Visual Container When Needed
Add visual containers only when the design requires it.

```qml
// Visual container for toolbar-style groups
Rectangle {
    color: Theme.colors.surface
    radius: Theme.radius.lg
    // ButtonGroup content here
}

// No container for scattered form elements
// Just use ButtonGroup directly
```

## Common Patterns

### Pattern 1: Toolbar with Visual Container
```qml
Rectangle {
    // Figma-style container
    color: Theme.colors.surface
    radius: Theme.radius.lg
    border.width: Theme.borders.b1
    
    Row {
        anchors.centerIn: parent
        spacing: Theme.spacing.s1
        
        // Buttons here with ButtonGroup
    }
}
```

### Pattern 2: Form Radio Buttons
```qml
ButtonGroup {
    id: formGroup
    exclusive: true
}

Column {
    // Scattered throughout form
    UI.Button {
        text: "Option A"
        checkable: true
        ButtonGroup.group: formGroup
    }
    
    // Other form elements...
    
    UI.Button {
        text: "Option B" 
        checkable: true
        ButtonGroup.group: formGroup
    }
}
```

### Pattern 3: Dynamic Button Management
```qml
ButtonGroup {
    id: dynamicGroup
    
    function addNewButton(buttonText) {
        const button = buttonComponent.createObject(container)
        button.text = buttonText
        button.ButtonGroup.group = dynamicGroup
    }
}

Component {
    id: buttonComponent
    UI.Button {
        checkable: true
        variant: "secondary"
    }
}
```

## Troubleshooting

### Issue 1: Buttons Not Responding to Selection
**Symptom**: Clicking buttons doesn't change selection state.
**Solution**: Ensure buttons have `checkable: true`.

```qml
// ❌ Won't work
UI.Button {
    text: "Option"
    ButtonGroup.group: myGroup  // Missing checkable
}

// ✅ Correct
UI.Button {
    text: "Option"
    checkable: true  // ← Required
    ButtonGroup.group: myGroup
}
```

### Issue 2: Multiple Buttons Selected in Exclusive Group
**Symptom**: More than one button is checked in an exclusive group.
**Solution**: Verify `exclusive: true` is set and buttons are properly attached.

```qml
ButtonGroup {
    id: myGroup
    exclusive: true  // ← Ensure this is set
}

// Verify all buttons use ButtonGroup.group, not addButton() mixing
```

### Issue 3: No Initial Selection in Exclusive Group
**Symptom**: No button is selected initially in a radio group.
**Solution**: Set `checked: true` on the default button.

```qml
UI.Button {
    text: "Default"
    checkable: true
    checked: true  // ← Set initial selection
    ButtonGroup.group: exclusiveGroup
}
```

### Issue 4: Selection Events Not Firing
**Symptom**: `onCheckedButtonChanged` or `onClicked` not triggered.
**Solution**: Check button attachment and event handler syntax.

```qml
ButtonGroup {
    id: myGroup
    
    // ✅ Correct event handler
    onCheckedButtonChanged: {
        console.log("Selection changed")
    }
    
    // ✅ Correct click handler
    onClicked: function(button) {
        console.log("Clicked:", button.text)
    }
}
```

---

## Summary

Qt's built-in ButtonGroup provides robust, reliable button grouping functionality that meets all our application needs. By leveraging this proven component, we achieve:

- **Reliability**: Battle-tested Qt implementation
- **Flexibility**: Works with any layout and button configuration  
- **Maintainability**: Zero custom selection logic to maintain
- **Standards Compliance**: Platform-native button group behavior
- **Developer Productivity**: Familiar Qt patterns and minimal learning curve

This approach allows us to focus on application logic and user experience rather than maintaining custom selection management code.
