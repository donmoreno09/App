# Qt WizardPage Component

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

This Qt 6 WizardPage component provides a production-ready, reusable wizard interface for multi-step user workflows. The component features a modern dark theme design, step progress indication, navigation controls, and a flexible content loading system with proper theming integration.

### Key Features

- **Responsive Layout**: Adapts to different screen sizes with proper spacing and typography
- **Step Management**: Visual progress indication with step titles and counters
- **Dynamic Content Loading**: Asynchronous page loading through Qt's Loader mechanism
- **Theme Integration**: Full integration with App.Themes system for consistent styling
- **Navigation Controls**: Back/Next buttons with proper state management
- **Type-Safe Configuration**: Uses structured step definitions for maintainable code
- **Accessibility Ready**: Proper focus handling and keyboard navigation support

## Why This Approach?

### Traditional Problems with Wizard Implementations

❌ **Common Problematic Approach:**
```qml
// Hard-coded wizard with inline content
StackView {
    initialItem: Rectangle { /* Step 1 content inline */ }
    // No progress indication, no reusability
}
```

**Issues with Inline Wizard Systems:**
- **No Reusability**: Each wizard reimplements basic functionality
- **Mixed Concerns**: UI logic mixed with step content
- **Poor UX**: No progress indication or consistent navigation
- **Hard to Maintain**: Changes require modifying multiple files
- **No Theme Consistency**: Each wizard has different styling

✅ **Our Solution: Component-Based Wizard System**

**Benefits of This Approach:**

1. **Separation of Concerns**
```qml
WizardPage {
    // Wizard logic and UI
    stepLoader.sourceComponent = getStepComponent(currentStep)
}
```

2. **Reusable Architecture**
```qml
// Same wizard component for different workflows
WizardPage { title: "Mission Setup" }
WizardPage { title: "User Onboarding" }
```

3. **Type-Safe Step Management**
```qml
StepDefinitions {
    readonly property var steps: ({
        MISSION_OVERVIEW: { index: 0, title: qsTr("Mission Overview") }
    })
}
```

4. **Consistent Theming**
```qml
// All styling through centralized theme system
color: Theme.colors.primaryText
font.family: Theme.typography.familySans
```

## Architecture & Design Patterns

### System Architecture

```
┌─────────────────┐ ┌──────────────────┐ ┌─────────────────┐
│   WizardPage    │───▶│  StepDefinitions │───▶│   Step Content  │
│  (Container)    │    │   (Config)       │    │  (Pages/*.qml)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
    UI Framework              Metadata                 Business Logic
    - Header                  - Step titles            - Form components  
    - Progress bar            - Step indices           - Validation logic
    - Footer                  - Navigation flow        - Data models
    - Content loader          │                        │
         │                    └── Observer Pattern ────┘
         └────────── Loader Pattern ─────────────────────┘
                    (Dynamic component loading)
```

### Design Patterns Used

1. **Template Method Pattern (WizardPage)**
```qml
// WizardPage defines the algorithm structure
ColumnLayout {
    // Header (fixed)
    RowLayout { /* title, close button */ }
    
    // Progress indicator (fixed)
    Rectangle { /* step title, progress bar */ }
    
    // Content area (variable - template method)
    ScrollView {
        Loader { id: stepLoader } // Subclass defines content
    }
    
    // Footer (fixed)
    Rectangle { /* back, next buttons */ }
}
```

**Why?** Provides consistent wizard structure while allowing custom step content.

2. **Strategy Pattern (Step Components)**
```qml
function getStepComponent(step) {
    switch(step) {
    case stepDefs.steps.MISSION_OVERVIEW.index: return missionOverviewComp
    case stepDefs.steps.OPERATIONAL_AREA.index: return operationalAreaComp
    default: return null
    }
}
```

**Why?** Different step implementations can be swapped without changing wizard logic.

3. **Configuration Pattern (StepDefinitions)**
```qml
QtObject {
    readonly property var steps: ({
        MISSION_OVERVIEW: {
            index: 0,
            title: qsTr("Mission Overview"),
            component: "MissionOverview"
        }
    })
}
```

**Why?** Centralizes step configuration and makes adding steps easier.

4. **Observer Pattern (Property Bindings)**
```qml
// UI automatically updates when properties change
stepTitle: stepDefs.titles[currentStep] || ""
enabled: wizardPage.canGoBack
```

**Why?** Automatic UI updates when wizard state changes.

## Core Components

### 1. WizardPage Component

**Purpose**
Main wizard container providing layout structure and navigation logic.

