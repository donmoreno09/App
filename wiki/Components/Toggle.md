# Qt Toggle/Switch Component

## Table of Contents
1. [Project Overview](#project-overview)
2. [Why This Approach?](#why-this-approach)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Core Components](#core-components)
5. [Qt QML Integration](#qt-qml-integration)
6. [Implementation Details](#implementation-details)
7. [Workflow & Process](#workflow--process)
8. [Building & Usage](#building--usage)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Project Overview

This Qt 6 Toggle/Switch component provides a production-ready, highly customizable binary selection interface with comprehensive support for different sizes, labels, and variant-based styling. The component features a modern dark theme design, smooth animations, and flexible integration patterns for various use cases.

### Key Features

- **Variant-Based Styling**: Clean separation between behavior and appearance through ToggleStyles singleton
- **Multiple Size Options**: Small (32×18), Medium (40×22), and Large (48×26) with appropriate knob sizing
- **Flexible Label Support**: Left labels, right labels for different layout requirements
- **Smooth Animations**: Buttery smooth transitions for knob movement and color changes
- **Theme Integration**: Full integration with App.Themes system for consistent styling
- **Accessibility Ready**: Keyboard navigation and screen reader support through Qt Switch base

## Why This Approach?

The Toggle component uses a **Variant-Based Architecture** that provides several key benefits:

**Benefits of This Structured Approach:**

1. **Centralized Style Management**
```qml
// All styling managed in one place
ToggleStyles {
    property ToggleStyle _primary: ToggleStyle {
        background: Theme.colors.grey400
        backgroundChecked: Theme.colors.accent500
        backgroundDisabled: Theme.colors.grey300
        knob: Theme.colors.white500
        knobDisabled: Theme.colors.grey200
    }
}
```

2. **Flexible Size System**
```qml
// Size configurations centrally managed
readonly property var _sizeConfigs: ({
    "sm": { width: 32, height: 18, knobSize: 14 },
    "md": { width: 40, height: 22, knobSize: 18 },
    "lg": { width: 48, height: 26, knobSize: 22 }
})
```

3. **Easy Variant Extension**
```qml
// Flexible variant system
enum Variant {
    Primary
}
```

4. **Consistent API**
```qml
// Same API across all usage patterns
Toggle { variant: ToggleStyles.Primary; size: "md" }
Toggle { variant: ToggleStyles.Primary; size: "lg" }
```

## Architecture & Design Patterns

### System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Toggle      │────▶│  ToggleStyles   │────▶│   ToggleStyle   │
│  (Main Component)│    │   (Singleton)   │    │   (Interface)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
    User Interface             Style Logic           Color Definitions
    - Size handling            │                        │
    - Label positioning        ▼                        ▼
    - Animation               ┌──────────────┐    ┌──────────────┐
    - Event handling          │Size Configs  │    │Theme Colors  │
         │                    │──────────────│    │──────────────│
         └─── Behavior ───────▶│ • Small      │    │ • Background │
             Logic             │ • Medium     │    │ • Checked    │
                              │ • Large      │    │ • Disabled   │
                              │ • Responsive │    │ • Knob       │
                              └──────────────┘    └──────────────┘
```

### Component Hierarchy

```
Toggle (QtQuick.Controls.Switch)
└── Indicator (Item - Main Container)
    ├── MouseArea (Click Handling)
    └── RowLayout (Complete Layout Container)
        ├── Left Label (Text) [Optional]
        ├── Toggle Track (Rectangle)
        │   ├── Background Styling (from ToggleStyle)
        │   ├── Knob (Rectangle - Moving Circle)
        │   │   ├── Knob Styling (from ToggleStyle)
        │   │   ├── Position Animation (Behavior on x)
        │   │   └── Color Animation (Behavior on color)
        │   └── Background Animation (Behavior on color)
        └── Right Label (Text) [Optional]
```

### Design Patterns Used

1. **Strategy Pattern (Variant System)**
```qml
// Different styling strategies based on variant
readonly property ToggleStyle _style: ToggleStyles.fromVariant(variant)

// Runtime style selection
function fromVariant(variant) {
    switch (variant) {
    case ToggleStyles.Primary: return _primary
    case ToggleStyles.Secondary: return _secondary
    default: return _primary
    }
}
```

**Why?** Allows different visual presentations while maintaining the same behavior and API.

2. **Singleton Pattern (Style Management)**
```qml
// ToggleStyles.qml - Centralized style management
pragma Singleton
QtObject {
    // All variants defined in one place
    property ToggleStyle _primary: ToggleStyle { /* ... */ }
    property ToggleStyle _secondary: ToggleStyle { /* ... */ }
}
```

**Why?** Ensures consistent styling across the entire application and makes theme changes easy.

3. **Template Method Pattern (Size Configuration)**
```qml
// Toggle defines structure, sizes provide parameters
readonly property var _sizeStyles: ToggleStyles.sizeConfig(size)

// Size template with flexible parameters
function sizeConfig(size) {
    return _sizeConfigs[size] || _sizeConfigs["md"]
}
```

**Why?** Consistent size behavior with flexible dimensional parameters.

4. **Facade Pattern (Complex Animation Management)**
```qml
// Simple API hides complex animation coordination
Behavior on x { NumberAnimation { duration: 150 } }
Behavior on color { ColorAnimation { duration: 150 } }

// User just sets properties, animations handle themselves
checked: someCondition  // Triggers all necessary animations
```

**Why?** Complex animation coordination hidden behind simple property changes.

5. **Composite Pattern (Integrated Layout)**
```qml
// Complete toggle layout in single indicator
indicator: Item {
    RowLayout {
        Text { visible: leftLabel !== "" }   // Left label
        Rectangle { /* Toggle track */ }     // Toggle mechanism  
        Text { visible: rightLabel !== "" }  // Right label
    }
}
```

**Why?** Unified layout container handles toggle mechanism and labels together, with custom click handling.

## Core Components

### 1. Toggle (Main Component)

**Purpose**
Primary toggle/switch component providing binary selection with smooth animations and flexible styling.

**Files**
- `Toggle.qml`: Main toggle component
- `ToggleStyle.qml`: Style interface/contract
- `ToggleStyles.qml`: Singleton with style variants and size configurations

**Key Properties**
```qml
Switch {
    // Configuration
    property string size: "md"              // "sm", "md", "lg"
    property string leftLabel: ""           // Optional left text
    property string rightLabel: ""          // Optional right text
    property int variant: ToggleStyles.Primary  // Style variant
    
    // Size computation (read-only)
    readonly property var _sizeStyles: ToggleStyles.sizeConfig(size)
    readonly property ToggleStyle _style: ToggleStyles.fromVariant(variant)
    
    // Inherited from Qt Switch
    property bool checked: false            // Toggle state
    property bool enabled: true             // Interactive state
    
    // Signals (inherited)
    signal toggled()                        // State changed
    signal clicked()                        // User interaction
    
    // Custom Implementation
    indicator: Item {
        // Complete toggle layout including labels and click handling
        MouseArea { /* Custom click logic */ }
        RowLayout {
            Text { /* Left label */ }
            Rectangle { /* Toggle track with knob */ }
            Text { /* Right label */ }
        }
    }
}
```

**Why This API Design?**
- **Size Flexibility**: String-based sizes are user-friendly and extensible
- **Label Integration**: Built-in label support with unified layout eliminates external layout complexity
- **Variant System**: Clean separation between behavior and appearance
- **Qt Integration**: Inherits all standard Switch behavior and accessibility
- **Animation Ready**: All visual changes automatically animated
- **Custom Interaction**: MouseArea provides precise click control within indicator

### 2. ToggleStyle (Style Interface)

**Purpose**
Defines the contract/interface that all toggle style variants must implement, ensuring consistency and enabling autocomplete.

**Key Properties**
```qml
QtObject {
    // Required color properties for any toggle variant
    required property color background        // Unchecked background
    required property color backgroundChecked // Checked background  
    required property color backgroundDisabled // Disabled background
    required property color knob             // Knob color (normal)
    required property color knobDisabled     // Knob color (disabled)
}
```

**Why This Interface?**
- **Type Safety**: Ensures all variants provide required properties
- **IDE Support**: Enables autocomplete when creating new variants
- **Documentation**: Self-documenting contract for style implementers
- **Validation**: Compile-time checking that variants are complete

### 3. ToggleStyles (Style Singleton)

**Purpose**
Centralized singleton providing all toggle style variants and size configurations.

**Key Properties**
```qml
pragma Singleton
QtObject {
    // Enum for type-safe variant selection
    enum Variant {
        Primary
    }
    
    // Style variants
    property ToggleStyle _primary: ToggleStyle {
        background: Theme.colors.grey400
        backgroundChecked: Theme.colors.accent500
        backgroundDisabled: Theme.colors.grey300
        knob: Theme.colors.white500
        knobDisabled: Theme.colors.grey200
    }
    
    // Size configurations
    readonly property var _sizeConfigs: ({
        "sm": { width: Theme.spacing.s8, height: 18, knobSize: 14 },
        "md": { width: Theme.spacing.s10, height: 22, knobSize: 18 },
        "lg": { width: Theme.spacing.s12, height: 26, knobSize: 22 }
    })
    
    // Variant resolver
    function fromVariant(variant) {
        switch (variant) {
        case ToggleStyles.Primary: return _primary
        default: return _primary
        }
    }
    
    // Size resolver
    function sizeConfig(size) {
        return _sizeConfigs[size] || _sizeConfigs["md"]
    }
}
```

**Benefits of Centralized Management:**
- **Single Source of Truth**: All styling decisions in one place
- **Easy Theme Updates**: Change colors globally by updating singleton
- **Size Consistency**: Standardized sizing across all toggles
- **Performance**: Singleton pattern prevents duplicate style objects

## Qt QML Integration

### Component Lifecycle & Property Binding

```qml
// 1. Component Initialization
Toggle {
    id: toggle
    
    // 2. Property initialization with defaults
    Component.onCompleted: {
        // Size styles computed immediately
        console.log("Toggle size:", _sizeStyles.width + "×" + _sizeStyles.height)
        console.log("Knob size:", _sizeStyles.knobSize)
        
        // Style variant resolved
        console.log("Background color:", _style.background)
    }
    
    // 3. Property binding establishment
    implicitWidth: _sizeStyles.width
    implicitHeight: _sizeStyles.height
    
    // 4. Animation system activation
    Behavior on checked {
        // Triggers knob movement and color changes
        PropertyAnimation { duration: Theme.motion.panelTransitionMs }
    }
}
```

### Qt Switch Integration (Inheritance Benefits)

```qml
// Toggle inherits all Qt Switch capabilities
Switch {
    // ✅ Automatic keyboard navigation (Tab, Space, Enter)
    // ✅ Screen reader accessibility
    // ✅ Focus management
    // ✅ Standard signals (toggled, clicked, etc.)
    
    // Our enhancements - complete custom indicator
    indicator: Item {
        MouseArea {
            // Custom click handling
            onPressed: root.checked = !root.checked
        }
        
        RowLayout {
            Text { /* Left label */ }
            Rectangle {
                // Custom toggle track implementation
                color: root.enabled ? 
                       (root.checked ? root._style.backgroundChecked : root._style.background) :
                       root._style.backgroundDisabled
                
                Rectangle {
                    // Custom knob implementation with animation
                    x: root.checked ? parent.width - width - 2 : 2
                    Behavior on x { NumberAnimation { /* smooth movement */ } }
                }
            }
            Text { /* Right label */ }
        }
    }
}
```

**Why Inherit from Qt Switch?**
- **Accessibility**: Free keyboard navigation and screen reader support
- **Platform Integration**: Native behavior on different operating systems  
- **Focus Management**: Proper focus indication and tab order
- **Signal Consistency**: Standard Qt signal patterns
- **Custom Control**: Complete indicator override allows full visual and interaction control

### Animation System Integration

```qml
// Coordinated animation system
Rectangle {
    // Knob position animation
    x: root.checked ? parent.width - width - 2 : 2
    Behavior on x {
        NumberAnimation { 
            duration: Theme.motion.panelTransitionMs
            easing.type: Theme.motion.panelTransitionEasing 
        }
    }
    
    // Knob color animation
    color: root.enabled ? root._style.knob : root._style.knobDisabled
    Behavior on color {
        ColorAnimation { 
            duration: Theme.motion.panelTransitionMs
            easing.type: Theme.motion.panelTransitionEasing 
        }
    }
}

// Background color animation
color: root.enabled ? 
       (root.checked ? root._style.backgroundChecked : root._style.background) :
       root._style.backgroundDisabled
Behavior on color {
    ColorAnimation { 
        duration: Theme.motion.panelTransitionMs
        easing.type: Theme.motion.panelTransitionEasing 
    }
}
```

**Animation Architecture Benefits:**
- **Synchronized Timing**: All animations use same duration and easing
- **Theme Integration**: Animation parameters from centralized theme
- **Smooth Transitions**: No jarring state changes
- **Performance**: Hardware-accelerated animations where possible

## Implementation Details

### Size System with Responsive Design

**Problem**: Creating toggles that work well at different sizes while maintaining proper proportions.

**Solution**: Mathematical size relationships with theme integration.

```qml
// Size configurations with mathematical relationships
readonly property var _sizeConfigs: ({
    "sm": { 
        width: Theme.spacing.s8,    // 32px
        height: 18,                 // ~56% of width
        knobSize: 14               // ~78% of height
    },
    "md": { 
        width: Theme.spacing.s10,   // 40px  
        height: 22,                // 55% of width
        knobSize: 18               // ~82% of height
    },
    "lg": { 
        width: Theme.spacing.s12,   // 48px
        height: 26,                // 54% of width
        knobSize: 22               // ~85% of height
    }
})

// Dynamic size application
implicitWidth: _sizeStyles.width
implicitHeight: _sizeStyles.height

Rectangle { // Knob
    width: root._sizeStyles.knobSize
    height: root._sizeStyles.knobSize
    radius: height / 2  // Always perfectly circular
}
```

**Why These Proportions?**
- **Visual Balance**: Knob size maintains visual weight across sizes
- **Touch Targets**: All sizes meet minimum touch target guidelines
- **Pixel Perfect**: Sizes align with 8px grid system
- **Scalability**: Proportions work from mobile to desktop

### Advanced Color State Management

**Problem**: Managing multiple color states (normal, checked, disabled) with smooth transitions.

**Solution**: Computed color properties with centralized state logic.

```qml
// Centralized color computation
readonly property color _backgroundColor: {
    if (!root.enabled) return root._style.backgroundDisabled
    return root.checked ? root._style.backgroundChecked : root._style.background
}

readonly property color _knobColor: {
    return root.enabled ? root._style.knob : root._style.knobDisabled
}

// Applied to visual elements
Rectangle { // Background
    color: root._backgroundColor
    Behavior on color { ColorAnimation { duration: 150 } }
}

Rectangle { // Knob
    color: root._knobColor
    Behavior on color { ColorAnimation { duration: 150 } }
}
```

**Benefits of This Approach:**
- **Single Source**: Color logic centralized and reusable
- **Automatic Animation**: Color changes automatically trigger smooth transitions
- **State Consistency**: Impossible to have inconsistent color states
- **Easy Debugging**: All color decisions in one place

### Label Integration with Unified Layout

**Problem**: Supporting various label configurations while keeping toggle and labels as a single cohesive unit.

**Solution**: Complete layout integration within the indicator using RowLayout.

```qml
indicator: Item {
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: root.checked = !root.checked  // Custom click handling
    }
    
    RowLayout {
        spacing: Theme.spacing.s2  // Consistent spacing
        
        // Left label - only renders when needed
        Text {
            visible: root.leftLabel !== ""
            text: root.leftLabel
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.text
        }
        
        // Toggle track - central element
        Rectangle {
            width: root._sizeStyles.width
            height: root._sizeStyles.height
            color: /* computed color from style */
            radius: height / 2
            
            Rectangle {
                // Knob with animated position
                x: root.checked ? parent.width - width - 2 : 2
                // ... knob styling and animations
            }
        }
        
        // Right label - only renders when needed
        Text {
            visible: root.rightLabel !== ""
            text: root.rightLabel
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.text
        }
    }
}
```

**Unified Layout Benefits:**
- **Single Component**: Toggle and labels managed as one cohesive unit
- **Automatic Sizing**: Component size adapts to content automatically  
- **Custom Interaction**: MouseArea allows precise click control
- **Performance**: No separate contentItem layout calculations needed
- **Consistent Spacing**: Typography and spacing from theme system

### Animation Coordination System

**Problem**: Coordinating multiple simultaneous animations (knob position, knob color, background color) within the indicator layout.

**Solution**: Synchronized Behavior animations with shared timing.

```qml
// Within the indicator's RowLayout
Rectangle {
    // Toggle track
    width: root._sizeStyles.width
    height: root._sizeStyles.height
    
    // Background color animation  
    color: {
        if (!root.enabled) return root._style.backgroundDisabled
        return root.checked ? root._style.backgroundChecked : root._style.background
    }
    Behavior on color {
        ColorAnimation { 
            duration: Theme.motion.panelTransitionMs
            easing.type: Theme.motion.panelTransitionEasing
        }
    }
    
    // Knob with coordinated animations
    Rectangle {
        // Position animation
        x: root.checked ? parent.width - width - 2 : 2
        Behavior on x {
            NumberAnimation { 
                duration: Theme.motion.panelTransitionMs
                easing.type: Theme.motion.panelTransitionEasing
            }
        }
        
        // Color animation
        color: root.enabled ? root._style.knob : root._style.knobDisabled
        Behavior on color {
            ColorAnimation { 
                duration: Theme.motion.panelTransitionMs
                easing.type: Theme.motion.panelTransitionEasing
            }
        }
    }
}
```

**Animation Coordination Benefits:**
- **Synchronized**: All animations complete at exactly the same time
- **Consistent**: Same easing curve creates unified motion feel
- **Theme Controlled**: Easy to adjust animation speed globally
- **Smooth**: No animation conflicts or jarring transitions

## Workflow & Process

### Development Workflow

1. **Component Design Phase**
```
Requirements → API Design → Style System → Implementation
      ↓              ↓              ↓             ↓
- Size variants    - Properties    - ToggleStyle   - Toggle.qml
- Label support    - Signals       - ToggleStyles  - Animation
- Variant system   - Methods       - Size configs  - Integration
```

2. **Style System Development**
```qml
// Step 1: Define style interface
ToggleStyle {
    required property color background
    required property color backgroundChecked
    // ... other required properties
}

// Step 2: Create style variants
ToggleStyles {
    property ToggleStyle _primary: ToggleStyle {
        background: Theme.colors.grey400
        // ... variant-specific colors
    }
}

// Step 3: Add size configurations
readonly property var _sizeConfigs: ({
    "sm": { width: 32, height: 18, knobSize: 14 }
    // ... other size variants
})
```

3. **Component Implementation**
```qml
// Step 1: Extend Qt Switch
Switch {
    // Inherit accessibility and behavior
}

// Step 2: Add custom properties
property string size: "md"
property int variant: ToggleStyles.Primary

// Step 3: Implement complete indicator
indicator: Item {
    MouseArea { /* Custom click handling */ }
    RowLayout {
        Text { /* Left label */ }
        Rectangle { /* Toggle track and knob */ }
        Text { /* Right label */ }
    }
}
```

### Adding New Sizes

**Example: Adding an "Extra Large" Size**

**Step 1: Add Size Configuration**
```qml
// In ToggleStyles.qml
readonly property var _sizeConfigs: ({
    "sm": { width: Theme.spacing.s8, height: 18, knobSize: 14 },
    "md": { width: Theme.spacing.s10, height: 22, knobSize: 18 },
    "lg": { width: Theme.spacing.s12, height: 26, knobSize: 22 },
    "xl": { width: Theme.spacing.s14, height: 30, knobSize: 26 }  // New size
})
```

**Step 2: Use New Size**
```qml
Toggle {
    size: "xl"
    leftLabel: "Master control"
    checked: true
}
```

**No Other Changes Needed:**
- Size resolver automatically handles new size
- Animation system works without modification
- All existing API continues to work

### Performance Optimization

1. **Property Binding Analysis**
```qml
// Use readonly properties for expensive computations
readonly property bool canEnableFeature: 
    user.hasPermission && system.isReady && !maintenance.active

readonly property color _backgroundColor: {
    if (!root.enabled) return root._style.backgroundDisabled
    return root.checked ? root._style.backgroundChecked : root._style.background
}
```

2. **Layout Optimization**
```qml
// Use fixed dimensions to prevent layout passes
implicitWidth: _sizeStyles.width   // Fixed, not computed
implicitHeight: _sizeStyles.height // Fixed, not computed
```

## Building & Usage

### Prerequisites

- **Qt 6.8+**: QML framework with Controls module
- **CMake 3.16+**: Build system with Qt integration
- **App.Themes Module**: Centralized theming system
- **App.Components Module**: Base component library

### Component Integration

**CMakeLists.txt Structure**
```cmake
# Toggle component files
set(toggle_qml_files
    toggle/Toggle.qml
    toggle/ToggleStyle.qml
    toggle/ToggleStyles.qml
)

# Singleton registration
set(qml_singletons
    toggle/ToggleStyles.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_components_toggle
    URI App.Components.Toggle
    VERSION 1.0
    QML_FILES ${toggle_qml_files}
)

# Link dependencies
target_link_libraries(app_components_toggle
    PRIVATE
    app_themes
    Qt6::Quick
    Qt6::QuickControls2
)
```

### Usage Examples

#### 1. Basic Toggle States

```qml
import App.Components 1.0 as UI

// Simple off/on toggle
UI.Toggle {
    id: basicToggle
    checked: false
    
    onToggled: {
        console.log("Toggle state:", checked)
    }
}

// Pre-checked toggle
UI.Toggle {
    checked: true
}

// Disabled toggle
UI.Toggle {
    enabled: false
    checked: true
}
```

#### 2. Size Variants

```qml
// Small toggle for compact UIs
UI.Toggle {
    size: "sm"
    checked: true
}

// Medium toggle (default)
UI.Toggle {
    size: "md"  // or omit for default
    checked: true
}

// Large toggle for accessibility
UI.Toggle {
    size: "lg"
    checked: true
}
```

#### 3. Labels and Settings Panels

```qml
// Settings-style toggles with left labels
ColumnLayout {
    UI.Toggle {
        leftLabel: "Enable notifications"
        checked: notificationSettings.enabled
        onToggled: notificationSettings.enabled = checked
    }
    
    UI.Toggle {
        leftLabel: "Dark mode"
        checked: appSettings.darkMode
        onToggled: appSettings.darkMode = checked
    }
    
    UI.Toggle {
        leftLabel: "Auto-save documents"
        checked: documentSettings.autoSave
        onToggled: documentSettings.autoSave = checked
    }
}
```

#### 4. Right Labels for Status Display

```qml
// Status indicators with right labels
UI.Toggle {
    rightLabel: connectionManager.isConnected ? "Connected" : "Disconnected"
    checked: connectionManager.isConnected
    enabled: false  // Display only
}

// Action toggles with right labels
UI.Toggle {
    rightLabel: "Auto-sync"
    checked: syncManager.autoSync
    onToggled: syncManager.autoSync = checked
}
```

#### 5. Interactive Mission Control Panel

```qml
Rectangle {
    width: 400
    height: 300
    color: Theme.colors.primary800
    border.color: Theme.colors.secondary500
    border.width: 1
    radius: Theme.radius.md

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Text {
            text: "Mission Control"
            font.pixelSize: Theme.typography.fontSize200
            font.weight: Theme.typography.weightBold
            color: Theme.colors.text
        }

        UI.Toggle {
            id: autoLaunchToggle
            leftLabel: "Auto-launch sequence"
            size: "md"
            checked: false
            onToggled: {
                statusDisplay.text = checked ? 
                    "🚀 Auto-launch: ENABLED" : 
                    "⏸️ Auto-launch: DISABLED"
                statusDisplay.color = checked ? 
                    Theme.colors.success : 
                    Theme.colors.textMuted
            }
        }

        UI.Toggle {
            id: telemetryToggle
            leftLabel: "Real-time telemetry"
            size: "md"
            checked: true
            onToggled: {
                statusDisplay.text = checked ? 
                    "📡 Telemetry: STREAMING" : 
                    "📡 Telemetry: PAUSED"
                statusDisplay.color = checked ? 
                    Theme.colors.accent500 : 
                    Theme.colors.warning
            }
        }

        UI.Toggle {
            id: emergencyToggle
            leftLabel: "Emergency override"
            size: "md"
            checked: false
            onToggled: {
                statusDisplay.text = checked ? 
                    "🚨 Emergency: ACTIVE" : 
                    "✅ Emergency: STANDBY"
                statusDisplay.color = checked ? 
                    Theme.colors.error : 
                    Theme.colors.success
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Theme.colors.secondary500
            radius: Theme.radius.sm

            Text {
                id: statusDisplay
                anchors.centerIn: parent
                text: "Toggle any setting to see status"
                font.pixelSize: Theme.typography.fontSize125
                color: Theme.colors.text
            }
        }
    }
}
```

#### 6. Form Integration with Validation

```qml
// Settings form with validation
ColumnLayout {
    id: settingsForm
    spacing: 16

    property bool hasChanges: 
        notificationsToggle.checked !== originalSettings.notifications ||
        autoSaveToggle.checked !== originalSettings.autoSave ||
        analyticsToggle.checked !== originalSettings.analytics

    Text {
        text: "Application Settings"
        font.pixelSize: Theme.typography.fontSize200
        font.weight: Theme.typography.weightSemibold
        color: Theme.colors.text
    }

    UI.Toggle {
        id: notificationsToggle
        leftLabel: "Push notifications"
        checked: originalSettings.notifications
        
        onToggled: validateForm()
    }

    UI.Toggle {
        id: autoSaveToggle
        leftLabel: "Auto-save every 5 minutes"
        checked: originalSettings.autoSave
        
        onToggled: validateForm()
    }

    UI.Toggle {
        id: analyticsToggle
        leftLabel: "Anonymous usage analytics"
        checked: originalSettings.analytics
        
        onToggled: validateForm()
    }

    // Validation feedback
    Rectangle {
        Layout.fillWidth: true
        height: 30
        visible: settingsForm.hasChanges
        color: Theme.colors.warning
        radius: Theme.radius.sm

        Text {
            anchors.centerIn: parent
            text: "⚠️ You have unsaved changes"
            color: Theme.colors.text
            font.pixelSize: Theme.typography.fontSize125
        }
    }

    // Action buttons
    RowLayout {
        Layout.fillWidth: true
        
        Button {
            text: "Reset"
            enabled: settingsForm.hasChanges
            onClicked: resetToDefaults()
        }
        
        Item { Layout.fillWidth: true }
        
        Button {
            text: "Save Changes"
            enabled: settingsForm.hasChanges
            onClicked: saveSettings()
        }
    }

    function validateForm() {
        // Custom validation logic here
        if (notificationsToggle.checked && !analyticsToggle.checked) {
            warningLabel.text = "Notifications work better with analytics enabled"
            warningLabel.visible = true
        } else {
            warningLabel.visible = false
        }
    }
    
    function resetToDefaults() {
        notificationsToggle.checked = originalSettings.notifications
        autoSaveToggle.checked = originalSettings.autoSave
        analyticsToggle.checked = originalSettings.analytics
    }
    
    function saveSettings() {
        originalSettings.notifications = notificationsToggle.checked
        originalSettings.autoSave = autoSaveToggle.checked
        originalSettings.analytics = analyticsToggle.checked
        // Save to persistent storage
        settingsManager.save(originalSettings)
    }
}
```

#### 7. List Items with Toggle Controls

```qml
// Feature list with individual toggles
ListView {
    width: 300
    height: 400
    model: featuresModel
    
    delegate: Rectangle {
        width: ListView.view.width
        height: 60
        color: index % 2 ? Theme.colors.primary900 : Theme.colors.primary800
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            Image {
                source: model.icon
                width: 24
                height: 24
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: model.title
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                }
                
                Text {
                    text: model.description
                    font.pixelSize: Theme.typography.fontSize125
                    color: Theme.colors.textMuted
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            
            UI.Toggle {
                size: "md"
                checked: model.enabled
                onToggled: {
                    model.enabled = checked
                    featuresModel.updateFeature(model.id, checked)
                }
            }
        }
    }
}

// Example model data
ListModel {
    id: featuresModel
    
    ListElement {
        id: "location"
        title: "Location Services"
        description: "Allow app to access your location"
        icon: "qrc:/icons/location.svg"
        enabled: true
    }
    
    ListElement {
        id: "camera"
        title: "Camera Access"
        description: "Enable photo capture and scanning"
        icon: "qrc:/icons/camera.svg" 
        enabled: false
    }
    
    ListElement {
        id: "microphone"
        title: "Microphone Access"
        description: "Allow voice commands and recording"
        icon: "qrc:/icons/microphone.svg"
        enabled: false
    }
}
```

#### 8. Toolbar Quick Actions

```qml
// Toolbar with toggle-based quick actions
Rectangle {
    width: parent.width
    height: 50
    color: Theme.colors.primary900
    border.color: Theme.colors.secondary500
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 16

        Text {
            text: "Quick Actions"
            font.pixelSize: Theme.typography.fontSize150
            color: Theme.colors.text
        }

        Item { Layout.fillWidth: true }

        UI.Toggle {
            size: "sm"
            rightLabel: "Grid"
            checked: viewManager.isGridView
            onToggled: viewManager.setGridView(checked)
        }

        Rectangle {
            width: 1
            height: 30
            color: Theme.colors.secondary500
        }

        UI.Toggle {
            size: "sm"
            rightLabel: "Auto"
            checked: refreshManager.autoRefresh
            onToggled: refreshManager.setAutoRefresh(checked)
        }

        Rectangle {
            width: 1
            height: 30
            color: Theme.colors.secondary500
        }

        UI.Toggle {
            size: "sm"
            rightLabel: "Sound"
            checked: audioManager.soundEnabled
            onToggled: audioManager.setSoundEnabled(checked)
        }
    }
}
```

#### 9. Card-Based Settings Groups

```qml
// Settings organized in cards
ColumnLayout {
    spacing: 16
    
    // Privacy Settings Card
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: privacyColumn.implicitHeight + 32
        color: Theme.colors.primary800
        border.color: Theme.colors.secondary500
        border.width: 1
        radius: Theme.radius.md
        
        ColumnLayout {
            id: privacyColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: "Privacy & Security"
                font.pixelSize: Theme.typography.fontSize175
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }
            
            UI.Toggle {
                leftLabel: "Two-factor authentication"
                checked: securitySettings.twoFactor
                onToggled: securitySettings.twoFactor = checked
            }
            
            UI.Toggle {
                leftLabel: "Encrypted local storage"
                checked: securitySettings.encryption
                onToggled: securitySettings.encryption = checked
            }
            
            UI.Toggle {
                leftLabel: "Anonymous crash reports"
                checked: privacySettings.crashReports
                onToggled: privacySettings.crashReports = checked
            }
        }
    }
    
    // Performance Settings Card
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: performanceColumn.implicitHeight + 32
        color: Theme.colors.primary800
        border.color: Theme.colors.secondary500
        border.width: 1
        radius: Theme.radius.md
        
        ColumnLayout {
            id: performanceColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: "Performance & Storage"
                font.pixelSize: Theme.typography.fontSize175
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }
            
            UI.Toggle {
                leftLabel: "Hardware acceleration"
                checked: performanceSettings.hardwareAccel
                onToggled: performanceSettings.hardwareAccel = checked
            }
            
            UI.Toggle {
                leftLabel: "Background processing"
                checked: performanceSettings.backgroundProcessing
                onToggled: performanceSettings.backgroundProcessing = checked
            }
            
            UI.Toggle {
                leftLabel: "Automatic cache cleanup"
                checked: storageSettings.autoCacheCleanup
                onToggled: storageSettings.autoCacheCleanup = checked
            }
        }
    }
}
```

#### 10. Advanced Custom Integration

```qml
// Custom toggle with extended functionality
Rectangle {
    width: 400
    height: 200
    color: Theme.colors.primary800
    radius: Theme.radius.lg

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "Advanced Network Settings"
            font.pixelSize: Theme.typography.fontSize200
            font.weight: Theme.typography.weightBold
            color: Theme.colors.text
        }

        // Master toggle with dependent settings
        UI.Toggle {
            id: networkMasterToggle
            leftLabel: "Enable advanced networking"
            size: "lg"
            checked: false
            
            onToggled: {
                // Enable/disable dependent toggles
                proxyToggle.enabled = checked
                compressionToggle.enabled = checked
                cachingToggle.enabled = checked
                
                if (!checked) {
                    // Turn off all dependent features
                    proxyToggle.checked = false
                    compressionToggle.checked = false
                    cachingToggle.checked = false
                }
                
                networkManager.setAdvancedMode(checked)
            }
        }

        // Dependent toggles (disabled when master is off)
        ColumnLayout {
            Layout.leftMargin: 20
            spacing: 8

            UI.Toggle {
                id: proxyToggle
                leftLabel: "Use HTTP proxy"
                enabled: networkMasterToggle.checked
                opacity: enabled ? 1.0 : 0.5
                
                onToggled: networkManager.setProxyEnabled(checked)
            }

            UI.Toggle {
                id: compressionToggle
                leftLabel: "Enable compression"
                enabled: networkMasterToggle.checked
                opacity: enabled ? 1.0 : 0.5
                
                onToggled: networkManager.setCompressionEnabled(checked)
            }

            UI.Toggle {
                id: cachingToggle
                leftLabel: "Advanced caching"
                enabled: networkMasterToggle.checked
                opacity: enabled ? 1.0 : 0.5
                
                onToggled: networkManager.setCachingEnabled(checked)
            }
        }

        // Status indicator
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: Theme.colors.secondary500
            radius: Theme.radius.sm

            Text {
                anchors.centerIn: parent
                text: networkMasterToggle.checked ? 
                      "🌐 Advanced networking active" : 
                      "📡 Using standard networking"
                font.pixelSize: Theme.typography.fontSize125
                color: Theme.colors.text
            }
        }
    }
}
```

## Best Practices

### 1. Component Selection and Usage

✅ **Choose Appropriate Sizes**

```qml
// ✅ Small toggles for dense UIs, mobile, compact panels
UI.Toggle { 
    size: "sm"
    leftLabel: "Compact setting"
}

