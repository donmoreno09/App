# StackView Translation Caching Issue - Analysis & Solution

## Table of Contents

1. [Problem Description](#problem-description)
2. [Root Cause Analysis](#root-cause-analysis)
   - [Architecture Overview](#architecture-overview)
   - [Translation System](#translation-system)
   - [The Caching Problem](#the-caching-problem)
   - [Why Some Elements Updated](#why-some-elements-updated)
3. [Solution Implementation](#solution-implementation)
   - [Approach 1: Force Panel Reload (Rejected)](#approach-1-force-panel-reload-rejected)
   - [Approach 2: Disable Caching (Attempted)](#approach-2-disable-caching-attempted)
   - [Approach 3: Transition-less Reload (Final Solution)](#approach-3-transition-less-reload-final-solution)
4. [Final Solution Code](#final-solution-code)
5. [Code Explanation (Line by Line)](#code-explanation-line-by-line)
   - [Connection Setup](#connection-setup)
   - [Signal Handler](#signal-handler)
   - [Condition Check](#condition-check)
   - [Store Current Transitions](#store-current-transitions)
   - [Disable Transitions](#disable-transitions)
   - [Force Panel Reload](#force-panel-reload)
   - [Restore Transitions](#restore-transitions)
6. [Technical Benefits](#technical-benefits)
7. [Alternative Solutions Considered](#alternative-solutions-considered)
8. [Conclusion](#conclusion)

## Problem Description

When changing the application language from English to Italian (or vice versa), only certain UI elements (like combo boxes) would update immediately, while other elements in the wizard page would only update after closing and reopening the side panel.

### Symptoms
- ✅ Combo boxes update translations immediately
- ❌ Wizard page buttons ("Back", "Next") don't update until panel is reopened
- ❌ Other text elements in wizard components remain in old language

## Root Cause Analysis

### Architecture Overview
The application uses a nested component structure for the side panel:
```
SidePanel.qml 
  → StackView 
    → PanelRouter 
      → MissionPanel.qml 
        → WizardPageTest 
          → WizardPage
```

### Translation System
1. **LanguageController**: Manages current language and emits `languageChanged` signal
2. **TranslationManager**: Listens for language changes, increments `revision` property, emits `revisionChanged`
3. **QML Pattern**: Uses `(TranslationManager.revision, qsTr("text"))` binding to force re-evaluation

### The Caching Problem
Qt's `StackView` caches component instances for performance optimization. When language changes:

1. ✅ `LanguageController.currentLanguage` changes → emits `languageChanged`
2. ✅ `TranslationManager` receives signal → increments `revision` → emits `revisionChanged` 
3. ❌ **BUT**: Components inside the StackView are cached and don't re-evaluate their bindings
4. ✅ Elements outside StackView (like combo boxes in headers) update correctly

### Why Some Elements Updated
- **Combo boxes**: Located outside the StackView caching scope (likely in panel headers)
- **Cached elements**: Wizard page content loaded through StackView remains cached with old translations

## Solution Implementation

### Approach 1: Force Panel Reload (Rejected)
**Code**: Direct `PanelRouter.replaceCurrent()` call
**Problem**: Caused jarring slide animation even when panel was closed
**UX Impact**: Very poor - visible panel sliding on every language change

### Approach 2: Disable Caching (Attempted)
**Code**: `StackView { cacheBuffer: 0 }`
**Problem**: `cacheBuffer` is not a valid StackView property
**Result**: Qt compilation error

### Approach 3: Transition-less Reload (Final Solution)
**Code**: Temporarily disable StackView transitions during language change

## Final Solution Code

**File**: `App/Features/SidePanel/SidePanel.qml`

```qml
Connections {
    target: LanguageController
    function onLanguageChanged() {
        // Force refresh without transition animation
        if (stackView.currentItem && PanelRouter.currentPath) {
            // Temporarily disable transitions
            var oldTransition = stackView.replaceEnter
            var oldExitTransition = stackView.replaceExit
            stackView.replaceEnter = null
            stackView.replaceExit = null
            
            PanelRouter.replaceCurrent(PanelRouter.currentPath)
            
            // Restore transitions
            stackView.replaceEnter = oldTransition
            stackView.replaceExit = oldExitTransition
        }
    }
}
```

## Code Explanation (Line by Line)

### Connection Setup
```qml
Connections {
    target: LanguageController
```
- Creates a connection to listen for signals from `LanguageController`
- `target` specifies which object's signals to monitor

### Signal Handler
```qml
function onLanguageChanged() {
```
- Triggered when `LanguageController` emits `languageChanged` signal
- This happens whenever `LanguageController.currentLanguage` property changes

### Condition Check
```qml
if (stackView.currentItem && PanelRouter.currentPath) {
```
- `stackView.currentItem`: Ensures there's actually a panel loaded
- `PanelRouter.currentPath`: Ensures we know which route is currently active
- Prevents errors when no panel is open

### Store Current Transitions
```qml
var oldTransition = stackView.replaceEnter
var oldExitTransition = stackView.replaceExit
```
- `replaceEnter`: Animation used when new item enters during replace
- `replaceExit`: Animation used when old item exits during replace
- Store these to restore them later

### Disable Transitions
```qml
stackView.replaceEnter = null
stackView.replaceExit = null
```
- Set transition properties to `null` to disable animations
- This prevents the sliding animation that was causing poor UX

### Force Panel Reload
```qml
PanelRouter.replaceCurrent(PanelRouter.currentPath)
```
- `replaceCurrent()`: Replaces current StackView item with same route
- `PanelRouter.currentPath`: Uses the same path, forcing component recreation
- This breaks the cache and creates fresh component instances with updated translations

### Restore Transitions
```qml
stackView.replaceEnter = oldTransition
stackView.replaceExit = oldExitTransition
```
- Restore original transition animations
- Ensures normal StackView navigation continues to work smoothly
- Only the language-change refresh is instant; regular navigation keeps animations

## Technical Benefits

1. **Immediate Translation Updates**: All text elements update instantly on language change
2. **No Visual Disruption**: No sliding animations during language changes
3. **Preserved UX**: Normal panel navigation still uses smooth transitions
4. **Performance**: Minimal overhead - only recreates components when language actually changes
5. **Clean Architecture**: Doesn't require changes to individual components

## Alternative Solutions Considered

1. **Component-level fixes**: Adding `(TranslationManager.revision, qsTr())` to every text element
   - **Issue**: Requires updating hundreds of files, easy to miss elements
   
2. **Global retranslation**: Force entire application refresh
   - **Issue**: Poor performance, loses application state
   
3. **Custom caching system**: Replace StackView with custom component manager
   - **Issue**: Complex implementation, potential for new bugs

## Conclusion

The StackView transition-disabling approach provides the best balance of:
- ✅ Immediate translation updates
- ✅ Minimal code changes  
- ✅ Preserved user experience
- ✅ Clean architecture
- ✅ Performance efficiency

This solution demonstrates how Qt's component caching, while beneficial for performance, can interfere with dynamic content updates and requires careful handling in internationalized applications.