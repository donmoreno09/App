# Qt Date-Time Picker Component

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

This Qt 6 Date-Time Picker component provides a production-ready, highly modular date and time selection interface with comprehensive support for single dates, date ranges, and combined date-time workflows. The component features a modern dark theme design, micro-component architecture, and flexible integration patterns for various use cases.

### Key Features

- **Micro-Component Architecture**: Decomposed into specialized, reusable sub-components
- **Multiple Selection Modes**: Single date, date range, time-only, and combined date-time
- **Dual Time Format Support**: 24-hour and 12-hour (AM/PM) time formats
- **Range Selection with Visual Feedback**: Continuous pill-like range highlighting
- **Standalone & Embedded Modes**: Adaptable for different container requirements
- **Theme Integration**: Full integration with App.Themes system for consistent styling
- **Responsive Layout**: Adapts to different screen sizes with proper spacing constraints


## Why This Approach?

### Traditional Problems with Monolithic Date Pickers

❌ **Common Problematic Approach:**
```qml
// Monolithic date picker with everything inline
Rectangle {
    // 500+ lines of mixed concerns:
    // - Calendar rendering
    // - Time selection
    // - Range logic
    // - Navigation
    // - Styling
    // - Event handling
}
```

**Issues with Monolithic Date Picker Systems:**
- **Massive Single Files**: 1000+ line components that are impossible to maintain
- **Mixed Responsibilities**: Calendar logic mixed with time picker mixed with styling
- **Poor Reusability**: Can't use calendar without time picker, or time without date
- **Testing Nightmare**: Unit testing requires testing everything at once
- **Styling Inconsistency**: Duplicate styling code across similar components
- **Performance Issues**: All functionality loaded even when only date selection is needed
- **Developer Confusion**: New team members overwhelmed by component complexity

✅ **Our Solution: Micro-Component Architecture**

**Benefits of This Decomposed Approach:**

1. **Single Responsibility Components**
```qml
// Each component has one clear purpose
DatePickerDay { /* Only handles individual day rendering */ }
DatePickerHeader { /* Only handles navigation header */ }
TimePicker { /* Only handles time selection */ }
DateTimePicker { /* Only orchestrates date + time */ }
```

2. **Composable & Reusable**
```qml
// Use components independently or together
DatePicker { mode: "single" }      // Date only
TimePicker { is24Hour: true }      // Time only  
DateTimePicker { mode: "range" }   // Combined
```

3. **Maintainable Codebase**
```qml
// Small, focused files (50-200 lines each)
DatePickerDay.qml           // 95 lines - day cell logic
DatePickerHeader.qml        // 87 lines - navigation
DatePickerCalendarView.qml  // 145 lines - calendar grid
DatePickerActions.qml       // 78 lines - action buttons
```

4. **Performance Benefits**
```qml
// Load only what you need
DatePicker { standalone: false }  // No action buttons
TimePicker { /* No calendar overhead */ }
```

5. **Easy Testing & Debugging**
```qml
// Test components in isolation
DatePickerDay {
    date: new Date(2025, 0, 15)
    isSelected: true
    // Easy to test single day behavior
}
```

## Architecture & Design Patterns

### System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  DateTimePicker │────▶│   DatePicker    │────▶│  TimePicker     │
│   (Orchestrator)│    │  (Date Logic)   │    │  (Time Logic)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
    Combined Mode              Date Components         Time Components
    - Layout manager           │                        │
    - Signal coordination      ▼                        ▼
    - State management   ┌──────────────┐        ┌──────────────┐
         │               │ Micro-Comps  │        │ Time Columns │
         │               │──────────────│        │──────────────│
         └─── Actions ───▶│ • Header     │        │ • Hour       │
             Buttons     │ • Calendar   │        │ • Minute     │
                        │ • Day Cell   │        │ • AM/PM      │
                        │ • Year View  │        │ • Actions    │
                        │ • Month View │        └──────────────┘
                        │ • Actions    │
                        └──────────────┘
```

### Micro-Component Hierarchy

```
DateTimePicker (Main Container)
├── DatePicker (Date Selection)
│   ├── DatePickerHeader (Navigation: ❮ January 2025 ❯)
│   ├── DatePickerCalendarView (Calendar Grid)
│   │   ├── DayOfWeekRow (S M T W T F S)
│   │   ├── MonthGrid (Date Grid Container)
│   │   └── DatePickerDay (Individual Day Cell) ×42
│   ├── DatePickerYearView (Year Selection Grid)
│   ├── DatePickerMonthView (Month Selection Grid)
│   └── DatePickerActions (Clear/Apply Buttons)
├── TimePicker (Time Selection)
│   ├── TimeColumn (Hour) - Up/Value/Down
│   ├── TimeSeparator (:)
│   ├── TimeColumn (Minute) - Up/Value/Down
│   ├── TimeSeparator (:) [12H mode only]
│   ├── TimeColumn (AM/PM) [12H mode only]
│   └── DatePickerActions (Clear/Apply) [standalone mode]
└── DatePickerActions (Master Clear/Apply)
```

### Design Patterns Used

1. **Micro-Component Pattern (Core Architecture)**
```qml
// Instead of one massive component, decompose into focused micro-components
DatePickerCalendarView {
    // Only handles calendar grid logic
    delegate: DatePickerDay {
        // Only handles single day rendering and interaction
        onClicked: parent.dateClicked(date)
    }
}
```

**Why?** Each component has a single, clear responsibility making them easier to understand, test, and maintain.

2. **Composite Pattern (Container Components)**
```qml
DateTimePicker {
    // Composes multiple specialized components
    DatePicker { /* Date selection */ }
    TimePicker { /* Time selection */ }
    DatePickerActions { /* Action buttons */ }
}
```

**Why?** Allows building complex functionality by combining simpler components.

3. **Strategy Pattern (Mode Switching)**
```qml
// Different rendering strategies based on mode
property string mode: "single" // or "range"

