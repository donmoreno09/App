# SidePanel System - Explanation and Workflow

## Overview

The SidePanel system is a modular navigation framework that provides a slide-out panel interface for the Title application. It implements a routing-based architecture with lifecycle management and smooth animations.

## File Structure

```
App/Features/SidePanel/
├── SidePanel.qml               # Main container component
├── SidePanelController.qml     # Singleton state controller
├── PanelRouter.qml            # Singleton navigation manager
├── routes.js                  # Route configuration
├── BasePanel.qml              # Base layout component
├── PanelTemplate.qml          # Standardized panel template
├── NotFoundPanel.qml          # Fallback error panel
└── CMakeLists.txt             # Build configuration
```

## Core Components

### 1. SidePanel.qml
**Purpose**: Main container and integration point
- Contains StackView for navigation
- Manages language change transitions
- Attaches to SidePanelController on initialization
- Handles transition animations during language switches

**Key Features**:
- Disables transitions during language changes for smooth UX
- Connects to LanguageController for internationalization

### 2. SidePanelController.qml (Singleton)
**Purpose**: Central state management and API
- Manages panel open/closed state (`isOpen` property)
- Provides public methods: `open()`, `close()`, `toggle()`
- Emits lifecycle signals (currently unused)
- Controls panel visibility

**Methods**:
```qml
open(path, props)    // Opens panel with specified route
close()              // Closes panel
toggle(path, props)  // Toggles panel or switches route
attach(sidePanel)    // Links to SidePanel instance
```

**Signals** (Future Implementation):
```qml
willOpen(), didOpen(), willClose(), didClose()
routeChanged(string path)
navigationError(string path, string reason)
```

### 3. PanelRouter.qml (Singleton)
**Purpose**: Navigation and routing management
- Manages StackView operations
- Maintains navigation history via internal `_pathStack`
- Resolves routes using routes.js
- Provides stack manipulation methods

**Methods**:
```qml
push(path, props)           // Add new panel to stack
pop()                      // Remove current panel
replace(path, props)       // Clear stack and load panel
replaceCurrent(path, props) // Replace current panel only
clear()                    // Clear entire stack
```

### 4. routes.js
**Purpose**: Route-to-file mapping configuration
```javascript
const routes = {
  "language": "qrc:/App/Features/Language/LanguagePanel.qml",
  "mission":  "qrc:/App/Features/Mission/MissionPanel.qml",
  "*":        "qrc:/App/Features/SidePanel/NotFoundPanel.qml"  // fallback
};
```

### 5. BasePanel.qml
**Purpose**: Layout foundation for all panels
- Provides header/content/footer slots
- Base class for panel implementations

### 6. PanelTemplate.qml
**Purpose**: Standardized panel with common UI elements
- Extends BasePanel
- Includes title and close button
- Uses Theme system for consistent styling
- Automatically connects close button to `SidePanelController.close()`

### 7. NotFoundPanel.qml
**Purpose**: Error handling for unknown routes
- Uses PanelTemplate with localized "Panel Not Found" message
- Fallback when route resolution fails

## Workflow and Navigation

### 1. Initialization Flow
```
SidePanel.qml loads
  ↓
StackView created
  ↓
PanelRouter.stackView = stackView
  ↓
SidePanelController.attach(sidePanel)
```

### 2. Panel Opening Flow
```
User action (e.g., SideRail button click)
  ↓
SidePanelController.toggle("route")
  ↓
PanelRouter.replace("route")
  ↓
routes.js.resolve("route") → QML file URL
  ↓
StackView loads component
  ↓
Panel renders with props
```

### 3. Navigation Stack Management
```
PanelRouter maintains:
- stackView: Reference to StackView component
- currentPath: Current route string
- _pathStack: Internal path history array

Operations update both StackView and _pathStack in sync
```

### 4. Language Change Handling
```
LanguageController.onLanguageChanged()
  ↓
SidePanel temporarily disables transitions
  ↓
PanelRouter.replaceCurrent(currentPath)
  ↓
Current panel reloads with new language
  ↓
Transitions re-enabled
```

## Integration Points

### SideRail Integration
**File**: `App/Features/SideRail/SideRail.qml`
- Uses `SidePanelController.isOpen` for active states
- Calls `SidePanelController.toggle()` on item clicks
- Visual indicators based on `PanelRouter.currentPath`

### Main Layout Integration  
**File**: `App/Main.qml:106`
- Slide animation based on `SidePanelController.isOpen`
- X-position animation: `0` (open) to `-panelWidth` (closed)
- 220ms OutCubic easing transition

### TitleBar Integration
**File**: `App/Features/TitleBar/TitleBar.qml:41`
- Language button calls `SidePanelController.toggle("language")`

## Current Limitations

### Unused Signals
The SidePanelController lifecycle signals are **defined and emitted but not consumed**:
- `willOpen()`, `didOpen()`, `willClose()`, `didClose()`
- Available for future implementations (logging, analytics, plugins)

### Route Configuration
- Routes are statically defined in routes.js
- No dynamic route registration
- Limited to predefined panel types

## Usage Examples

### Opening a Panel
```qml
// From any component
SidePanelController.open("mission", { title: "Custom Title" })
```

### Toggle Panel
```qml
// Toggle between open/closed or switch routes
SidePanelController.toggle("language")
```

### Creating a New Panel
1. Create QML file extending PanelTemplate or BasePanel
2. Add route to routes.js
3. Use standard navigation methods

### Listening to State Changes
```qml
// Monitor panel state
Connections {
    target: SidePanelController
    function onIsOpenChanged() {
        console.log("Panel is now:", SidePanelController.isOpen ? "open" : "closed")
    }
}
```

## Architecture Benefits

1. **Separation of Concerns**: Clear division between routing, state, and UI
2. **Extensibility**: Easy to add new panels via routes.js
3. **Consistency**: PanelTemplate ensures uniform panel design
4. **Internationalization**: Built-in language change handling
5. **Animation Ready**: Smooth transitions with state-driven animations
6. **Future-Proof**: Signal infrastructure for advanced features

## Build Configuration

The CMakeLists.txt configures the QML module:
- URI: `App.Features.SidePanel`
- Singleton types: PanelRouter, SidePanelController
- Standard QML files included as module resources