// ✅ Medium toggles for standard desktop interfaces
UI.Toggle { 
    size: "md"  // Default, can be omitted
    leftLabel: "Standard setting"
}

// ✅ Large toggles for accessibility, touch interfaces
UI.Toggle { 
    size: "lg"
    leftLabel: "Important setting"
}

// ❌ Don't use oversized toggles for minor settings
// ❌ Don't use tiny toggles on touch devices
```

### 2. Label Strategy

✅ **Effective Label Usage**

```qml
// ✅ Left labels for settings panels (most common)
UI.Toggle {
    leftLabel: "Enable notifications"
    checked: settings.notifications
}

// ✅ Right labels for status display
UI.Toggle {
    rightLabel: server.isOnline ? "Online" : "Offline"
    checked: server.isOnline
    enabled: false  // Display only
}

// ✅ No labels when context is clear
GridLayout {
    columns: 2
    Text { text: "Notifications:" }
    UI.Toggle { checked: settings.notifications }
}

// ❌ Avoid unclear or redundant labels
UI.Toggle {
    leftLabel: "Toggle this"  // Unclear what it toggles
    rightLabel: "On/Off"     // Redundant with visual state
}
```

### 3. State Management

✅ **Proper State Binding**

```qml
// ✅ Two-way binding with settings objects
UI.Toggle {
    leftLabel: "Dark mode"
    checked: appSettings.darkMode
    onToggled: appSettings.darkMode = checked
}