function _handleDateClick(date) {
    if (mode === "single") {
        selectedDate = date
        dateSelected(selectedDate)
    } else if (mode === "range") {
        // Range selection logic
    }
}
```

**Why?** Same component can handle different selection behaviors without duplication.

4. **Template Method Pattern (Picker Containers)**
```qml
// DatePicker defines structure, subcomponents implement details
ColumnLayout {
    DatePickerHeader { /* Navigation template */ }
    StackLayout {
        DatePickerYearView { /* Year selection implementation */ }
        DatePickerMonthView { /* Month selection implementation */ }
        DatePickerCalendarView { /* Calendar implementation */ }
    }
    DatePickerActions { /* Action template */ }
}
```

**Why?** Consistent structure across different picker types while allowing customized implementations.

5. **Observer Pattern (Property Binding)**
```qml
// UI automatically updates when data changes
selectedDate: root.selectedDate
isSelected: root._isDaySelected(model.date)
canApply: root._canApply()

// Changes propagate automatically through binding chain
onDateSelected: function(date) {
    root.selectedDate = date  // Triggers UI updates throughout component tree
}
```

**Why?** Automatic UI synchronization when underlying data changes.

## Core Components

### 1. DateTimePicker (Main Orchestrator)

**Purpose**
Main container that combines date and time selection with proper layout management and signal coordination.

**Files**
- `DateTimePicker.qml`: Main orchestrator component
- Integrates `DatePicker` and `TimePicker` components

**Key Properties**
```qml
Rectangle {
    // Configuration
    property string mode: "single"        // "single" or "range"
    property bool is24Hour: true
    
    // Date properties (immediate updates)
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)
    property date endDate: new Date(NaN)
    
    // Time properties (always valid, initialized to current time)
    property int selectedHour: _currentHour
    property int selectedMinute: _currentMinute
    property bool selectedAMPM: _currentAMPM
    
    // End time properties (for range mode)
    property int endHour: _nextHour
    property int endMinute: _currentMinute
    property bool endAMPM: _nextAMPM
    
    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []
    
    // Read-only computed properties
    readonly property bool hasValidSelection: /* validation logic */
    readonly property date currentDateTime: /* combined date+time */
    
    // Signals - clean separation of concerns
    signal selectionChanged()                    // Immediate feedback
    signal dateTimeApplied(date dateTime)        // Final confirmation (single)
    signal rangeApplied(date start, date end)    // Final confirmation (range)
    signal selectionCleared()                    // Clear action
}
```

**Why This API Design?**
- **Immediate Updates**: `selectedDate` changes as user clicks, enabling live previews
- **Final Confirmation**: `dateTimeApplied` only fires when user clicks Apply
- **Range Support**: Separate start/end properties for date ranges with independent time selection
- **Validation**: `hasValidSelection` prevents invalid states from being applied
- **Extensibility**: Easy to add new constraints or validation rules

### 2. DatePicker (Date Selection Specialist)

**Purpose**
Handles all date selection logic with support for single dates and date ranges through a clean navigation flow.

**Key Properties**
```qml
Rectangle {
    // Public API
    property string mode: "single"               // "single", "range"
    property date selectedDate: new Date(NaN)
    property date startDate: new Date(NaN)
    property date endDate: new Date(NaN)
    property bool standalone: true              // Hide actions when embedded
    
    // Constraints
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property var disabledDates: []
    
    // Internal state - navigation flow
    property string _currentView: "calendar"    // "year", "month", "calendar"
    property int _currentMonth: _getInitialMonth()
    property int _currentYear: _getInitialYear()
    
    // Signals
    signal dateSelected(date date)
    signal rangeSelected(date startDate, date endDate)
}
```

**Navigation Flow**
```
Year View → Month View → Calendar View
    ↑           ↑           ↑
  2020-2031   Jan-Dec    Daily Grid
  (12 years) (12 months) (42 days)
