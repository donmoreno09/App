# Overlay Component Documentation

## Table of Contents

1. [Overview](#overview)
2. [Why This Approach](#why-this-approach)
3. [Architecture](#architecture)
4. [Properties](#properties)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)
7. [Technical Implementation](#technical-implementation)
9. [Accessibility](#accessibility)
10. [Troubleshooting](#troubleshooting)

## Overview

The `Overlay` component is a production-ready, minimalist overlay solution built on Qt Quick Controls' `Popup` component. It provides essential modal functionality with backdrop blur effects, smooth animations, and comprehensive event handling.

### Key Features

- **Modal behavior** with automatic focus management
- **Backdrop blur effect** using Qt's MultiEffect system
- **Center positioning** with automatic layering
- **ESC key and click-outside dismissal** built-in
- **Smooth enter/exit animations** with theme integration
- **Accessibility support** through Qt's popup infrastructure

## Why This Approach

### Popup vs. Alternative Containers

The `Overlay` component leverages Qt's `Popup` as its foundation rather than basic containers like `Rectangle` or `Item`. This architectural decision provides:

| Feature | Popup | Rectangle/Item |
|---------|-------|----------------|
| **Automatic Layering** | ✅ Uses `Overlay.overlay` global layer | ❌ Manual z-index management required |
| **Focus Management** | ✅ Built-in focus trapping and restoration | ❌ Complex manual implementation needed |
| **Event Handling** | ✅ Sophisticated `closePolicy` system | ❌ Global event handling complexity |
| **Accessibility** | ✅ Screen reader and keyboard navigation | ❌ Manual accessibility implementation |
| **Backdrop System** | ✅ `Overlay.modal` automatic management | ❌ Manual backdrop coordination |

## Architecture

```
Application Window
├── Normal Content (your app UI)
└── Overlay.overlay (global overlay layer - z: 1000+)
    ├── Backdrop (MultiEffect with blur)
    └── Popup Content
        └── contentItem (automatic)
            └── Your Content (via default property)
```

### Component Hierarchy

```qml
Popup (root)
├── Overlay.modal → backdropComponent
│   └── MultiEffect (backdrop blur)
│       └── ShaderEffectSource (captures background)
├── contentItem (auto-created by Qt)
│   └── Your Rectangle/Content (default property)
└── Animations (enter/exit transitions)
```

## Properties

### Public Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showBackdrop` | `bool` | `true` | Controls whether the blur backdrop is shown |

### Inherited Properties (from Popup)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `modal` | `bool` | `true` | Blocks interaction with background content |
| `focus` | `bool` | `true` | Automatically receives keyboard focus |
| `closePolicy` | `flags` | `CloseOnEscape \| CloseOnPressOutside` | Defines dismissal behavior |

## Usage Examples

### Basic Modal Dialog

```qml
import App.Components 1.0 as UI

UI.Overlay {
    id: basicDialog
    width: 400
    height: 300
    
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        radius: Theme.radius.lg
        border.width: Theme.borders.b1
        border.color: Theme.colors.border
        
        Text {
            anchors.centerIn: parent
            text: "Hello World"
            color: Theme.colors.text
        }
    }
}

// Usage
Button {
    text: "Show Dialog"
    onClicked: basicDialog.open()
}
```

### Confirmation Dialog

```qml
UI.Overlay {
    id: confirmDialog
    width: 450
    height: 200
    
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        radius: Theme.radius.lg
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.s6
            spacing: Theme.spacing.s4
            
            Text {
                text: "Confirm Delete"
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }
            
            Text {
                text: "This action cannot be undone."
                color: Theme.colors.textMuted
                Layout.fillWidth: true
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Theme.spacing.s2
                
                UI.Button {
                    text: "Cancel"
                    variant: "ghost"
                    onClicked: confirmDialog.close()
                }
                
                UI.Button {
                    text: "Delete"
                    variant: "danger"
                    onClicked: {
                        performDelete()
                        confirmDialog.close()
                    }
                }
            }
        }
    }
}
```

### Settings Panel

```qml
UI.Overlay {
    id: settingsPanel
    width: 600
    height: 500
    
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        radius: Theme.radius.lg
        
        ScrollView {
            anchors.fill: parent
            anchors.margins: Theme.spacing.s4
            
            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.s4
                
                Text {
                    text: "Application Settings"
                    font.pixelSize: Theme.typography.fontSize250
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                }
                
                // Settings content here
                Repeater {
                    model: settingsModel
                    delegate: SettingItem {
                        title: model.title
                        value: model.value
                    }
                }
            }
        }
    }
}
```

### No Backdrop Overlay

```qml
UI.Overlay {
    id: tooltip
    width: 250
    height: 100
    showBackdrop: false  // No blur backdrop
    
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.tooltip
        radius: Theme.radius.sm
        border.width: Theme.borders.b1
        border.color: Theme.colors.border
        
        Text {
            anchors.centerIn: parent
            text: "Tooltip content"
            color: Theme.colors.tooltipText
        }
    }
}
```

## Best Practices

### Content Structure

**Recommended Pattern:**
```qml
UI.Overlay {
    // Always wrap content in a styled container
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        radius: Theme.radius.lg
        
        // Your actual content here
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.s4
            // Content items...
        }
    }
}
```

### Sizing Guidelines

- **Small dialogs**: 300-400px width, 200-300px height
- **Medium dialogs**: 450-600px width, 300-500px height  
- **Large dialogs**: 600-800px width, 400-600px height
- **Full overlays**: Use percentage-based sizing: `width: parent.width * 0.8`

### Event Handling

```qml
UI.Overlay {
    id: myOverlay
    
    // Handle custom close logic
    onAboutToHide: {
        // Save unsaved changes
        saveData()
    }
    
    // Handle opened event
    onOpened: {
        // Focus first input
        firstInput.forceActiveFocus()
    }
}
```

## Technical Implementation

### Backdrop Blur System

The backdrop blur uses Qt's modern MultiEffect system:

```qml
Component {
    id: backdropComponent
    
    MultiEffect {
        source: ShaderEffectSource {
            sourceItem: (Overlay.overlay && Overlay.overlay.parent) ? Overlay.overlay.parent : null
            live: true              // Real-time updates
            hideSource: false       // Keep original visible
        }
        
        blurEnabled: true
        blur: 0.6                  // 60% blur intensity
        autoPaddingEnabled: false  // Prevent size growth
    }
}
```

### Content System

Content is managed through Qt's default property system:

```qml
// What you write:
UI.Overlay {
    Rectangle { /* content */ }
}

// What QML creates internally:
Popup {
    contentData: [ Rectangle { /* content */ } ]  // Default property
}
```

### Animation System

```qml
enter: Transition {
    ParallelAnimation {
        NumberAnimation { 
            property: "opacity"
            from: 0; to: 1
            duration: 200
        }
        NumberAnimation { 
            property: "scale"
            from: 0.9; to: 1.0
            duration: 200
        }
    }
}
```

## Accessibility

The Overlay component provides comprehensive accessibility through Qt's Popup infrastructure:

### Automatic Features

- **Screen Reader Announcements**: Modal overlays are announced to assistive technologies
- **Focus Management**: Focus is automatically trapped within the overlay
- **Keyboard Navigation**: Tab/Shift+Tab stays within overlay content
- **ESC Key Handling**: Universal close behavior for keyboard users

### Best Practices

```qml
UI.Overlay {
    // Add accessible labels
    Accessible.name: "Settings Dialog"
    Accessible.description: "Configure application preferences"
    
    Rectangle {
        // First focusable item
        TextField {
            id: firstInput
            Accessible.name: "Username"
            Component.onCompleted: forceActiveFocus()
        }
    }
}
```

## Troubleshooting

### Common Issues

**Issue**: Backdrop not appearing
```qml
// Check: Is showBackdrop set to true?
showBackdrop: true

// Check: Is MultiEffect available?
import QtQuick.Effects  // Required import
```

**Issue**: Content not visible
```qml
// Ensure content has proper styling
Rectangle {
    anchors.fill: parent
    color: Theme.colors.surface  // Not transparent!
    // Your content...
}
```

**Issue**: Blur effect not working
```qml
// Fallback for systems without MultiEffect support
Component {
    id: backdropComponent
    Rectangle {
        color: "#AA000000"  // Simple dark overlay fallback
    }
}
```

**Issue**: Animation stuttering
```qml
// Reduce animation complexity on low-end devices
NumberAnimation { 
    duration: Qt.platform.os === "android" ? 100 : 200
}
```

### Debug Information

Enable Qt logging to debug popup behavior:
```bash
QT_LOGGING_RULES="qt.quick.controls.popup.debug=true" ./your-app
```

## Migration Guide

### From Custom Rectangle-based Overlays

**Before:**
```qml
Rectangle {
    id: overlay
    z: 999
    anchors.fill: parent
    color: "#80000000"
    visible: false
    
    MouseArea {
        anchors.fill: parent
        onClicked: overlay.visible = false
    }
    
    Rectangle {
        anchors.centerIn: parent
        // Content...
    }
}
```

**After:**
```qml
UI.Overlay {
    id: overlay
    width: 400
    height: 300
    
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.surface
        // Content...
    }
}
```

### Benefits of Migration

- **50+ lines of code eliminated** per overlay
- **Automatic accessibility** support added
- **Professional animations** and behavior
- **Cross-platform compatibility** improved
- **Maintenance burden** reduced significantly

---

*This component is part of the App.Components design system. For questions or issues, refer to the component source code or team documentation.*