// ✅ Computed properties for complex logic
UI.Toggle {
    leftLabel: "Master control"
    checked: systemController.allSystemsEnabled
    onToggled: systemController.setAllSystems(checked)
}

// ✅ Validation before state changes
UI.Toggle {
    leftLabel: "Delete files on exit"
    onToggled: {
        if (checked && !userHasConfirmed) {
            confirmationDialog.open()
            checked = false  // Revert until confirmed
        } else {
            destructiveSettings.deleteOnExit = checked
        }
    }
}

// ❌ Avoid direct property manipulation without validation
onToggled: someRandomProperty = checked  // No validation
```

### 4. Performance Optimization

✅ **Efficient Implementation**

```qml
// ✅ Use readonly properties for expensive computations
readonly property bool canEnableFeature: 
    user.hasPermission && system.isReady && !maintenance.active

UI.Toggle {
    leftLabel: "Advanced features"
    enabled: canEnableFeature
    checked: canEnableFeature ? settings.advancedMode : false
}

// ✅ Batch related state changes
function updateNetworkSettings(enabled) {
    // Batch all network-related changes
    settings.networkEnabled = enabled
    settings.proxyEnabled = enabled && settings.proxyEnabled
    settings.compressionEnabled = enabled && settings.compressionEnabled
    settings.save()  // Single save operation
}