```

**Why Three-Level Navigation?**
- **Efficiency**: Quick navigation to distant dates without scrolling
- **Familiarity**: Matches common calendar app patterns
- **Accessibility**: Large click targets for each level

### 3. TimePicker (Time Selection Specialist)

**Purpose**
Dedicated time selection with support for 24-hour and 12-hour formats, flexible height adaptation.

**Key Properties**
```qml
Rectangle {
    // Public API
    property bool is24Hour: true
    property int selectedHour: 12
    property int selectedMinute: 0
    property bool selectedAMPM: true           // true = AM, false = PM
    property bool standalone: true             // Show actions when standalone
    
    // Flexible sizing
    width: standalone ? 280 : parent.width
    height: standalone ? 110 : parent.height
    
    // Signals
    signal timeSelected(int hour, int minute, bool isAM)
}
```

**Why Flexible Height?**
- **Standalone Mode**: Fixed height for popup usage
- **Embedded Mode**: Adapts to container space (DateTimePicker needs compact layout)
- **Responsive**: Minimum heights ensure usability on small screens

### 4. Micro-Component Breakdown

**DatePickerDay** (Individual Day Cell)
```qml
Item {
    // Props
    property date date
    property bool isCurrentMonth: false
    property bool isToday: false
    property bool isSelected: false
    property bool isDisabled: false
    
    // Visual state computation
    readonly property color _backgroundColor: {
        if (isDisabled) return Theme.colors.transparent
        if (isSelected) return Theme.colors.accent500
        if (isToday && isCurrentMonth && !isSelected) return "transparent"
        if (mouseArea.containsMouse) return Theme.colors.secondary500
        return Theme.colors.transparent
    }
}
```

**Benefits of Micro-Day Component:**
- **Performance**: Only renders necessary visual states
- **Reusability**: Same component works for single/range modes
- **Maintainability**: Day styling logic isolated and testable
- **Animation**: Individual day transitions without affecting others

**DatePickerHeader** (Navigation Controls)
```qml
Item {
    // Props
    property string currentView: "calendar"
    property int currentMonth: 0
    property int currentYear: 2025
    
    // Signals
    signal previousClicked()
    signal nextClicked()
    signal headerClicked()  // For view navigation (Calendar → Year)
    
    // Dynamic title based on current view
    function _getTitleText() {
        switch (currentView) {
        case "year": return startYear + " - " + (startYear + 11)
        case "month": return currentYear.toString()
        case "calendar": return Qt.locale().monthName(currentMonth) + " " + currentYear
        }
    }
}
```

**Benefits of Separate Header:**
- **View-Aware**: Title adapts to current navigation level
- **Clickable Navigation**: Header click enables quick year/month jumping
- **Consistent Styling**: Same header across all picker views

## Qt QML Integration

### Component Lifecycle & Memory Management

```qml
// 1. Component Initialization
DateTimePicker {
    id: dateTimePicker
    
    // 2. Property initialization with sensible defaults
    Component.onCompleted: {
        // Initialize time to current time
        selectedHour = _currentHour
        selectedMinute = _currentMinute
        selectedAMPM = _currentAMPM
        
        // End time defaults to 1 hour later
        endHour = _nextHour
        endMinute = _currentMinute
        endAMPM = _nextAMPM
    }
    
    // 3. Child component initialization
    DatePicker {
        id: datePicker
        standalone: false  // Embedded mode
        
        // 4. Property binding establishment
        selectedDate: root.selectedDate
        startDate: root.startDate
        endDate: root.endDate
        
        // 5. Signal forwarding
        onDateSelected: (date) => {
            root.selectedDate = date
            root.selectionChanged()  // Immediate feedback
        }
    }
}
```

### StackLayout Integration (View Management)

```qml
// Dynamic view switching in DatePicker
StackLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    currentIndex: root._getViewIndex()  // Computed based on _currentView
    
    // Year picker (Index 0)
    DatePickerYearView {
        currentYear: root._currentYear
        onYearSelected: function(year) {
            root._currentYear = year
            root._currentView = "month"  // Automatic progression
        }
    }
    
    // Month picker (Index 1)  
    DatePickerMonthView {
        currentMonth: root._currentMonth
        onMonthSelected: function(month) {
            root._currentMonth = month
            root._currentView = "calendar"  // Back to calendar
        }
    }
    
    // Calendar view (Index 2)
    DatePickerCalendarView {
        mode: root.mode
        onDateClicked: function(date) { 
            root._handleDateClick(date) 
        }
    }
}
```

**Why StackLayout Instead of Loader?**
- **Performance**: All views pre-loaded (small memory footprint)
- **Smooth Transitions**: Instant view switching without loading delays
- **State Preservation**: Views maintain their state during navigation
- **Simple Logic**: Index-based switching is more reliable than dynamic loading

### Signal Coordination Pattern

```qml
DateTimePicker {
    // Master signal coordination
    onSelectionChanged: {
        // Fired immediately when any selection changes
        // Enables live preview in parent components
    }
    
    onDateTimeApplied: function(dateTime) {
        // Fired only when user confirms selection
        // Parent can distinguish between preview and final selection
    }
    
    DatePicker {
        // Child component signals forward to master
        onDateSelected: (date) => {
            root.selectedDate = date      // Update state
            root.selectionChanged()       // Trigger master signal
        }
    }
    
    TimePicker {
        // Time changes also trigger master coordination
        onSelectedHourChanged: {
            root.selectedHour = selectedHour
            root.selectionChanged()       // Live time preview
        }
    }
}
```

**Signal Architecture Benefits:**
- **Immediate Feedback**: `selectionChanged` enables live previews
- **Final Confirmation**: `dateTimeApplied` distinguishes user intent
- **Decoupled Components**: Child components don't need to know about parent usage
- **Event Aggregation**: Single place to handle all selection events

## Implementation Details

### Range Selection with Visual Feedback

**Problem**: Creating continuous range highlighting across a calendar grid.

**Solution**: Smart margin technique for pill-shaped ranges.

```qml
// In DatePickerCalendarView delegate
Rectangle {
    anchors {
        fill: parent
        // Key technique: reduce width on ends to create pill shape
        leftMargin: isRangeStart ? parent.width / 2 : 0
        rightMargin: isRangeEnd ? parent.width / 2 : 0
    }
    visible: isInRange
    color: Theme.colors.accent100
    opacity: 0.3
    z: 0  // Behind day cell
}

// Day cell renders on top with normal margins
DatePickerDay {
    anchors.fill: parent
    anchors.margins: Theme.spacing.s1
    z: 1  // Above range background
}
```

**Why This Technique?**
- **Continuous Visual**: Range appears as connected pills
- **Flexible Layout**: Works with any calendar grid configuration
- **Performance**: No complex path calculations, just margin adjustments
- **Theme Integration**: Uses theme colors and opacity

### Multi-Mode Time Selection

**12-Hour Mode Layout**
```qml
RowLayout {
    TimeColumn { /* Hour (1-12) */ }
    TimeSeparator { text: ":" }
    TimeColumn { /* Minute (00-59) */ }
    TimeSeparator { text: ":" }
    TimeColumn { /* AM/PM */ visible: !is24Hour }
}
```

**24-Hour Mode Layout**
```qml
RowLayout {
    TimeColumn { /* Hour (00-23) */ }
    TimeSeparator { text: ":" }
    TimeColumn { /* Minute (00-59) */ }
    // No AM/PM column
}
```

**Time Conversion Logic**
```qml
// 12H to 24H conversion
function _to24Hour(hour12, isAM) {
    if (isAM && hour12 === 12) return 0      // 12:xx AM = 00:xx
    if (!isAM && hour12 !== 12) return hour12 + 12  // 1:xx PM = 13:xx
    return hour12  // 12:xx PM = 12:xx, 1-11 AM = 1-11
}

