# TextArea Component Documentation

## Table of Contents

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Component Architecture](#component-architecture)
4. [Properties](#properties)
   - [Core Properties](#core-properties)
   - [Styling Properties](#styling-properties)
   - [Component References](#component-references)
5. [Signals](#signals)
6. [Usage Examples](#usage-examples)
   - [Basic Usage](#basic-usage)
   - [With Validation States](#with-validation-states)
   - [Character Limits](#character-limits)
   - [Custom Sizing](#custom-sizing)
7. [Styling System](#styling-system)
8. [Implementation Details](#implementation-details)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The TextArea component is a multi-line text input component built for Qt Quick applications. It extends the standard Qt TextArea with consistent theming, validation states, character counting, and integrated labeling - following the same design patterns established by the Input component.

### Key Features

- **Multi-line text editing** with automatic scrolling
- **Character limit enforcement** with visual counter
- **Consistent styling system** with variant-based theming (Default, Success, Warning, Error)
- **Integrated labeling** with optional tooltips and messages
- **Responsive design** that adapts to content while maintaining fixed height
- **Accessibility support** with proper ARIA roles and navigation

---

## Design Philosophy

### Why This Approach?

The TextArea component was designed to maintain **visual and functional consistency** with the existing Input component while addressing the unique requirements of multi-line text editing:

1. **Unified Design Language**: Shares the same styling system, label structure, and interaction patterns as single-line Input components
2. **User Experience Continuity**: Users familiar with Input components can immediately understand TextArea behavior
3. **Scalable Architecture**: Component-based design allows for easy maintenance and extension
4. **Performance Optimization**: Fixed-height approach with internal scrolling prevents layout shifts

### Design Decisions

- **Fixed Height with Scrolling**: Maintains consistent layout while allowing unlimited content
- **Character Counter Integration**: Built-in enforcement prevents accidental over-input
- **Variant-Based Styling**: Consistent error/warning/success states across all input types
- **Composition over Inheritance**: Uses Qt's TextArea internally rather than extending it

---

## Component Architecture

```
TextArea (Item)
├── ColumnLayout (container)
    ├── RowLayout (Label Section)
    │   ├── Label (main label)
    │   ├── InfoBadge (tooltip icon)
    │   └── CharacterCounter (0/1000 display)
    ├── Rectangle (Input Section)
    │   ├── ScrollView
    │   │   └── TextArea (Qt's TextArea)
    │   └── Rectangle (bottom border)
    └── RowLayout (Message Section)
        ├── Button (status icon)
        └── Text (message text)
```

### Internal Components

- **CharacterCounter**: Displays current/max character count
- **InfoBadge**: Shows tooltip icon with hover information
- **ScrollView**: Handles content overflow with vertical scrolling
- **MouseArea**: Provides click-to-focus behavior across entire component

---

## Properties

### Core Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | `""` | The text content of the TextArea |
| `placeholderText` | string | `""` | Hint text shown when TextArea is empty |
| `enabled` | bool | `true` | Whether the TextArea accepts user input |
| `wrapMode` | enumeration | `TextArea.Wrap` | How text wrapping is handled |
| `selectByMouse` | bool | `true` | Whether text can be selected with mouse |

### Styling Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `labelText` | string | `""` | Main label text displayed above TextArea |
| `tooltipText` | string | `""` | Tooltip text for info icon (shows icon when set) |
| `messageText` | string | `""` | Status message displayed below TextArea |
| `variant` | int | `InputStyles.Default` | Visual state: Default, Success, Warning, Error |
| `minimumHeight` | int | `60` | Minimum height in pixels of the input area |
| `characterLimit` | int | `1000` | Maximum number of characters allowed |

### Component References

| Property | Type | Description |
|----------|------|-------------|
| `textArea` | TextArea | Direct reference to internal Qt TextArea |
| `scrollView` | ScrollView | Reference to the ScrollView container |

---

## Signals

| Signal | Parameters | Description |
|--------|------------|-------------|
| `textEdited()` | none | Emitted when text is modified by user interaction |
| `textEditingFinished()` | none | Emitted when TextArea loses focus or Enter is pressed |

---

## Usage Examples

### Basic Usage

```qml
import App.Components 1.0 as UI

UI.TextArea {
    labelText: "Description"
    placeholderText: "Enter your description here..."
    text: "Initial content"
}
```

### With Validation States

```qml
// Success state
UI.TextArea {
    variant: UI.InputStyles.Success
    labelText: "Comments"
    messageText: "Looks good!"
    text: "Well-written feedback"
}

// Error state
UI.TextArea {
    variant: UI.InputStyles.Error
    labelText: "Required Field"
    messageText: "This field cannot be empty"
    placeholderText: "Please enter content..."
}

// Warning state
UI.TextArea {
    variant: UI.InputStyles.Warning
    labelText: "Notes"
    messageText: "Consider adding more details"
    text: "Brief note"
}
```

### Character Limits

```qml
// Short limit for concise input
UI.TextArea {
    labelText: "Tweet"
    characterLimit: 280
    placeholderText: "What's happening?"
}

// Custom limit with tooltip
UI.TextArea {
    labelText: "Summary"
    tooltipText: "Keep it under 500 characters"
    characterLimit: 500
    placeholderText: "Brief project summary..."
}
```

### Custom Sizing

```qml
// Compact TextArea
UI.TextArea {
    labelText: "Quick Note"
    minimumHeight: 40
    placeholderText: "Short note..."
}

// Tall TextArea for detailed content
UI.TextArea {
    labelText: "Detailed Description"
    minimumHeight: 120
    placeholderText: "Provide detailed information..."
}
```

### Event Handling

```qml
UI.TextArea {
    id: myTextArea
    labelText: "Content"
    
    onTextEdited: {
        console.log("User is typing:", text)
        // Perform real-time validation or processing
    }
    
    onTextEditingFinished: {
        console.log("User finished editing:", text)
        // Save content, trigger validation, etc.
    }
    
    // Access internal components if needed
    Component.onCompleted: {
        myTextArea.textArea.selectAll() // Select all text
        myTextArea.scrollView.contentY = 0 // Scroll to top
    }
}
```

---

## Styling System

The TextArea component uses the same styling system as Input components:

### Available Variants

- **`InputStyles.Default`**: Standard neutral appearance
- **`InputStyles.Success`**: Green accent for positive states
- **`InputStyles.Warning`**: Orange accent for cautionary states  
- **`InputStyles.Error`**: Red accent for error states

### Style Properties Applied

Each variant affects:
- Border color (normal, focused, disabled states)
- Message icon (info, check, warning, error icons)
- Message text color
- Label text color when disabled

### Theme Integration

The component automatically adapts to:
- Typography settings from `Theme.typography`
- Color palette from `Theme.colors`
- Spacing values from `Theme.spacing`
- Border radius from `Theme.radius`

---

## Implementation Details

### Character Limit Enforcement

```qml
onTextChanged: {
    if (text.length > characterCounter.limit) {
        var cursorPos = cursorPosition
        text = text.substring(0, characterCounter.limit)
        cursorPosition = Math.min(cursorPos, text.length)
    }
    textAreaInput.textEdited()
}
```

The component enforces character limits by:
1. Monitoring text changes in real-time
2. Truncating text that exceeds the limit
3. Preserving cursor position when possible
4. Updating the character counter display

### Scrolling Behavior

- **Fixed Height**: Component maintains consistent height regardless of content
- **Vertical Scrolling**: Content scrolls vertically when exceeding visible area
- **No Horizontal Scrolling**: Text wrapping prevents horizontal overflow
- **Auto-scroll**: ScrollView automatically scrolls to cursor position

### Focus Management

- **Click-to-Focus**: Clicking anywhere on the component focuses the TextArea
- **Visual Focus Indicators**: Bottom border changes color when focused
- **Keyboard Navigation**: Standard Tab/Shift+Tab navigation support

---

## Best Practices

### Content Guidelines

- **Use appropriate character limits** based on content type (tweets: 280, descriptions: 1000+)
- **Provide clear placeholder text** that explains expected content format
- **Set meaningful labels** that clearly identify the field's purpose
- **Use validation states** to provide immediate feedback on content quality

### Layout Considerations

- **Allow adequate height** - 60px minimum, increase for detailed content
- **Consider responsive design** - component adapts well to Layout constraints
- **Group related TextAreas** logically within forms
- **Provide sufficient spacing** between multiple TextArea components

### Accessibility

- **Always include labelText** for screen readers
- **Use tooltipText** for additional context when needed
- **Provide meaningful messageText** for validation feedback
- **Test keyboard navigation** through your form

### Performance

- **Avoid excessive character limits** (10,000+ characters may impact performance)
- **Use textEditingFinished** for expensive operations instead of textEdited
- **Consider debouncing** for real-time validation or search functionality

---

## Troubleshooting

### Common Issues

**TextArea not scrolling properly**
- Ensure `minimumHeight` is set appropriately
- Check that parent Layout constraints aren't conflicting
- Verify ScrollView isn't being overridden by custom styling

**Character limit not working**
- Confirm `characterLimit` property is set correctly
- Check that character counter is visible (requires labelText to be set)
- Verify no external code is overriding the text property

**Styling inconsistencies**
- Ensure proper import: `import App.Components 1.0 as UI`
- Verify theme system is properly initialized
- Check that variant values use `UI.InputStyles` enum

**Focus issues**
- Confirm MouseArea isn't blocked by parent components
- Verify component is properly enabled
- Check that other components aren't intercepting focus

### Integration Notes

- **Works with Layout systems**: Properly supports Qt's Layout components
- **Theme compatibility**: Automatically adapts to light/dark theme changes
- **Form integration**: Designed to work alongside other Input components
- **Validation systems**: Event signals integrate well with form validation frameworks

---

*This component follows the established design patterns of the Input component family and maintains consistency with the overall application design system.*