// ❌ Avoid creating toggles in loops without delegates
Repeater {
    model: 100
    UI.Toggle { /* Creates 100 toggle instances */ }  // Expensive
}

// ✅ Use ListView with delegates for large lists
ListView {
    delegate: UI.Toggle { /* Only visible items created */ }
}
```

### 5. Accessibility Best Practices

✅ **Accessibility-First Design**

```qml
// ✅ Provide clear, descriptive labels
UI.Toggle {
    leftLabel: "Enable push notifications for new messages"
    // Clear what the toggle controls
}

// ✅ Use appropriate sizes for touch targets
UI.Toggle {
    size: "lg"  // Better for touch interfaces
    leftLabel: "Important system setting"
}

// ✅ Support keyboard navigation (inherited from Qt Switch)
UI.Toggle {
    focus: true  // Can receive keyboard focus
    Keys.onSpacePressed: toggle()  // Space bar activation
}

// ✅ Provide context for screen readers
UI.Toggle {
    leftLabel: "Automatic backups"
    Accessible.description: "When enabled, creates daily backups of your data"
}
```

### 6. Visual Consistency

✅ **Maintain Design System Consistency**

```qml
// ✅ Use theme-provided spacing
ColumnLayout {
    spacing: Theme.spacing.s4  // Consistent spacing
    
    UI.Toggle { leftLabel: "Setting 1" }
    UI.Toggle { leftLabel: "Setting 2" }
    UI.Toggle { leftLabel: "Setting 3" }
}