// 24H to 12H conversion
function _to12Hour(hour24) {
    if (hour24 === 0) return 12        // 00:xx = 12:xx AM
    if (hour24 > 12) return hour24 - 12  // 13:xx = 1:xx PM
    return hour24  // 1-12 = 1-12
}
```

### Responsive Layout Management

**Fixed Container Sizing**
```qml
DateTimePicker {
    width: 312   // Fixed width for consistent UX
    height: 540  // Fixed height prevents layout jumps
    
    ColumnLayout {
        // Proportional space allocation
        DatePicker {
            Layout.preferredHeight: 276  // 51% of space
            standalone: false            // No duplicate actions
        }
        
        Rectangle { height: 1; color: Theme.colors.grey400 }  // Divider
        
        TimePicker {
            Layout.preferredHeight: 120  // 22% of space  
            standalone: false            // Embedded mode
        }
        
        DatePickerActions {
            Layout.fillWidth: true       // Remaining space
        }
    }
}
```

**Why Fixed Dimensions?**
- **Predictable Layout**: Parent components can rely on consistent sizing
- **Design System**: Matches Figma specifications exactly
- **Mobile Friendly**: Optimized dimensions work on mobile and desktop
- **Popup Behavior**: Fixed size prevents popup repositioning issues

### State Management & Validation

**Live Validation System**
```qml
// Computed validation properties
readonly property bool hasValidSelection: 
    mode === "single" ? !_isEmpty(selectedDate) : 
    (!_isEmpty(startDate) && !_isEmpty(endDate))

readonly property bool canClear: 
    mode === "single" ? !_isEmpty(selectedDate) : 
    (!_isEmpty(startDate) || !_isEmpty(endDate))

// Date-time combination for output
readonly property date currentDateTime: 
    hasValidSelection ? _combineDateTime(selectedDate, selectedHour, selectedMinute, selectedAMPM) : 
    new Date(NaN)

// Helper functions
function _combineDateTime(date, hour, minute, isAM) {
    if (_isEmpty(date)) return new Date(NaN)
    
    const result = new Date(date)
    let finalHour = hour
    
    if (!is24Hour) {
        finalHour = _to24Hour(hour, isAM)
    }
    
    result.setHours(finalHour, minute, 0, 0)
    return result
}
```

**State Lifecycle**
1. **Initialization**: Set defaults (current date/time)
2. **Selection**: Update properties as user interacts
3. **Validation**: Continuously check selection validity
4. **Preview**: Emit `selectionChanged` for immediate feedback
5. **Confirmation**: Emit `dateTimeApplied` when user clicks Apply
6. **Reset**: Clear selection and return to defaults

## Workflow & Process

### Development Workflow

1. **Component Design Phase**
```
Identify Requirements → Design API → Create Micro-Components → Integrate
      ↓                    ↓              ↓                    ↓
- Single/Range dates  - Properties    - DatePickerDay     - DatePicker
- Time selection      - Signals       - TimeColumn        - TimePicker  
- Combined mode       - Methods       - Navigation        - DateTimePicker
- Validation         - Constraints    - Actions           - Test Integration
```

2. **Micro-Component Development**
```qml
// Step 1: Create focused micro-component
DatePickerDay {
    // Single responsibility: render one day
    property date date
    property bool isSelected
    signal clicked(date date)
    
    // Minimal, testable implementation
}

// Step 2: Integrate into container
DatePickerCalendarView {
    // Compose micro-components
    delegate: DatePickerDay {
        onClicked: parent.dateClicked(date)
    }
}
```

3. **API Design Iteration**
```qml
// Version 1: Basic implementation
signal dateSelected(date date)

// Version 2: Add live preview capability
signal selectionChanged()  // Immediate feedback
signal dateTimeApplied(date dateTime)  // Final confirmation

// Version 3: Add validation support
readonly property bool hasValidSelection
readonly property date currentDateTime
```

4. **Integration Testing**
```qml
// Test individual components
DatePickerDay { date: testDate; isSelected: true }

// Test integrated functionality
DateTimePicker { 
    mode: "single"
    onSelectionChanged: console.log("Live:", currentDateTime)
    onDateTimeApplied: console.log("Final:", dateTime)
}
```

### Adding New Selection Modes

**Example: Adding a "Week" Selection Mode**

**Step 1: Update API**
```qml
property string mode: "single"  // "single", "range", "week"
signal weekSelected(date weekStart, date weekEnd)
```

**Step 2: Add Week Logic**
```qml
function _handleDateClick(date) {
    if (mode === "week") {
        const weekStart = _getWeekStart(date)
        const weekEnd = _getWeekEnd(date)
        weekSelected(weekStart, weekEnd)
    }
    // existing logic...
}
```

**Step 3: Add Visual Feedback**
```qml
// In DatePickerCalendarView
property bool isInWeek: mode === "week" && _isInSelectedWeek(model.date)

Rectangle {
    visible: isInWeek
    color: Theme.colors.accent100
    // Week highlighting logic
}
```

**Step 4: Update Actions**
```qml
function _canApply() {
    if (mode === "week") return !_isEmpty(weekStart) && !_isEmpty(weekEnd)
    // existing logic...
}
```

**Benefits of This Approach:**
- **Isolated Changes**: New mode doesn't affect existing functionality
- **Consistent API**: Same patterns as existing modes
- **Testable**: Can test week mode independently
- **Scalable**: Easy to add more modes (month, quarter, etc.)

### Performance Optimization Process

1. **Identify Bottlenecks**
```javascript
// Profile rendering performance
console.time("DatePicker.render")
// Component initialization
console.timeEnd("DatePicker.render")

// Monitor property binding updates
onCurrentStepChanged: console.log("Navigation:", currentStep)
```

2. **Optimize Micro-Components**
```qml
// Before: Expensive computed properties
color: Qt.rgba(Theme.colors.accent500.r, Theme.colors.accent500.g, Theme.colors.accent500.b, 0.3)

