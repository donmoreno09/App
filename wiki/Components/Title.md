# Qt Dynamic Title Component - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Why This Approach?](#why-this-approach)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Core Components](#core-components)
5. [Qt Property Binding System](#qt-property-binding-system)
6. [Implementation Details](#implementation-details)
7. [Workflow & Process](#workflow--process)
8. [Building & Running](#building--running)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Project Overview

This Qt 6 application demonstrates a production-ready dynamic title management system with centralized state control and automatic UI updates. The component provides smooth fade animations, glow visual effects, and seamless integration with Qt's property binding system.

### Key Features

- **Dynamic Title Updates**: Change titles at runtime with smooth fade animations
- **Centralized State Management**: TitleBarController singleton manages all title state
- **Visual Feedback**: Glow effects using Qt5Compat.GraphicalEffects
- **Theme Integration**: Full integration with existing design token system
- **Property Binding**: Automatic UI updates when TitleBarController state changes
- **Modular Architecture**: Clean separation between TitleBar controller and Components UI

## Why This Approach?

### Traditional Problems with Direct Title Management

❌ **Common Problematic Approach:**
```qml
// Hard-coded titles scattered throughout code
Text { text: "Mission Planning" }
Text { text: "Navigation Map" }
// No centralized management, inconsistent updates
```

### Issues with Direct Title Management:
- **Scattered Logic**: Title updates spread across multiple components
- **Inconsistent State**: Different parts of UI showing different titles
- **Manual Updates**: Each navigation change requires manual title updates
- **No Animation**: Abrupt title changes without smooth transitions
- **Difficult Testing**: No centralized point to verify title behavior

✅ **Our Solution: TitleBarController Singleton with Property Binding**

### Benefits of This Approach:

**1. Centralized Management**
```qml
// All title logic in TitleBarController singleton
TitleBarController.setTitle("Mission Planning")
// Automatically updates all bound components
```

**2. Automatic UI Updates**
```qml
// Components automatically update via property binding
Text { text: TitleBarController.currentTitle }
// No manual update calls needed
```

**3. Smooth Fade Animations**
```qml
// Built-in fade animations for title changes
SequentialAnimation on opacity {
    PropertyAnimation { to: 0; duration: 200 }
    PauseAnimation { duration: 200 }
    PropertyAnimation { to: 1; duration: 1000 }
}
```

**4. Visual Glow Effects**
```qml
// Glow effects provide professional appearance
import Qt5Compat.GraphicalEffects
Glow {
    source: glowRect
    color: "#5281c6f0"
    radius: 8
}
```

## Architecture & Design Patterns

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Navigation    │───▶│ TitleBarController│───▶│  Title Component│
│   Components    │    │   (Singleton)     │    │   (UI Display)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
    User Actions              State Storage         Visual Rendering
    (Button clicks)           (currentTitle)     (Text + Glow Effect)
         │                       │                       │
         └──── Property Binding ─┴──── Signal/Slot ─────┘
             (QML auto-updates via property changes)
```

### Design Patterns Used

**1. Singleton Pattern (TitleBarController)**
```qml
// App/Features/TitleBar/TitleBarController.qml
pragma Singleton
import QtQuick 6.8

QtObject {
    property string currentTitle: "Overview"
    function setTitle(title) { /* implementation */ }
}
```
*Why?* Global access to title management from any component.

**2. Observer Pattern (Qt Property Binding)**
```qml
// UI automatically observes TitleBarController changes
Text { text: TitleBarController.currentTitle }
// Updates automatically when currentTitle changes
```
*Why?* Decoupled UI updates when title state changes.

**3. Command Pattern (Title Updates)**
```qml
// Navigation components issue title change commands
Button {
    onClicked: TitleBarController.setTitle("New Title")
}
```
*Why?* Clean separation between UI actions and state changes.

**4. Template Method Pattern (Animation Sequence)**
```qml
SequentialAnimation on opacity {
    PropertyAnimation { to: 0; duration: 200 }    // Fade out
    PauseAnimation { duration: 200 }              // Brief pause  
    PropertyAnimation { to: 1; duration: 1000 }   // Fade in
}
```
*Why?* Consistent animation behavior across all title changes.

## Core Components

### 1. TitleBarController (Singleton)

**Purpose:** Central title state management with automatic UI notifications.

**File:** `App/Features/TitleBar/TitleBarController.qml`

**Key Responsibilities:**
- Title state storage and management
- Validation of title changes
- Automatic property change notifications
- Integration with Qt's property binding system

```qml
pragma Singleton
import QtQuick 6.8

QtObject {
    id: titleBarController
    
    // Current title state - components bind to this property
    property string currentTitle: "Overview"
    
    // Primary method for title updates
    function setTitle(title) {
        if (currentTitle !== title) {
            currentTitle = title
        }
    }
}
```

**Qt Integration Features:**
- **Property Binding**: QML components automatically update when `currentTitle` changes
- **Type Safety**: QString ensures proper string handling
- **Change Notifications**: Qt's property system automatically emits change signals

### 2. Title Component (UI Display)

**Purpose:** Visual presentation of title with fade animations and glow effects.

**File:** `App/Components/Title.qml`

**Key Responsibilities:**
- Visual rendering of current title
- Smooth fade animations during title changes  
- Glow effects for visual feedback
- Integration with theme system

```qml
import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects
import App.Themes 1.0
import App.Features.TitleBar 1.0

Rectangle {
    color: "transparent"
    
    Text {
        id: titleText
        anchors.centerIn: parent
        text: TitleBarController.currentTitle  // Property binding
        color: Theme.colors.text
        font.pointSize: Theme.typography.sizeSm
        opacity: 0
        
        // Fade animation sequence
        SequentialAnimation on opacity {
            id: fadeAnim
            running: false
            PropertyAnimation { to: 0; duration: 0 }
            PauseAnimation { duration: 200 }
            PropertyAnimation { to: 1; duration: 1000 }
        }
        
        onTextChanged: fadeAnim.restart()
    }
    
    // Visual indicator rectangle
    Rectangle {
        id: glowRect
        anchors.top: titleText.bottom
        anchors.horizontalCenter: titleText.horizontalCenter
        anchors.topMargin: 4
        width: 16
        height: 4
        topLeftRadius: Theme.radius.sm
        topRightRadius: Theme.radius.sm
        color: Theme.colors.primaryText
    }
    
    // Glow effect using Qt5Compat
    Glow {
        id: titleGlowEffect
        source: glowRect
        anchors.fill: glowRect
        color: "#5281c6f0"
        radius: 8
    }
}
```

### 3. CMake Integration

**Purpose:** Build system configuration for modular architecture.

**TitleBar Module (Controller):**
```cmake
# App/Features/TitleBar/CMakeLists.txt
set(qml_files
    TitleBar.qml
)

set(cpp_singletons
    WindowsNcController.h
    WindowsNcController.cpp
)

set(qml_singletons
    TitleBarController.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_singletons}
)

target_link_libraries(app_features_titlebar
    PRIVATE
        Qt6::Quick
)
```

**Components Module (UI):**
```cmake
# App/Components/CMakeLists.txt
set(qml_files
    Button.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalPadding.qml
    VerticalPadding.qml
    HorizontalSpacer.qml
    VerticalSpacer.qml
    Title.qml                    # Title component here
    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCES ${icon_resources}
)
```

## Qt Property Binding System

### Property Binding Fundamentals

**Problem:** How do UI components know when TitleBarController state changes?

**Solution:** Qt's property binding system provides automatic updates.

```qml
// Binding establishment
Text { text: TitleBarController.currentTitle }

// When this happens in controller:
currentTitle = "New Title"

// Qt automatically:
// 1. Detects property change
// 2. Notifies all bound components  
// 3. Updates UI immediately
// 4. Triggers animations if defined
```

### Animation Integration

**Property-Driven Fade Animation:**
```qml
Text {
    text: TitleBarController.currentTitle
    opacity: 0
    
    // Specific animation sequence from your implementation
    SequentialAnimation on opacity {
        id: fadeAnim
        running: false
        PropertyAnimation { to: 0; duration: 0 }
        PauseAnimation { duration: 200 }
        PropertyAnimation { to: 1; duration: 1000 }
    }
    
    // Restart animation when text changes
    onTextChanged: fadeAnim.restart()
}
```

**Why This Timing?**
- **Initial State (0 opacity)**: Text starts invisible
- **Pause (200ms)**: Brief delay before fade-in begins
- **Fade In (1000ms)**: Slow, smooth appearance of new title
- **Total Experience**: Professional, readable transition

## Implementation Details

### Singleton Registration

**CMake Configuration:**
```cmake
# Mark QML file as singleton
set_source_files_properties(
    TitleBarController.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# Include in TitleBar module
qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar
    QML_FILES TitleBarController.qml
)
```

**QML Singleton Declaration:**
```qml
pragma Singleton
import QtQuick 6.8

QtObject {
    id: titleBarController
    property string currentTitle: "Overview"
    function setTitle(title) {
        if (currentTitle !== title) {
            currentTitle = title
        }
    }
}
```

**What This Enables:**
1. **Global Access**: Available from any QML component via `import App.Features.TitleBar 1.0`
2. **Single Instance**: Only one TitleBarController instance exists
3. **Automatic Loading**: Qt creates instance on first access
4. **Memory Efficiency**: Shared across all components

### Glow Effect Implementation

**Qt5Compat Dependency:**
```qml
import Qt5Compat.GraphicalEffects

Rectangle {
    id: glowRect
    color: Theme.colors.primaryText
    // ... positioning and sizing
}

Glow {
    id: titleGlowEffect
    source: glowRect           // Source rectangle to glow
    anchors.fill: glowRect     // Same size as source
    color: "#5281c6f0"         // Semi-transparent blue
    radius: 8                  // Glow spread radius
}
```

**Effect Configuration:**
- **Source**: The `glowRect` Rectangle provides the shape to glow
- **Color**: `#5281c6f0` creates a semi-transparent blue glow
- **Radius**: `8` pixels provides subtle but visible glow spread
- **Performance**: GPU-accelerated when available

### Animation Sequence Breakdown

**Your Specific Implementation:**
```qml
SequentialAnimation on opacity {
    id: fadeAnim
    running: false
    PropertyAnimation { to: 0; duration: 0 }      // Instant reset
    PauseAnimation { duration: 200 }              // 200ms pause
    PropertyAnimation { to: 1; duration: 1000 }   // 1000ms fade in
}
onTextChanged: fadeAnim.restart()
```

**Timing Analysis:**
- **Instant Reset**: Immediately hides text when change occurs
- **200ms Pause**: Brief moment for visual separation
- **1000ms Fade**: Slow, readable appearance of new title
- **Total Duration**: 1200ms for complete transition

## Workflow & Process

### Development Workflow

**1. Title Integration**
```qml
// Import TitleBarController in navigation components
import App.Features.TitleBar 1.0

Button {
    text: "Mission"
    onClicked: {
        TitleBarController.setTitle("Mission Planning")
        // ... navigation logic
    }
}
```

**2. Title Component Usage**
```qml
// Use Title component in layouts
import App.Components 1.0

RowLayout {
    // ... other components
    Title { }  // Automatically shows current title
    // ... other components
}
```

**3. Testing Integration**
```qml
// Test title updates
Component.onCompleted: {
    console.log("Initial:", TitleBarController.currentTitle)
    TitleBarController.setTitle("Test")
}
```

### Adding New Navigation Sections

**Example: Adding Analytics Section**

**Step 1: Update navigation handler**
```qml
function navigateToAnalytics() {
    TitleBarController.setTitle("Analytics Dashboard")
    stackView.push("AnalyticsPage.qml")
}
```

**Step 2: Connect to UI button**
```qml
Button {
    text: "Analytics"
    onClicked: navigateToAnalytics()
}
```

**Result:** Analytics navigation now updates title with fade animation automatically.

## Building & Running

### Prerequisites

- **Qt 6.8+**: Core framework with QML and property binding
- **CMake 3.16+**: Build system with Qt module support
- **C++17 Compiler**: For Qt framework compatibility
- **Qt5Compat.GraphicalEffects**: Required for Glow effects

### Build Commands

```bash
# Configure build system
cmake -B build -S .

# Build project (compiles QML modules)
cmake --build build

# Run application
./build/Debug/IRIDESS_FE.exe  # Windows
./build/IRIDESS_FE            # Linux/macOS
```

### Verification Steps

**1. Check Module Registration**
```bash
# Verify TitleBar module built correctly
ls build/*/App/Features/TitleBar/
# Should contain: qmldir, TitleBarController.qmlc

# Verify Components module built correctly
ls build/*/App/Components/
# Should contain: qmldir, Title.qmlc
```

**2. Test Title Updates**
- Start application (should show "Overview" with glow effect)
- Navigate using SideRail buttons
- Watch for fade animation: text disappears, pause, then fades in
- Verify glow effect is visible around small rectangle

**3. Console Verification**
Expected output when clicking navigation:
```
Language button clicked
Title changed to: Language Settings
```

## Best Practices

### 1. TitleBarController Usage

**✅ Good Practices**
```qml
// Import controller properly
import App.Features.TitleBar 1.0

// Use descriptive titles
TitleBarController.setTitle("Mission Planning")

// Update before navigation
function navigateToSection(section) {
    TitleBarController.setTitle(getSectionTitle(section))
    performNavigation(section)
}
```

**❌ Avoid**
```qml
// Missing import
TitleBarController.setTitle("Title")  // Error: not defined

// Vague titles  
TitleBarController.setTitle("Page 2")

// Navigation without title update
stackView.push("NewPage.qml")  // Title stays old
```

### 2. Animation Performance

**✅ Optimize Animations**
```qml
// Use your specific timing
SequentialAnimation on opacity {
    running: false  // Only run when triggered
    PropertyAnimation { to: 0; duration: 0 }
    PauseAnimation { duration: 200 }
    PropertyAnimation { to: 1; duration: 1000 }
}

// Trigger efficiently
onTextChanged: fadeAnim.restart()  // Only on actual changes
```

**Performance Benefits:**
- **GPU Acceleration**: Glow effects use GPU when available
- **Efficient Triggering**: Animation only runs on text changes
- **Single Controller**: Shared instance reduces memory usage

### 3. Module Organization

**✅ Recommended Structure**
```
App/Features/TitleBar/
├── TitleBarController.qml    # Singleton controller
├── TitleBar.qml             # Main title bar UI
├── WindowsNcController.h/.cpp # Window controls
└── CMakeLists.txt           # Module build config

App/Components/
├── Title.qml               # Title display component
├── Button.qml              # Other reusable components
└── CMakeLists.txt         # Components build config
```

**Benefits:**
- **Clear Separation**: Controller logic in TitleBar module, UI in Components
- **Reusability**: Title component can be used in any layout
- **Maintainability**: Related functionality grouped together

## Troubleshooting

### Common Issues & Solutions

**1. "TitleBarController is not defined"**

**Problem:** QML cannot find the TitleBarController singleton.

**Solutions:**
```qml
// ✅ Ensure correct import
import App.Features.TitleBar 1.0

// ✅ Verify CMakeLists.txt in App/Features/TitleBar/
set_source_files_properties(TitleBarController.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

// ✅ Check module URI matches import
qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar  # Must match import exactly
```

**2. Title Updates But No Fade Animation**

**Problem:** Text changes but fade animation doesn't trigger.

**Debug Steps:**
```qml
Text {
    text: TitleBarController.currentTitle
    opacity: 0  // ✅ Must start at 0
    
    SequentialAnimation on opacity {
        id: fadeAnim
        running: false  // ✅ Must be false initially
        PropertyAnimation { to: 0; duration: 0 }
        PauseAnimation { duration: 200 }
        PropertyAnimation { to: 1; duration: 1000 }
    }
    
    onTextChanged: {
        console.log("Text changed to:", text)
        fadeAnim.restart()  // ✅ Must call restart()
    }
}
```

**3. Glow Effect Not Visible**

**Problem:** Glow component exists but no visual effect appears.

**Solutions:**
```qml
// ✅ Verify Qt5Compat import
import Qt5Compat.GraphicalEffects

// ✅ Check source rectangle properties
Rectangle {
    id: glowRect
    color: Theme.colors.primaryText  // Must have visible color
    width: 16                        // Must have size
    height: 4                        // Must have size
}

// ✅ Configure glow properly
Glow {
    source: glowRect              // Must reference existing rectangle
    anchors.fill: glowRect        // Must have proper anchoring
    color: "#5281c6f0"           // Semi-transparent for effect
    radius: 8                     // Appropriate radius (4-12 typical)
}
```

**4. Module Build Errors**

**Problem:** CMake can't find or build QML modules.

**Debug Steps:**
```bash
# Check Qt6 QML tools installation
find /path/to/qt -name "qmlcachegen"
find /path/to/qt -name "Qt6QmlMacros.cmake"

# Clean build to resolve cache issues
rm -rf build/
cmake -B build -S .
cmake --build build --verbose

# Check module output
find build/ -name "qmldir"
find build/ -name "*.qmlc"
```

**5. Animation Overlap Issues**

**Problem:** Multiple rapid title changes cause animation conflicts.

**Solutions:**
```qml
// ✅ Your implementation handles this correctly
onTextChanged: fadeAnim.restart()  // restart() stops current and begins new

// ✅ Verify animation state
SequentialAnimation {
    id: fadeAnim
    running: false  // Important: only run when explicitly started
    
    onRunningChanged: {
        console.log("Animation running:", running)
    }
}
```

### Debugging Commands

```bash
# Check TitleBar module compilation
find build/ -path "*/TitleBar/*.qmlc"
find build/ -path "*/TitleBar/qmldir"

# Check Components module compilation  
find build/ -path "*/Components/*.qmlc"
find build/ -path "*/Components/qmldir"

# Verify Qt5Compat availability
find /path/to/qt -name "*Qt5Compat*"

# Test QML syntax independently
qmlscene App/Components/Title.qml  # May not work due to dependencies
```

## Conclusion

This Qt Dynamic Title Component demonstrates a production-ready approach to centralized title management with:

- **TitleBarController Singleton**: Centralized state management with global access
- **Automatic Property Binding**: UI components update automatically via Qt's property system  
- **Smooth Fade Animations**: Professional 1200ms transition sequence (200ms pause + 1000ms fade)
- **Glow Visual Effects**: Qt5Compat.GraphicalEffects provides polished appearance
- **Modular Architecture**: Clean separation between TitleBar controller and Components UI
- **Theme Integration**: Uses existing design token system for consistent styling
- **CMake Integration**: Proper QML module configuration with singleton registration

The architecture scales well for larger applications and demonstrates best practices for Qt QML singleton controllers, property binding, and visual effects integration.
