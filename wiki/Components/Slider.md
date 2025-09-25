# Slider Component

A highly customizable and optimized QML slider component that supports both single-value and range selection modes with solid and dotted track styles.

## Table of Contents

1. [Overview](#overview)
2. [Architecture & Design Philosophy](#architecture--design-philosophy)
3. [Features](#features)
4. [Component Structure](#component-structure)
5. [API Reference](#api-reference)
6. [Usage Examples](#usage-examples)
7. [Styling & Theming](#styling--theming)
8. [Best Practices](#best-practices)
9. [Performance Notes](#performance-notes)

## Overview

The Slider component is a versatile UI control that allows users to select single values or ranges within a specified boundary. Built on top of Qt Quick's native `Slider` and `RangeSlider` controls, it provides a consistent, themeable interface with advanced customization options.

**Key Benefits:**
- Unified API for both single and range selection
- Optimized micro-component architecture
- Consistent theming integration
- Minimal code duplication
- High performance rendering

## Architecture & Design Philosophy

### Micro-Component Approach

This component employs a micro-component architecture using QML's `component` keyword, which provides several advantages:

**Why Micro-Components?**
- **Code Reusability**: Shared logic between single and range sliders
- **Maintainability**: Single source of truth for styling and behavior
- **Performance**: No overhead of separate QML files
- **Encapsulation**: Self-contained logic with clear interfaces
- **Consistency**: Unified styling across all slider variants

### Component Breakdown

```qml
component ValueDisplay: RowLayout { ... }    // Handles value text formatting
component SliderTrack: Item { ... }         // Unified track rendering (solid/dotted)
component SliderHandle: Rectangle { ... }   // Reusable handle with styling
```

This approach eliminates ~200 lines of code duplication while maintaining full functionality.

## Features

- ✅ **Dual Mode**: Single value or range selection
- ✅ **Track Styles**: Solid or dotted track appearance
- ✅ **Size Variants**: Small, medium, and large sizes
- ✅ **Value Formatting**: Prefix, suffix, and decimal place control
- ✅ **Theme Integration**: Consistent with App.Themes system
- ✅ **Smooth Animations**: Color transitions and hover effects
- ✅ **Responsive Design**: Adapts to container width
- ✅ **Touch Friendly**: Optimized handle sizes for mobile
- ✅ **Disabled State**: Visual feedback for non-interactive states

## Component Structure

```
Slider
├── Properties (Public API)
├── Size Configuration
├── Micro-Components
│   ├── ValueDisplay
│   ├── SliderTrack  
│   └── SliderHandle
└── Main Layout
    ├── Header (Label + Values)
    └── Control Area
        ├── Single Slider
        └── Range Slider
```

## API Reference

### Properties

#### Basic Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | string | `"md"` | Size variant: `"sm"`, `"md"`, `"lg"` |
| `label` | string | `""` | Text label displayed above slider |
| `enabled` | bool | `true` | Whether the slider is interactive |
| `accentColor` | color | `Theme.colors.accent500` | Primary color for active elements |

#### Display Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showValues` | bool | `true` | Show/hide value text display |
| `valuePrefix` | string | `""` | Text prepended to values (e.g., "$") |
| `valueSuffix` | string | `""` | Text appended to values (e.g., "%") |
| `decimalPlaces` | int | `0` | Number of decimal places to display |

#### Behavior Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `isRange` | bool | `false` | Enable range selection mode |
| `isDotted` | bool | `false` | Use dotted track style |
| `from` | real | `0` | Minimum value |
| `to` | real | `100` | Maximum value |
| `stepSize` | real | `1` | Value increment step |

#### Single Value Mode
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | real | `50` | Current slider value |

#### Range Mode
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `firstValue` | real | `25` | Lower bound of range |
| `secondValue` | real | `75` | Upper bound of range |

### Size Configurations

| Size | Handle | Track Height | Font Size | Use Case |
|------|--------|--------------|-----------|----------|
| `sm` | 16px | 4px | 12px | Compact interfaces, mobile |
| `md` | 20px | 6px | 14px | Standard desktop applications |
| `lg` | 24px | 8px | 16px | Touch-first, accessibility |

## Usage Examples

### Basic Single Value Slider

```qml
UI.Slider {
    width: 300
    value: 50
    from: 0
    to: 100
    label: "Volume"
    valueSuffix: "%"
}
```

### Range Slider

```qml
UI.Slider {
    width: 400
    isRange: true
    firstValue: 25
    secondValue: 75
    from: 0
    to: 100
    label: "Price Range"
    valuePrefix: "$"
}
```

### Dotted Track Style

```qml
UI.Slider {
    width: 350
    value: 60
    isDotted: true
    label: "Progress"
    showValues: true
}
```

### Size Variants

```qml
// Small size for compact UI
UI.Slider {
    size: "sm"
    width: 200
    value: 30
    label: "Small"
}

// Large size for touch interfaces
UI.Slider {
    size: "lg"
    width: 300
    value: 70
    label: "Large"
}
```

### Formatted Values

```qml
// Currency formatting
UI.Slider {
    width: 300
    value: 250
    from: 0
    to: 1000
    stepSize: 10
    valuePrefix: "$"
    label: "Budget"
}

// Percentage with decimals
UI.Slider {
    width: 300
    value: 75.5
    from: 0
    to: 100
    stepSize: 0.1
    decimalPlaces: 1
    valueSuffix: "%"
    label: "Completion"
}
```

### Disabled State

```qml
UI.Slider {
    width: 300
    value: 40
    enabled: false
    label: "Read Only"
}
```

### Integration in Forms

```qml
ColumnLayout {
    spacing: 16
    
    UI.Slider {
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        label: "Temperature"
        value: 22
        from: 10
        to: 35
        valueSuffix: "°C"
    }
    
    UI.Slider {
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        label: "Humidity Range"
        isRange: true
        firstValue: 40
        secondValue: 60
        from: 0
        to: 100
        valueSuffix: "%"
    }
}
```

## Styling & Theming

The component integrates with the `App.Themes` system and uses the following theme tokens:

### Colors
- `Theme.colors.accent500` - Primary accent color
- `Theme.colors.text` - Label text color
- `Theme.colors.textMuted` - Disabled text color
- `Theme.colors.grey300` - Inactive track color
- `Theme.colors.white500` - Handle background

### Typography
- `Theme.typography.familySans` - Font family
- `Theme.typography.weightMedium` - Label font weight
- Size-specific font sizes from typography scale

### Spacing
- `Theme.spacing.s1` - Tight spacing
- `Theme.spacing.s2` - Standard spacing
- `Theme.spacing.s3` - Loose spacing

## Best Practices

### Layout Integration

```qml
// ✅ Good - Constrain maximum width
UI.Slider {
    Layout.fillWidth: true
    Layout.maximumWidth: 400
    // ... other properties
}

// ❌ Avoid - Unconstrained width in flexible layouts
UI.Slider {
    Layout.fillWidth: true  // May become too wide
    // ... other properties
}
```

### Value Handling

```qml
// ✅ Good - Bind to external state
UI.Slider {
    value: settings.volume
    onValueChanged: settings.volume = value
}

// ✅ Good - Use appropriate step sizes
UI.Slider {
    from: 0
    to: 1
    stepSize: 0.01  // Fine-grained control
    decimalPlaces: 2
}
```

### Range Validation

```qml
UI.Slider {
    isRange: true
    firstValue: Math.min(minVal, maxVal)
    secondValue: Math.max(minVal, maxVal)
    
    // Ensure valid range on external changes
    onFirstValueChanged: {
        if (firstValue > secondValue) {
            secondValue = firstValue
        }
    }
}
```

### Performance Optimization

```qml
// ✅ Good - Reasonable step size
UI.Slider {
    from: 0
    to: 100
    stepSize: 1  // 100 possible values
}

// ❌ Avoid - Too fine granularity
UI.Slider {
    from: 0
    to: 100
    stepSize: 0.001  // 100,000 possible values
}
```

## Performance Notes

### Micro-Component Benefits
- **Zero File I/O**: Components defined inline eliminate file loading overhead
- **Shared Instances**: QML engine can optimize repeated component usage
- **Reduced Memory**: Single component definition shared across instances
- **Fast Instantiation**: No additional QML parsing for each slider

### Dotted Track Performance
The dotted track uses a `Repeater` with calculated model size:
```qml
model: isDotted ? Math.floor(parent.width / 6) : 0
```
- Model calculation is efficient (simple division)
- Zero delegates created when `isDotted: false`
- Delegate creation scales with track width (typically 30-100 items)

### Animation Performance
- Uses `ColorAnimation` with hardware acceleration
- 150ms duration provides smooth transitions without feeling sluggish
- `Easing.OutCubic` creates natural-feeling motion

---

*This component is part of the App.Components module and requires Qt Quick 6.8 or higher.*