// After: Pre-computed theme values
readonly property color accentLight: Theme.colors.accent100
color: accentLight
```

3. **Minimize Layout Passes**
```qml
// Use implicit sizing for dynamic content
implicitHeight: content.implicitHeight

// Cache expensive calculations
readonly property date _weekStart: _getWeekStart(selectedDate)
```

## Building & Usage

### Prerequisites

- **Qt 6.8+**: QML framework with Calendar controls
- **CMake 3.16+**: Build system with Qt integration
- **App.Themes Module**: Centralized theming system
- **App.Components Module**: Base component library (Button, etc.)

### Component Integration

**CMakeLists.txt Structure**
```cmake
# Date-Time Picker module
set(datetime_picker_qml_files
    DateTimePicker.qml
    DatePicker.qml
    TimePicker.qml
    DatePickerCalendarView.qml
    DatePickerDay.qml
    DatePickerHeader.qml
    DatePickerActions.qml
    DatePickerYearView.qml
    DatePickerMonthView.qml
)

qt_add_qml_module(app_components_datetime_picker
    URI App.Components.DateTimePicker
    VERSION 1.0
    QML_FILES ${datetime_picker_qml_files}
)

# Link dependencies
target_link_libraries(app_components_datetime_picker
    PRIVATE
    app_themes
    app_components_base
    Qt6::Quick
    Qt6::QuickControls2
)
```

### Usage Examples

#### 1. Basic Date Selection

```qml
import App.Components 1.0 as UI

UI.DatePicker {
    id: singleDatePicker
    mode: "single"
    
    onDateSelected: function(date) {
        console.log("Selected date:", Qt.formatDate(date, "yyyy-MM-dd"))
        // Handle date selection
        selectedDateLabel.text = Qt.formatDate(date, "dd/MM/yyyy")
    }
}
```

#### 2. Date Range Selection

```qml
UI.DatePicker {
    id: dateRangePicker
    mode: "range"
    
    onRangeSelected: function(startDate, endDate) {
        console.log("Date range:", 
                   Qt.formatDate(startDate, "yyyy-MM-dd"), 
                   "to", 
                   Qt.formatDate(endDate, "yyyy-MM-dd"))
        
        // Calculate duration
        const days = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24))
        durationLabel.text = `${days} days selected`
    }
}
```

#### 3. Time Selection (24-Hour)

```qml
UI.TimePicker {
    id: timePicker24
    is24Hour: true
    
    onTimeSelected: function(hour, minute, isAM) {
        const timeString = hour.toString().padStart(2, '0') + ":" + 
                          minute.toString().padStart(2, '0')
        console.log("Selected time:", timeString)
        timeDisplayLabel.text = timeString
    }
}
```

#### 4. Time Selection (12-Hour AM/PM)

```qml
UI.TimePicker {
    id: timePicker12
    is24Hour: false
    
    onTimeSelected: function(hour, minute, isAM) {
        const timeString = hour.toString().padStart(2, '0') + ":" + 
                          minute.toString().padStart(2, '0') + " " +
                          (isAM ? "AM" : "PM")
        console.log("Selected time:", timeString)
        timeDisplayLabel.text = timeString
    }
}
```

#### 5. Combined Date-Time Selection

```qml
UI.DateTimePicker {
    id: dateTimePicker
    mode: "single"
    is24Hour: true
    
    // Live preview as user selects
    onSelectionChanged: {
        if (hasValidSelection) {
            previewLabel.text = "Preview: " + 
                              Qt.formatDateTime(currentDateTime, "dd/MM/yyyy hh:mm")
        } else {
            previewLabel.text = "Select date and time..."
        }
    }
    
    // Final confirmation when user clicks Apply
    onDateTimeApplied: function(dateTime) {
        console.log("Final selection:", Qt.formatDateTime(dateTime, "yyyy-MM-dd hh:mm:ss"))
        finalLabel.text = "Applied: " + Qt.formatDateTime(dateTime, "dd/MM/yyyy hh:mm")
        
        // Close popup, save to database, etc.
        dateTimePopup.close()
    }
    
    // Handle clear action
    onSelectionCleared: {
        previewLabel.text = "Selection cleared"
        finalLabel.text = ""
    }
}
```

#### 6. Date-Time Range Selection

```qml
UI.DateTimePicker {
    id: dateTimeRangePicker
    mode: "range"
    is24Hour: false  // 12-hour format
    
    onSelectionChanged: {
        if (hasValidSelection) {
            // Live preview of both start and end times
            const startDT = _combineDateTime(startDate, selectedHour, selectedMinute, selectedAMPM)
            const endDT = _combineDateTime(endDate, endHour, endMinute, endAMPM)
            
            rangePreviewLabel.text = 
                Qt.formatDateTime(startDT, "dd/MM/yyyy h:mm AP") + " - " +
                Qt.formatDateTime(endDT, "dd/MM/yyyy h:mm AP")
        } else {
            rangePreviewLabel.text = "Select date range and times..."
        }
    }
    
    onRangeApplied: function(startDateTime, endDateTime) {
        console.log("Date range applied:")
        console.log("Start:", Qt.formatDateTime(startDateTime, "yyyy-MM-dd hh:mm:ss"))
        console.log("End:", Qt.formatDateTime(endDateTime, "yyyy-MM-dd hh:mm:ss"))
        
        // Calculate duration
        const durationMs = endDateTime - startDateTime
        const durationHours = Math.floor(durationMs / (1000 * 60 * 60))
        const durationMinutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60))
        
        durationLabel.text = `Duration: ${durationHours}h ${durationMinutes}m`
        
        // Handle range application
        bookingManager.createBooking(startDateTime, endDateTime)
    }
}
```

#### 7. Embedded Usage (No Actions)

```qml
// For use in custom containers where you handle actions externally
ColumnLayout {
    UI.DatePicker {
        id: embeddedDatePicker
        Layout.fillWidth: true
        standalone: false  // Hides Clear/Apply buttons
        mode: "single"
        
        onDateSelected: function(date) {
            // Handle immediately without Apply button
            parentContainer.selectedDate = date
        }
    }
    
    // Custom action buttons
    RowLayout {
        Button {
            text: "Save"
            enabled: !isNaN(embeddedDatePicker.selectedDate.getTime())
            onClicked: saveDate(embeddedDatePicker.selectedDate)
        }
        
        Button {
            text: "Cancel"
            onClicked: parentContainer.close()
        }
    }
}
```

#### 8. Input Field Integration

```qml
// Complete example with input field and popup
Rectangle {
    width: 400
    height: 60
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        
        Text {
            text: selectedDateTime.getTime() ? 
                  Qt.formatDateTime(selectedDateTime, "dd/MM/yyyy hh:mm") : 
                  "Select date & time..."
            color: selectedDateTime.getTime() ? 
                   Theme.colors.text : Theme.colors.textMuted
        }
        
        Item { Layout.fillWidth: true }
        
        Image {
            source: "qrc:/icons/calendar.svg"
            width: 20; height: 20
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: dateTimePopup.open()
    }
    
    property date selectedDateTime: new Date(NaN)
    
    Popup {
        id: dateTimePopup
        width: 312
        height: 540
        
        UI.DateTimePicker {
            anchors.fill: parent
            mode: "single"
            is24Hour: true
            
            onDateTimeApplied: function(dateTime) {
                parent.selectedDateTime = dateTime
                dateTimePopup.close()
            }
        }
    }
}
```

#### 9. Form Integration with Validation

```qml
// Integration in forms with validation
ColumnLayout {
    // Event title
    TextField {
        id: titleField
        placeholderText: "Event title"
        Layout.fillWidth: true
    }
    
    // Start date-time
    Text {
        text: "Start Date & Time *"
        color: Theme.colors.text
    }
    
    DateTimeInputField {
        id: startDateTimeField
        Layout.fillWidth: true
        required: true
        
        onDateTimeChanged: validateForm()
    }
    
    // End date-time
    Text {
        text: "End Date & Time *"
        color: Theme.colors.text
    }
    
    DateTimeInputField {
        id: endDateTimeField
        Layout.fillWidth: true
        required: true
        
        onDateTimeChanged: validateForm()
    }
    
    // Validation
    property bool formValid: titleField.text.length > 0 && 
                           startDateTimeField.hasValidSelection && 
                           endDateTimeField.hasValidSelection &&
                           endDateTimeField.selectedDateTime > startDateTimeField.selectedDateTime
    
    Button {
        text: "Create Event"
        enabled: formValid
        onClicked: createEvent()
    }
    
    function validateForm() {
        // Custom validation logic
        if (endDateTimeField.selectedDateTime <= startDateTimeField.selectedDateTime) {
            errorLabel.text = "End time must be after start time"
            errorLabel.visible = true
        } else {
            errorLabel.visible = false
        }
    }
}
```

#### 10. Advanced Configuration

```qml
UI.DateTimePicker {
    // Custom constraints
    minimumDate: new Date(2025, 0, 1)  // January 1, 2025
    maximumDate: new Date(2025, 11, 31) // December 31, 2025
    
    // Disable specific dates (e.g., holidays)
    disabledDates: [
        new Date(2025, 0, 1),   // New Year's Day
        new Date(2025, 6, 4),   // Independence Day
        new Date(2025, 11, 25)  // Christmas
    ]
    
    // Initialize with specific date
    Component.onCompleted: {
        setDateTime(new Date(2025, 5, 15, 14, 30)) // June 15, 2025 2:30 PM
    }
    
    // Custom styling through theme
    color: Theme.colors.surfaceVariant
    border.color: Theme.colors.outline
    radius: Theme.radius.lg
}
```

## Best Practices

### 1. Component Selection

✅ **Choose the Right Component for Your Use Case**

```qml
// ✅ Date only → DatePicker
DatePicker { mode: "single" }