// ✅ Group related toggles visually
Rectangle {
    color: Theme.colors.primary800  // Consistent background
    border.color: Theme.colors.secondary500
    radius: Theme.radius.md
    
    ColumnLayout {
        // Related privacy settings
        UI.Toggle { leftLabel: "Private browsing" }
        UI.Toggle { leftLabel: "Block trackers" }
        UI.Toggle { leftLabel: "Clear history on exit" }
    }
}

// ❌ Don't mix toggle sizes arbitrarily
ColumnLayout {
    UI.Toggle { size: "sm"; leftLabel: "Setting 1" }
    UI.Toggle { size: "lg"; leftLabel: "Setting 2" }  // Inconsistent
    UI.Toggle { size: "md"; leftLabel: "Setting 3" }
}
```

### 7. Error Handling and Validation

✅ **Robust Error Handling**

```qml
// ✅ Handle toggle failures gracefully
UI.Toggle {
    id: networkToggle
    leftLabel: "Connect to server"
    
    onToggled: {
        if (checked) {
            networkManager.connect().then(
                function(success) {
                    if (!success) {
                        // Revert on failure
                        checked = false
                        errorMessage.show("Failed to connect to server")
                    }
                }
            )
        } else {
            networkManager.disconnect()
        }
    }
}

// ✅ Provide immediate feedback for long operations
UI.Toggle {
    leftLabel: "Sync with cloud"
    enabled: !syncInProgress
    
    onToggled: {
        syncInProgress = true
        cloudSync.start(checked).finally(function() {
            syncInProgress = false
        })
    }
}