**Files**
- `WizardPage.qml`: Main component implementation
- `Constants/StepDefinitions.qml`: Step configuration
- `Pages/*.qml`: Individual step implementations

**Key Properties**
```qml
Item {
    // Configuration properties
    property string title: ""
    property int currentStep: 0
    property int totalSteps: 1
    property string stepTitle: ""
    
    // Navigation state
    property bool canGoBack: currentStep > 0
    property bool canGoNext: true
    property bool showCloseButton: true
    
    // Component access
    property alias stepLoader: stepLoader
    
    // Navigation signals
    signal wizardFinished()
    signal wizardCanceled()
}
```

**Why Properties Over Functions?**
```qml
// ✅ Clean binding with properties
enabled: wizardPage.canGoBack

// ❌ Verbose with function calls  
enabled: wizardPage.getCanGoBack()
```

### 2. StepDefinitions System

**Purpose**
Type-safe step configuration with internationalization support.

**Key Structure**
```qml
QtObject {
    readonly property var steps: ({
        MISSION_OVERVIEW: {
            index: 0,
            title: qsTr("Mission Overview"),
            component: "MissionOverview"
        },
        OPERATIONAL_AREA: {
            index: 1,
            title: qsTr("Operational Area"),
            component: "OperationalArea"
        }
    })
    
    readonly property var titles: [
        steps.MISSION_OVERVIEW.title,
        steps.OPERATIONAL_AREA.title
    ]
    
    readonly property int totalSteps: titles.length
}
```

**Why Structured Objects?**
- **Type Safety**: Access via `steps.MISSION_OVERVIEW.index`
- **Maintainability**: All step data in one place
- **Extensibility**: Easy to add new properties like `validation` or `icon`
- **Internationalization**: Built-in qsTr() support

### 3. Theme Integration

**Layout Specifications**
```qml
// Consistent spacing using theme tokens
Layout.preferredHeight: Theme.spacing.s16  // 64px
anchors.leftMargin: Theme.spacing.s8       // 32px
spacing: Theme.spacing.s4                  // 16px
```

**Typography System**
```qml
// Consistent text styling
font.family: Theme.typography.familySans
font.pixelSize: Theme.typography.sizeLg    // 18px
font.weight: Theme.typography.weightMedium
color: Theme.colors.primaryText
```

**Why Theme Integration?**
- **Consistency**: Same styling across entire application
- **Maintainability**: Changes in one place affect all wizards
- **Design System Compliance**: Follows established design tokens
- **Dark Mode Ready**: Theme handles color scheme switching

## Qt QML Integration

### Component Lifecycle

```qml
// 1. Component creation and property initialization
WizardPage {
    title: "Mission Menu"
    
    // 2. StepDefinitions instantiation
    StepDefinitions { id: stepDefs }
    
    // 3. Property binding establishment
    totalSteps: stepDefs.totalSteps
    stepTitle: stepDefs.titles[currentStep] || ""
    
    // 4. Component registration
    Component { id: missionOverviewComp; MissionOverview {} }
    Component { id: operationalAreaComp; OperationalArea {} }
    
    // 5. Initial content loading
    Component.onCompleted: stepLoader.sourceComponent = getStepComponent(currentStep)
    
    // 6. Change handling
    onCurrentStepChanged: stepLoader.sourceComponent = getStepComponent(currentStep)
}
```

### Loader Pattern Implementation

**Problem**: Static step content increases memory usage and load time.

**Solution**: Asynchronous component loading with Qt's Loader.

```qml
ScrollView {
    Loader {
        id: stepLoader
        width: scrollView.width
        height: item ? item.implicitHeight : 0
        asynchronous: true  // Non-blocking loading
    }
}
```

**Benefits:**
- **Memory Efficient**: Only current step loaded in memory
- **Fast Startup**: Initial load only requires wizard shell
- **Smooth Transitions**: Asynchronous loading prevents UI blocking
- **Dynamic Height**: Content adapts to step requirements

### Signal-Slot Integration

```qml
// Internal wizard signals
signal wizardFinished()
signal wizardCanceled()

// Navigation functions automatically emit state changes
function goNext() { 
    if(isLastStep) wizardFinished() 
    else goToStep(currentStep + 1) 
}

// External usage
WizardPage {
    onWizardFinished: {
        // Handle completion
        console.log("Wizard completed successfully")
    }
    
    onWizardCanceled: {
        // Handle cancellation
        console.log("Wizard was canceled")
    }
}
```

## Implementation Details

### Responsive Layout System