// ✅ Time only → TimePicker  
TimePicker { is24Hour: true }

// ✅ Date + Time → DateTimePicker
DateTimePicker { mode: "single" }

// ❌ Don't use DateTimePicker for date-only selection
// (Wastes screen space and confuses users)
```

**Component Decision Matrix:**
- **DatePicker**: Appointments, deadlines, birth dates, event dates
- **TimePicker**: Alarms, duration settings, time-only scheduling
- **DateTimePicker**: Meeting scheduling, booking systems, event creation

### 2. Mode Selection Strategy

✅ **Match Mode to User Intent**

```qml
// ✅ Single appointment
DateTimePicker { mode: "single" }

// ✅ Vacation booking, project duration
DateTimePicker { mode: "range" }

// ✅ Quick date selection in forms
DatePicker { 
    mode: "single"
    standalone: false  // Embedded in form
}
```

### 3. Signal Handling Patterns

✅ **Distinguish Between Preview and Confirmation**

```qml
DateTimePicker {
    // ✅ Use selectionChanged for immediate feedback
    onSelectionChanged: {
        if (hasValidSelection) {
            previewLabel.text = Qt.formatDateTime(currentDateTime, "dd/MM/yyyy hh:mm")
            calculateCost()  // Update dependent calculations
        }
    }
    
    // ✅ Use dateTimeApplied for final actions
    onDateTimeApplied: function(dateTime) {
        saveToDatabase(dateTime)
        sendNotification()
        closeDialog()
    }
}
```

❌ **Avoid**
```qml
// ❌ Don't trigger expensive operations on every change
onSelectionChanged: {
    saveToDatabase(currentDateTime)  // Too frequent!
    sendEmailNotification()          // Spam user!
}
```

### 4. Validation Implementation

✅ **Comprehensive Validation Strategy**

```qml
DateTimePicker {
    id: picker
    
    // ✅ Use built-in validation properties
    readonly property bool isDateValid: hasValidSelection
    readonly property bool isTimeReasonable: {
        const hour = currentDateTime.getHours()
        return hour >= 6 && hour <= 22  // Business hours
    }
    readonly property bool isFutureDate: currentDateTime > new Date()
    
    // ✅ Aggregate validation
    readonly property bool canSubmit: isDateValid && isTimeReasonable && isFutureDate
    
    // ✅ Provide clear error messages
    property string validationError: {
        if (!isDateValid) return "Please select a date and time"
        if (!isTimeReasonable) return "Please select a time between 6 AM and 10 PM"
        if (!isFutureDate) return "Please select a future date"
        return ""
    }
}

