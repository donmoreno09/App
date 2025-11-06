# ComboBox Component Documentation

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Properties](#properties)
- [Signals](#signals)
- [Usage Examples](#usage-examples)
- [Styling](#styling)
- [Accessibility](#accessibility)
- [Best Practices](#best-practices)

---

## Overview

The `ComboBox` component is a custom dropdown selection control built on top of Qt Quick Controls 6.8's native ComboBox. It provides a consistent, themed selection interface that integrates seamlessly with the application's design system.

### Why This Approach?

**Wrapping Native ComboBox Instead of Building from Scratch:**
- ✅ **Leverages Qt's proven implementation** - Keyboard navigation, accessibility, and complex interaction logic are already handled
- ✅ **Maintains consistency** - Follows the same pattern as other components (`Input`, `TextArea`, `Button`)
- ✅ **Reduces maintenance burden** - Qt handles edge cases and platform-specific behaviors
- ✅ **Easier to extend** - Custom styling while keeping native functionality intact


## Features

- 🎨 **Themed styling** - Automatically uses application theme colors and spacing
- 📱 **Responsive states** - Hover, focus, pressed, and disabled states with smooth transitions
- ⌨️ **Keyboard navigation** - Full keyboard support (Arrow keys, Enter, Escape, Tab)
- ♿ **Accessible** - Built on Qt's accessible components
- 📜 **Smart scrolling** - Automatically displays scrollbar when more than 5 items
- 🎯 **Focus management** - Visual focus indicators for keyboard navigation

---

## Component Structure

```
ComboBox.qml
├── Label (optional)
└── QtQuick.Controls.ComboBox
    ├── contentItem (RowLayout)
    │   ├── Text (display text)
    │   └── Image (chevron icon)
    ├── background (Rectangle with bottom border)
    └── popup (Popup)
        └── ListView
            └── ItemDelegate (for each item)
```

---

## Properties

### Public Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Whether the ComboBox is enabled |
| `labelText` | `string` | `""` | Optional label displayed above the ComboBox |
| `currentIndex` | `int` | `0` | Index of the currently selected item |
| `currentValue` | `var` | - | Value of the currently selected item |
| `displayText` | `string` | - | Text displayed in the ComboBox |
| `model` | `var` | `[]` | The data model (array of strings) |
| `comboBox` | `ComboBox` | - | Direct access to the underlying Qt ComboBox |

### Aliases

The component exposes the native ComboBox through the `comboBox` alias, allowing access to all native properties if needed:

```qml
UI.ComboBox {
    id: myCombo
    
    // Access native properties
    comboBox.acceptableInput
    comboBox.flat
    // etc.
}
```

---

## Signals

### `activated(int index)`

Emitted when an item is selected (either by clicking or keyboard).

**Parameters:**
- `index` - The index of the selected item

**Example:**
```qml
UI.ComboBox {
    model: ["Apple", "Banana", "Cherry"]
    
    onActivated: function(index) {
        console.log("Selected index:", index)
        console.log("Selected text:", displayText)
    }
}
```

---

## Usage Examples

### Basic ComboBox

```qml
import App.Components 1.0 as UI

UI.ComboBox {
    Layout.fillWidth: true
    labelText: "Select Option"
    model: ["Option 1", "Option 2", "Option 3"]
}
```

### Without Label

```qml
UI.ComboBox {
    Layout.fillWidth: true
    model: ["Red", "Green", "Blue"]
}
```

### With Preselected Value

```qml
UI.ComboBox {
    Layout.fillWidth: true
    labelText: "Month"
    model: ["January", "February", "March", "April"]
    currentIndex: 2  // Preselect "March"
}
```

### Disabled State

```qml
UI.ComboBox {
    Layout.fillWidth: true
    enabled: false
    labelText: "Disabled"
    model: ["Cannot", "Select", "These"]
    currentIndex: 1
}
```

### Long List with Automatic Scrolling

```qml
UI.ComboBox {
    Layout.fillWidth: true
    labelText: "Countries"
    model: [
        "Afghanistan", "Albania", "Algeria", 
        "Andorra", "Angola", "Argentina",
        // ... more items
    ]
    // Automatically shows scrollbar when > 5 items
}
```

### Handling Selection Changes

```qml
UI.ComboBox {
    id: countrySelector
    labelText: "Select Country"
    model: ["Italy", "France", "Germany", "Spain"]
    
    onActivated: function(index) {
        console.log("User selected:", displayText)
        updateMap(displayText)
    }
}

function updateMap(country) {
    // Your logic here
}
```

### Programmatic Control

```qml
RowLayout {
    UI.ComboBox {
        id: myCombo
        Layout.fillWidth: true
        model: ["First", "Second", "Third", "Fourth"]
    }
    
    UI.Button {
        text: "Reset"
        onClicked: myCombo.currentIndex = 0
    }
}
```

### Dynamic Model

```qml
UI.ComboBox {
    id: dynamicCombo
    labelText: "Dynamic Options"
    model: backendModel.availableOptions
    
    Connections {
        target: backendModel
        function onOptionsChanged() {
            // Model updates automatically
        }
    }
}
```

---

## Styling

### Theme Integration

The ComboBox automatically uses theme values for consistent appearance:

```qml
// Colors
Theme.colors.text           // Normal text
Theme.colors.textMuted      // Disabled text
Theme.colors.surface        // Hover/pressed background
Theme.colors.primary500     // Focus indicator
Theme.colors.grey300        // Default border
Theme.colors.grey400        // Hover border

// Spacing
Theme.spacing.s2            // Internal padding
Theme.spacing.s3            // Left/right content padding
Theme.spacing.s10           // Item height
Theme.spacing.s12           // ComboBox height

// Effects
Theme.radius.sm             // Corner radius
Theme.icons.sizeSm          // Chevron size
```

### Visual States

| State | Visual Feedback |
|-------|----------------|
| **Default** | Transparent background, grey bottom border |
| **Hover** | Light surface background, darker border |
| **Focus** | Primary color bottom border, outline rect |
| **Pressed** | Darker surface background |
| **Disabled** | Muted colors, reduced opacity |

### Popup Behavior

- **Maximum visible items:** 5
- **Position:** Always below the ComboBox
- **Scroll:** Automatic when > 5 items
- **Animation:** 150ms fade in/out with cubic easing

---

## Accessibility

The ComboBox is built on Qt Quick Controls' accessible foundation:

- ✅ **Screen reader support** - Announces label and current value
- ✅ **Keyboard navigation:**
  - `Tab`/`Shift+Tab` - Focus navigation
  - `Space`/`Enter` - Open popup
  - `Arrow Up/Down` - Navigate items
  - `Escape` - Close popup
- ✅ **Focus indicator** - Visual outline when focused via keyboard
- ✅ **High contrast** - Works with system high contrast modes

---

## Best Practices

### ✅ Do

```qml
// Use descriptive labels
UI.ComboBox {
    labelText: "Departure Airport"
    model: airportList
}

// Handle selection changes
onActivated: function(index) {
    validateForm()
}

// Provide reasonable default
currentIndex: 0
```

### ❌ Don't

```qml
// Don't use without a label in forms
UI.ComboBox {
    model: ["Option 1", "Option 2"]  // What does this select?
}

// Don't use huge models without filtering
UI.ComboBox {
    model: allCitiesInTheWorld  // 10,000+ items = bad UX
}

// Don't forget to handle errors
UI.ComboBox {
    model: backendData  // What if this is null/undefined?
}
```

### Model Size Recommendations

| Item Count | Recommendation |
|-----------|----------------|
| 1-10 | ✅ Ideal for ComboBox |
| 11-50 | ✅ Good, scrolling works well |
| 51-200 | ⚠️ Consider adding search/filter |
| 200+ | ❌ Use autocomplete or different UI pattern |

---

## Integration Notes

### File Location
```
App/Components/ComboBox.qml
```

### CMakeLists.txt Entry
```cmake
set(qml_files
    # ...
    ComboBox.qml
    # ...
)
```

### Import Statement
```qml
import App.Components 1.0 as UI
```