**Grid-Based Spacing**
```qml
// Header section
Layout.preferredHeight: 64  // Theme.spacing.s16
anchors.leftMargin: 32      // Theme.spacing.s8
anchors.rightMargin: 32     // Theme.spacing.s8

// Section title
Layout.preferredHeight: 92  // Custom height for content
spacing: 16                 // Theme.spacing.s4

// Footer section  
Layout.preferredHeight: 88  // Custom height for buttons
```

**Typography Scale**
```qml
// Hierarchy through font sizes
// Title: 18px (Theme.typography.sizeLg)
text: wizardPage.title
font.pixelSize: Theme.typography.sizeLg

// Section title: 20px (Theme.typography.sizeLg)  
text: wizardPage.stepTitle
font.pixelSize: Theme.typography.sizeLg

// Step counter: 14px (Theme.typography.sizeSm)
text: "02 / 07"
font.pixelSize: Theme.typography.sizeSm
```

### Progress Indication System

**Visual Progress Bar**
```qml
RowLayout {
    Repeater {
        model: wizardPage.totalSteps
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: Theme.radius.xs
            color: Theme.colors.primaryText
            opacity: index <= wizardPage.currentStep ? 1.0 : 0.1
            
            Behavior on opacity { 
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
            }
        }
    }
}
```

**Step Counter Display**
```qml
Text {
    text: String(wizardPage.currentStep + 1).padStart(2,'0') + 
          " / " + 
          String(wizardPage.totalSteps).padStart(2,'0')
    color: Theme.colors.primaryText
    font.family: Theme.typography.familyMono  // Monospace for alignment
}
```

**Why This Approach?**
- **Visual Feedback**: Users understand their progress
- **Consistent Spacing**: Equal-width step indicators
- **Smooth Transitions**: Animated progress changes
- **Accessibility**: High contrast for visibility

### Navigation State Management

**State Calculation**
```qml
// Computed properties for clean state management
property bool canGoBack: currentStep > 0
readonly property bool isLastStep: currentStep >= totalSteps - 1

// Button text adapts to state
property string nextButtonText: isLastStep ? qsTr("Finish") : qsTr("Next")
property string backButtonText: qsTr("Back")
```

**Navigation Functions**
```qml
// Bounds checking prevents invalid states
function goToStep(step) { 
    if(step >= 0 && step < totalSteps) currentStep = step 
}

// Semantic navigation functions
function goNext() { 
    if(isLastStep) wizardFinished()
    else goToStep(currentStep + 1) 
}

function goBack() { 
    if(currentStep > 0) goToStep(currentStep - 1) 
}
```

## Workflow & Process

### Development Workflow

1. **Step Definition Phase**
```qml
// Define all steps in StepDefinitions.qml
readonly property var steps: ({
    STEP_ONE: { index: 0, title: qsTr("First Step") },
    STEP_TWO: { index: 1, title: qsTr("Second Step") }
})
```

2. **Component Creation Phase**
```qml
// Create individual step components
Component { id: stepOneComp; StepOne {} }
Component { id: stepTwoComp; StepTwo {} }
```

3. **Navigation Mapping Phase**
```qml
// Map steps to components
function getStepComponent(step) {
    switch(step) {
    case stepDefs.steps.STEP_ONE.index: return stepOneComp
    case stepDefs.steps.STEP_TWO.index: return stepTwoComp
    default: return null
    }
}
```

4. **Integration Phase**
```qml
// Wire up the wizard
Component.onCompleted: stepLoader.sourceComponent = getStepComponent(currentStep)
onCurrentStepChanged: stepLoader.sourceComponent = getStepComponent(currentStep)
```

### Adding New Steps

**Example: Adding a Validation Step**

**Step 1: Update StepDefinitions**
```qml
readonly property var steps: ({
    MISSION_OVERVIEW: { index: 0, title: qsTr("Mission Overview") },
    OPERATIONAL_AREA: { index: 1, title: qsTr("Operational Area") },
    VALIDATION: { index: 2, title: qsTr("Review & Validate") }  // New step
})
```

**Step 2: Create Component**
```qml
// Create Pages/ValidationStep.qml
Component { id: validationComp; ValidationStep {} }
```

**Step 3: Update Navigation**
```qml
function getStepComponent(step) {
    switch(step) {
    case stepDefs.steps.MISSION_OVERVIEW.index: return missionOverviewComp
    case stepDefs.steps.OPERATIONAL_AREA.index: return operationalAreaComp
    case stepDefs.steps.VALIDATION.index: return validationComp  // Add mapping
    default: return null
    }
}
```

**Result**: New step is fully integrated with zero changes to WizardPage core logic.

### Step Content Development