Text {
    text: picker.validationError
    color: Theme.colors.error
    visible: picker.validationError.length > 0
}
```

### 5. Performance Best Practices

✅ **Optimize for Smooth User Experience**

```qml
// ✅ Use readonly properties for expensive calculations
readonly property date nextWeek: {
    const date = new Date()
    date.setDate(date.getDate() + 7)
    return date
}

// ✅ Minimize property bindings in delegates
Component {
    id: dayDelegate
    DatePickerDay {
        // ✅ Pass properties directly instead of complex bindings
        date: model.date
        isSelected: model.isSelected  // Pre-computed in model
        isToday: model.isToday        // Pre-computed in model
    }
}

// ✅ Use asynchronous operations for expensive tasks
onDateTimeApplied: function(dateTime) {
    // ✅ Immediate UI feedback
    confirmationDialog.show("Saving...")
    
    // ✅ Asynchronous save operation
    DatabaseManager.saveEventAsync(dateTime).then(function(result) {
        confirmationDialog.show("Saved successfully!")
    })
}
```

### 6. Accessibility & Usability

✅ **Ensure Accessible Design**

```qml
DateTimePicker {
    // ✅ Provide clear labels
    stepTitle: "Select appointment date and time"
    
    // ✅ Keyboard navigation support (built-in with Qt Controls)
    focus: true
    
    // ✅ Screen reader support
    Accessible.role: Accessible.Dialog
    Accessible.name: "Date and time picker"
    Accessible.description: "Select date and time for your appointment"
    
    // ✅ High contrast mode support
    color: Theme.colors.surface  // Uses theme system
    border.color: Theme.colors.outline
}

// ✅ Clear button states
Button {
    text: picker.hasValidSelection ? "Apply Selection" : "Select Date & Time"
    enabled: picker.hasValidSelection
    
    // ✅ Visual feedback for disabled state
    opacity: enabled ? 1.0 : 0.6
}
```

### 7. Internationalization Support

✅ **Global-Ready Implementation**

```qml
DateTimePicker {
    // ✅ All user-visible strings use qsTr()
    // (Already implemented in components)
    
    // ✅ Locale-aware formatting
    function formatDisplayDate(date) {
        return Qt.formatDate(date, Qt.locale().dateFormat(Locale.ShortFormat))
    }
    
    function formatDisplayTime(date) {
        return Qt.formatTime(date, Qt.locale().timeFormat(Locale.ShortFormat))
    }
    
    // ✅ Support different calendar systems (handled by Qt)
    // ✅ RTL language support (handled by Qt layout system)
}
```

## Troubleshooting

### Common Issues & Solutions

1. **"TypeError: Cannot read property 'getTime' of undefined"**

**Problem**: Attempting to use invalid date objects.

**Solution**:
```qml
// ✅ Always check date validity
function isValidDate(date) {
    return date && !isNaN(date.getTime())
}

// ✅ Use safe property access
displayText: isValidDate(selectedDate) ? 
             Qt.formatDate(selectedDate, "dd/MM/yyyy") : 
             placeholder

// ✅ Provide fallbacks
readonly property date currentDateTime: 
    hasValidSelection ? _combineDateTime(selectedDate, selectedHour, selectedMinute, selectedAMPM) : 
    new Date(NaN)  // Explicit invalid date
```

2. **Range Selection Not Working Properly**

**Problem**: Range selection logic not handling edge cases.

**Debug Steps**:
```qml
// Add debug output to DatePicker
function _handleDateClick(date) {
    console.log("Date clicked:", date)
    console.log("Current mode:", mode)
    console.log("Range start temp:", _rangeStartTemp)
    
    if (mode === "range") {
        console.log("Range logic - isEmpty start:", _isEmpty(_rangeStartTemp))
        // Continue with debug output...
    }
}
```

**Common Solutions**:
```qml
// ✅ Ensure proper range state management
property date _rangeStartTemp: new Date(NaN)

function _handleDateClick(date) {
    if (mode === "range") {
        if (_isEmpty(_rangeStartTemp)) {
            // First date selected
            _rangeStartTemp = date
            startDate = date
            endDate = new Date(NaN)  // Clear end date
        } else {
            // Second date selected - handle order
            if (date >= _rangeStartTemp) {
                startDate = _rangeStartTemp
                endDate = date
            } else {
                startDate = date
                endDate = _rangeStartTemp
            }
            _rangeStartTemp = new Date(NaN)  // Reset temp
            rangeSelected(startDate, endDate)
        }
    }
}
```

3. **Time Picker Display Issues**

**Problem**: Time values not displaying correctly in different modes.

**Debug**:
```qml
TimePicker {
    Component.onCompleted: {
        console.log("TimePicker initialized:")
        console.log("- is24Hour:", is24Hour)
        console.log("- selectedHour:", selectedHour)
        console.log("- selectedAMPM:", selectedAMPM)
    }
    
    onSelectedHourChanged: console.log("Hour changed:", selectedHour)
    onSelectedAMPMChanged: console.log("AM/PM changed:", selectedAMPM)
}
```

**Solutions**:
```qml
// ✅ Proper hour validation
function _incrementHour() {
    if (is24Hour) {
        selectedHour = (selectedHour + 1) % 24
    } else {
        // 12-hour mode: 1-12
        selectedHour = selectedHour >= 12 ? 1 : selectedHour + 1
    }
}