// ✅ Validate dependent settings
UI.Toggle {
    id: encryptionToggle
    leftLabel: "Enable encryption"
    
    onToggled: {
        if (checked && !securityModule.available) {
            checked = false
            warningDialog.show("Encryption module not available")
            return
        }
        
        securitySettings.encryption = checked
    }
}
```

## Troubleshooting

### Common Issues & Solutions

1. **"ReferenceError: ToggleStyles is not defined"**

**Problem**: Toggle component can't find the ToggleStyles singleton.

**Root Causes:**
- CMakeLists.txt not properly configured
- Singleton not registered correctly
- Build cache issues

**Solutions:**
```cmake
# ✅ Verify CMakeLists.txt configuration
set(qml_singletons
    toggle/ToggleStyles.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES ${qml_files}
    # ✅ Ensure singletons are included
)
```

**Debug Steps:**
```qml
// Check if singleton is available
Component.onCompleted: {
    console.log("ToggleStyles available:", typeof ToggleStyles)
    console.log("ToggleStyles.Primary:", ToggleStyles.Primary)
}
```

**Quick Fix:**
1. Clean build directory completely
2. Rebuild project from scratch
3. Verify imports in Toggle.qml: `import App.Components 1.0`

2. **Toggle Not Responding to Clicks**

**Problem**: Toggle visually appears but doesn't respond to user interaction.

**Debug Steps:**
```qml
UI.Toggle {
    onClicked: console.log("Toggle clicked")  // Check if signal fires
    onToggled: console.log("Toggle toggled, new state:", checked)
    
    MouseArea {
        anchors.fill: parent
        onClicked: console.log("MouseArea clicked")  // Check if area is accessible
    }
}
```

**Common Solutions:**
```qml
// ✅ Ensure toggle is enabled
UI.Toggle {
    enabled: true  // Explicitly set if unsure
    leftLabel: "My setting"
}