**Step Component Structure**
```qml
// Pages/MissionOverview.qml
Item {
    id: missionOverview
    
    // Define implicit height for proper sizing
    implicitHeight: content.implicitHeight
    
    // Step-specific properties
    property var formData: ({})
    property bool isValid: validateForm()
    
    // Content layout
    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.s8
        spacing: Theme.spacing.s8
        
        // Step content here...
    }
    
    // Validation logic
    function validateForm() {
        // Return true if step is complete
        return formData.required !== undefined
    }
}
```

**Step Communication Pattern**
```qml
// Parent wizard can access step properties
readonly property alias currentStepValid: stepLoader.item?.isValid ?? false

// Enable/disable next button based on step validation
canGoNext: currentStepValid
```

## Building & Usage

### Prerequisites

- **Qt 6.8+**: QML framework with modern layout system
- **CMake 3.16+**: Build system with Qt integration
- **App.Themes Module**: Centralized theming system
- **App.Components Module**: Base component library

### Component Integration

**CMakeLists.txt Structure**
```cmake
# WizardPage module structure
set(wizard_qml_files
    WizardPage.qml
    Pages/MissionOverview.qml
    Pages/OperationalArea.qml
    Constants/StepDefinitions.qml
)

qt_add_qml_module(app_components_wizardpage
    URI App.Components.WizardPage
    VERSION 1.0
    QML_FILES ${wizard_qml_files}
)
```

### Usage Examples

**Basic Wizard Implementation**
```qml
import App.Components.WizardPage 1.0

WizardPage {
    id: missionWizard
    title: "Mission Configuration"
    
    StepDefinitions { id: stepDefs }
    
    totalSteps: stepDefs.totalSteps
    stepTitle: stepDefs.titles[currentStep] || ""
    
    Component { id: overviewComp; MissionOverview {} }
    Component { id: areaComp; OperationalArea {} }
    
    Component.onCompleted: stepLoader.sourceComponent = getStepComponent(currentStep)
    onCurrentStepChanged: stepLoader.sourceComponent = getStepComponent(currentStep)
    
    function getStepComponent(step) {
        switch(step) {
        case stepDefs.steps.MISSION_OVERVIEW.index: return overviewComp
        case stepDefs.steps.OPERATIONAL_AREA.index: return areaComp
        default: return null
        }
    }
    
    onWizardFinished: {
        console.log("Mission configuration completed")
        // Handle completion logic
    }
}
```

**Advanced Usage with Validation**
```qml
WizardPage {
    id: advancedWizard
    
    // Dynamic navigation based on step validity
    canGoNext: stepLoader.item?.isValid ?? false
    
    // Custom button text based on completion state
    property bool allStepsComplete: checkAllStepsComplete()
    
    function checkAllStepsComplete() {
        // Custom validation logic
        return currentStep === totalSteps - 1 && stepLoader.item?.isValid
    }
    
    onWizardFinished: {
        if (allStepsComplete) {
            submitData()
        } else {
            showValidationErrors()
        }
    }
}
```

## Best Practices

### 1. Component Organization

✅ **Recommended Structure**
```
App/Components/WizardPage/
├── WizardPage.qml              # Main component
├── Constants/
│   └── StepDefinitions.qml     # Step configuration
└── Pages/
    ├── MissionOverview.qml     # Step implementations
    └── OperationalArea.qml
```

**Benefits**
- **Clear Separation**: Configuration vs implementation
- **Scalability**: Easy to add new steps
- **Maintainability**: Logical file organization

### 2. Step Design Patterns

✅ **Good Step Component Design**
```qml
Item {
    id: stepComponent
    
    // Always define implicit height
    implicitHeight: content.implicitHeight
    
    // Expose validation state
    property bool isValid: formValidator.isValid
    
    // Expose step data
    property var stepData: formValidator.data
    
    // Clean layout structure
    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.s8
        
        // Step content...
    }
}
```

❌ **Avoid**
```qml
// Fixed heights (breaks responsive design)
Item { height: 800 }

// No validation exposure
// No data binding

// Complex nested structures without implicit height
```

### 3. State Management

✅ **Recommended Pattern**
```qml
WizardPage {
    // Centralized state
    property var wizardData: ({})
    
    // Step data collection
    onCurrentStepChanged: {
        if (stepLoader.item?.stepData) {
            wizardData[stepLoader.item.stepName] = stepLoader.item.stepData
        }
    }
    
    // Validation aggregation
    readonly property bool canProceed: stepLoader.item?.isValid ?? false
    canGoNext: canProceed
}
```

### 4. Performance Considerations