// ✅ Correct display formatting
displayValue: {
    if (is24Hour) {
        return selectedHour.toString().padStart(2, '0')
    } else {
        // 12-hour display
        return selectedHour.toString().padStart(2, '0')
    }
}
```

4. **Layout Height Issues in DateTimePicker**

**Problem**: Components not fitting properly in fixed height container.

**Debug**:
```qml
DateTimePicker {
    Component.onCompleted: {
        console.log("Container height:", height)
        console.log("DatePicker height:", datePicker.height)
        console.log("TimePicker height:", timePicker.height)
        console.log("Actions height:", actions.height)
    }
}
```

**Solutions**:
```qml
// ✅ Use precise layout allocation
ColumnLayout {
    anchors.fill: parent
    anchors.margins: Theme.spacing.s4  // 16px
    spacing: Theme.spacing.s1          // 4px
    
    DatePicker {
        Layout.preferredHeight: 276     // Fixed allocation
        standalone: false
    }
    
    Rectangle { height: 1 }             // 1px divider
    
    Rectangle {
        Layout.preferredHeight: 120     // Time picker area
        // Remaining: 540 - 32(margins) - 8(spacing) - 276 - 1 - 120 = 103px for actions
    }
    
    DatePickerActions {
        Layout.fillWidth: true          // Uses remaining space
    }
}
```

5. **Signal Not Firing Issues**

**Problem**: `dateSelected` or `timeSelected` signals not being emitted.

**Debug**:
```qml
DatePicker {
    onDateSelected: function(date) {
        console.log("DateSelected signal fired:", date)
    }
    
    // Add debug in DatePickerDay
    DatePickerDay {
        onClicked: function(date) {
            console.log("Day clicked:", date)
            console.log("Will emit dateSelected")
            // Signal should fire here
        }
    }
}
```

**Common Solutions**:
```qml
// ✅ Ensure signal connection in DatePickerCalendarView
DatePickerDay {
    onClicked: function(date) {
        console.log("Day clicked, calling parent.dateClicked")
        root.dateClicked(date)  // Must call parent method
    }
}

// ✅ Verify signal propagation chain
function _handleDateClick(date) {
    console.log("_handleDateClick called with:", date)
    if (mode === "single") {
        selectedDate = date
        console.log("About to emit dateSelected")
        dateSelected(selectedDate)  // Signal emission
    }
}
```

6. **Theme Values Not Applied**

**Problem**: `Theme.colors.accent500` showing as undefined.

**Debug**:
```qml
Component.onCompleted: {
    console.log("Theme object:", Theme)
    console.log("Colors object:", Theme.colors)
    console.log("Accent500:", Theme.colors?.accent500)
    console.log("Spacing s4:", Theme.spacing?.s4)
}
```

**Solutions**:
```qml
// ✅ Verify imports
import App.Themes 1.0

// ✅ Provide fallbacks during development
color: Theme.colors?.accent500 ?? "#3B82F6"  // Fallback color
spacing: Theme.spacing?.s4 ?? 16              // Fallback spacing

// ✅ Check theme module registration in CMakeLists.txt
qt_add_qml_module(app_themes
    URI App.Themes
    VERSION 1.0
    QML_FILES Theme.qml
)
```

### Debugging Commands

**Component State Inspection**
```javascript
// Check DateTimePicker state
console.log("DateTimePicker state:", JSON.stringify({
    mode: mode,
    selectedDate: selectedDate?.toISOString(),
    startDate: startDate?.toISOString(),
    endDate: endDate?.toISOString(),
    selectedHour: selectedHour,
    selectedMinute: selectedMinute,
    hasValidSelection: hasValidSelection
}))

// Check individual component states
console.log("DatePicker currentView:", datePicker._currentView)
console.log("TimePicker values:", timePicker.getFormattedTime())
```

**Performance Profiling**
```javascript
// Profile component creation
console.time("DateTimePicker.creation")
// Component initialization
console.timeEnd("DateTimePicker.creation")

// Profile expensive operations
console.time("DatePicker.monthChange")
// Month navigation
console.timeEnd("DatePicker.monthChange")
```

## Conclusion

The Date-Time Picker component demonstrates a sophisticated micro-component architecture that solves common problems with monolithic date/time selection interfaces:

### Key Architectural Benefits

- **Modularity**: Each micro-component has a single, clear responsibility
- **Reusability**: Components can be used independently or composed together
- **Maintainability**: Small, focused files are easy to understand and modify
- **Testability**: Individual components can be tested in isolation
- **Performance**: Only load functionality that's actually needed
- **Scalability**: Easy to add new selection modes or features

### Production-Ready Features

- **Comprehensive API**: Supports all common date/time selection patterns
- **Visual Feedback**: Live preview and range highlighting for better UX
- **Flexible Integration**: Works as standalone popups or embedded forms
- **Theme Consistency**: Full integration with centralized design system
- **Accessibility**: Keyboard navigation and screen reader support
- **Internationalization**: Locale-aware formatting and text translation

### Development Benefits

- **Clear Separation**: Date logic separate from time logic separate from layout
- **Type Safety**: Structured properties and signals prevent runtime errors
- **Documentation**: Each component has clear API and usage patterns
- **Debugging**: Isolated components make troubleshooting straightforward
- **Team Collaboration**: Multiple developers can work on different micro-components

This architecture provides a solid foundation for any application requiring date/time selection, from simple appointment booking to complex scheduling systems, while maintaining code quality and developer productivity at scale.