// ✅ Check parent clipping
Rectangle {
    clip: false  // Don't clip toggle area
    UI.Toggle { /* ... */ }
}

// ✅ Verify z-order
UI.Toggle {
    z: 1  // Bring to front if covered by other elements
}
```

3. **Animation Performance Issues**

**Problem**: Toggle animations are choppy or slow.

**Debug Steps:**
```javascript
// Profile animation performance
console.time("toggle-animation")
toggle.checked = !toggle.checked
// Check if completes within 150-200ms
console.timeEnd("toggle-animation")
```

**Performance Solutions:**
```qml
// ✅ Use hardware acceleration hints
Rectangle {
    // Knob element
    layer.enabled: true  // Enable hardware layer
    layer.samples: 4     // Anti-aliasing
    
    Behavior on x {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic  // Smooth easing
        }
    }
}

// ✅ Optimize color animations
color: root._backgroundColor  // Use computed property
Behavior on color {
    ColorAnimation {
        duration: 150
        // Don't animate alpha separately
    }
}

// ❌ Avoid complex bindings in animations
color: {
    // Complex computation in every frame
    let result = Theme.colors.accent500
    if (!root.enabled) {
        result = Qt.darker(result, 1.5)
    }
    return result
}
```

4. **Size Configuration Not Applied**

**Problem**: Toggle appears with wrong dimensions despite size property.

**Debug Steps:**
```qml
UI.Toggle {
    size: "lg"
    Component.onCompleted: {
        console.log("Requested size:", size)
        console.log("Size config:", JSON.stringify(_sizeStyles))
        console.log("Actual dimensions:", width + "x" + height)
    }
}
```

**Solutions:**
```qml
// ✅ Verify size string is correct
UI.Toggle {
    size: "lg"  // Not "large" or "LG"
}

// ✅ Check if parent constrains size
Item {
    width: 100   // Parent width
    height: 50   // Parent height
    
    UI.Toggle {
        size: "lg"  // May be constrained by parent
        anchors.fill: parent  // Remove if size should be implicit
    }
}

// ✅ Use explicit sizing when needed
UI.Toggle {
    size: "lg"
    width: _sizeStyles.width    // Force explicit sizing
    height: _sizeStyles.height
}
```

5. **Theme Colors Not Applied**

**Problem**: Toggle shows incorrect colors or falls back to defaults.

**Debug Steps:**
```qml
// Check theme availability
Component.onCompleted: {
    console.log("Theme object:", typeof Theme)
    console.log("Colors available:", typeof Theme.colors)
    console.log("Accent color:", Theme.colors?.accent500)
    console.log("Style object:", _style)
    console.log("Background color:", _style?.background)
}
```

**Solutions:**
```qml
// ✅ Verify theme import
import App.Themes 1.0  // Must be imported