**Memory Management**
```qml
// ✅ Good: Loader automatically manages memory
Loader {
    id: stepLoader
    asynchronous: true  // Non-blocking loading
}

// ✅ Good: Only current step in memory
onCurrentStepChanged: stepLoader.sourceComponent = getStepComponent(currentStep)
```

**Layout Optimization**
```qml
// ✅ Use implicit sizing for dynamic content
height: item ? item.implicitHeight : 0

// ✅ Enable clipping for scroll areas
ScrollView {
    clip: true  // Prevents rendering outside bounds
}
```

### 5. Theme Consistency

**Always Use Theme Tokens**
```qml
// ✅ Good: Theme-based spacing
anchors.margins: Theme.spacing.s8
spacing: Theme.spacing.s4

// ✅ Good: Theme-based colors
color: Theme.colors.primaryText
border.color: Theme.colors.border

// ❌ Avoid: Hard-coded values
anchors.margins: 32  // Breaks design system consistency
color: "#FFFFFF"     // Doesn't adapt to theme changes
```

## Troubleshooting

### Common Issues & Solutions

1. **"Cannot read property 'titles' of undefined"**

**Problem**: StepDefinitions not properly instantiated.

**Solution**:
```qml
// ✅ Correct: Create instance before using
StepDefinitions { id: stepDefs }
stepTitle: stepDefs.titles[currentStep] || ""

// ❌ Wrong: Using without instantiation
stepTitle: StepDefinitions.titles[currentStep] || ""
```

2. **Step Content Not Displaying**

**Problem**: Component not loaded or null sourceComponent.

**Debug Steps**:
```qml
onCurrentStepChanged: {
    console.log("Changing to step:", currentStep)
    let component = getStepComponent(currentStep)
    console.log("Component:", component)
    stepLoader.sourceComponent = component
}
```

**Common Solutions**:
- Verify component registration: `Component { id: comp; StepContent {} }`
- Check step index mapping in `getStepComponent()`
- Ensure step content QML files exist

3. **Layout Issues and Sizing Problems**

**Problem**: Step content not sizing correctly.

**Solutions**:
```qml
// ✅ Always define implicit height in step components
Item {
    implicitHeight: content.implicitHeight
    
    ColumnLayout {
        id: content
        // Content here
    }
}

// ✅ Handle empty states
Loader {
    height: item ? item.implicitHeight : 0
}
```

4. **Theme Values Not Applied**

**Problem**: `Theme.spacing.s8` shows as undefined.

**Debug Steps**:
```qml
Component.onCompleted: {
    console.log("Theme available:", typeof Theme !== 'undefined')
    console.log("Spacing s8:", Theme.spacing?.s8)
}
```

**Solutions**:
- Verify `import App.Themes 1.0` is present
- Check theme module is properly built and linked
- Ensure theme properties are defined

5. **Navigation State Issues**

**Problem**: Buttons enabled when they shouldn't be.

**Debug State**:
```qml
// Add debug output
property bool debugMode: true

Text {
    visible: debugMode
    text: `Step: ${currentStep}/${totalSteps}, CanBack: ${canGoBack}, CanNext: ${canGoNext}`
}
```

**Common Fixes**:
- Check `currentStep` bounds (0 to totalSteps-1)
- Verify `totalSteps` is set correctly
- Ensure validation logic is working

### Debugging Commands

**QML Console Debugging**
```javascript
// Check wizard state
console.log("Wizard state:", JSON.stringify({
    currentStep: currentStep,
    totalSteps: totalSteps,
    canGoBack: canGoBack,
    canGoNext: canGoNext
}))

// Check step definitions
console.log("Steps:", JSON.stringify(stepDefs.steps))
console.log("Titles:", stepDefs.titles)
```

**Component Introspection**
```qml
// Check loaded component
Component.onCompleted: {
    console.log("Step component loaded:", stepLoader.item)
    console.log("Item properties:", Object.keys(stepLoader.item || {}))
}
```

## Conclusion

The WizardPage component demonstrates a production-ready approach to multi-step user interfaces with:

- **Modularity**: Reusable wizard container with pluggable step content
- **Type Safety**: Structured step definitions prevent runtime errors  
- **Theme Integration**: Consistent styling through centralized design system
- **Performance**: Efficient memory usage through dynamic component loading
- **Maintainability**: Clear separation of concerns and organized file structure
- **User Experience**: Smooth navigation with progress indication and validation

The architecture scales well for complex wizards while maintaining simplicity for basic use cases, providing a solid foundation for any multi-step workflow requirements in Qt QML applications.