// ✅ Provide fallback colors during development
readonly property ToggleStyle _style: ToggleStyles.fromVariant(variant) || QtObject {
    property color background: "#666666"
    property color backgroundChecked: "#0066CC" 
    property color backgroundDisabled: "#333333"
    property color knob: "#FFFFFF"
    property color knobDisabled: "#999999"
}

// ✅ Check theme module is linked
// In CMakeLists.txt:
target_link_libraries(app_components
    PRIVATE
    app_themes  # Must be linked
    Qt6::Quick
)
```

6. **Label Positioning Issues**

**Problem**: Labels not appearing or positioned incorrectly.

**Debug Steps:**
```qml
UI.Toggle {
    leftLabel: "Test Label"
    Component.onCompleted: {
        console.log("Left label text:", leftLabel)
        console.log("ContentItem children:", contentItem.children.length)
    }
    
    // Debug contentItem
    contentItem: Row {
        spacing: Theme.spacing.s2
        
        Text {
            visible: root.leftLabel !== ""
            text: root.leftLabel
            color: "red"  // Make visible for debugging
            
            Component.onCompleted: {
                console.log("Left label visible:", visible)
                console.log("Left label text:", text)
            }
        }
        
        Item { 
            width: root._sizeStyles.width
            height: root._sizeStyles.height
            
            Rectangle {
                anchors.fill: parent
                color: "blue"  // Debug spacer area
                opacity: 0.3
            }
        }
        
        Text {
            visible: root.rightLabel !== ""
            text: root.rightLabel
            color: "green"  // Make visible for debugging
        }
    }
}
```

**Common Solutions:**
```qml
// ✅ Ensure labels have content
UI.Toggle {
    leftLabel: "Enable feature"  // Non-empty string
    rightLabel: ""              // Empty = not visible
}

// ✅ Check parent width is sufficient
Rectangle {
    width: 200  // Adequate width for toggle + labels
    UI.Toggle {
        leftLabel: "Long setting description"
    }
}

// ✅ Handle text overflow
UI.Toggle {
    leftLabel: "Very long label that might overflow"
    contentItem: Row {
        Text {
            visible: root.leftLabel !== ""
            text: root.leftLabel
            wrapMode: Text.WordWrap  // Handle overflow
            maximumLineCount: 2
            Layout.fillWidth: true
        }
        // ... rest of contentItem
    }
}
```

### Debugging Commands

**Component State Inspection**
```javascript
// Toggle state debugging
function debugToggle(toggle) {
    console.log("Toggle Debug Info:")
    console.log("- Checked:", toggle.checked)
    console.log("- Enabled:", toggle.enabled)
    console.log("- Size:", toggle.size)
    console.log("- Variant:", toggle.variant)
    console.log("- Left label:", toggle.leftLabel)
    console.log("- Right label:", toggle.rightLabel)
    console.log("- Dimensions:", toggle.width + "x" + toggle.height)
    console.log("- Style available:", typeof toggle._style)
    console.log("- Size config:", JSON.stringify(toggle._sizeStyles))
}

// Usage
debugToggle(myToggle)
```

**Animation Performance Testing**
```javascript
// Test animation smoothness
function testToggleAnimation(toggle) {
    console.time("toggle-animation")
    let startTime = Date.now()
    
    toggle.checked = !toggle.checked
    
    // Check completion after animation duration
    Timer {
        interval: 200  // Animation + buffer
        running: true
        onTriggered: {
            console.timeEnd("toggle-animation")
            let endTime = Date.now()
            console.log("Animation took:", endTime - startTime, "ms")
            console.log("Expected: ~150ms")
        }
    }
}
```

**Style System Verification**
```javascript
// Verify style system integrity
function verifyToggleStyles() {
    console.log("ToggleStyles Verification:")
    console.log("- Singleton available:", typeof ToggleStyles)
    console.log("- Primary variant:", ToggleStyles.Primary)
    console.log("- fromVariant function:", typeof ToggleStyles.fromVariant)
    console.log("- sizeConfig function:", typeof ToggleStyles.sizeConfig)
    
    // Test variant resolution
    let primaryStyle = ToggleStyles.fromVariant(ToggleStyles.Primary)
    console.log("- Primary style resolved:", typeof primaryStyle)
    console.log("- Background color:", primaryStyle?.background)
    
    // Test size resolution  
    let mediumSize = ToggleStyles.sizeConfig("md")
    console.log("- Medium size config:", JSON.stringify(mediumSize))
}
```

## Conclusion

The Toggle component demonstrates a sophisticated variant-based architecture focused on clean styling and size management:

### Key Architectural Benefits

- **Centralized Styling**: All visual decisions managed through ToggleStyles singleton
- **Flexible Sizing**: Consistent size system that works across different UI contexts
- **Theme Integration**: Full integration with centralized design system
- **Performance Optimized**: Smooth animations with minimal property binding overhead
- **Accessibility Ready**: Built on Qt Switch foundation for robust accessibility
- **Clean Architecture**: Simple variant system focused on primary use case

### Production-Ready Features

- **Comprehensive Size Support**: Small, medium, and large variants for different contexts
- **Label Integration**: Built-in support for left and right labels with automatic layout
- **Smooth Animations**: Hardware-accelerated transitions for professional feel
- **Robust State Management**: Proper binding patterns with validation support
- **Theme Consistency**: Automatic color and typography from centralized theme
- **Developer Experience**: Clear API with excellent debugging capabilities

### Development Benefits

- **Maintainable Architecture**: Separation of concerns between behavior and appearance
- **Easy Customization**: Add new sizes with minimal code changes
- **Performance Monitoring**: Built-in debugging tools for animation and state tracking  
- **Type Safety**: Enum-based variant system prevents invalid configurations
- **Documentation**: Self-documenting API with clear usage patterns
- **Team Collaboration**: Centralized styling enables consistent implementation across developers

This architecture provides a solid foundation for any application requiring toggle/switch controls, from simple settings panels to complex configuration interfaces, while maintaining excellent performance and user experience at scale.

The Toggle component exemplifies modern QML component design principles: clean separation of concerns, centralized configuration management, smooth user interactions, and developer-friendly APIs that scale from simple on/off switches to complex settings interfaces.
