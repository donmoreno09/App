# Modal Dialog Stack Component Documentation

## Table of Contents

1. [Overview](#overview)
2. [Why This Approach?](#why-this-approach)
3. [Component Architecture](#component-architecture)
4. [API Reference](#api-reference)
   - [Properties](#properties)
   - [Signals](#signals)
   - [Methods](#methods)
5. [Usage Examples](#usage-examples)
   - [Basic Modal Dialog](#basic-modal-dialog)
   - [Stacked Dialogs](#stacked-dialogs)
   - [Dialog with Form](#dialog-with-form)
6. [Styling & Theming](#styling--theming)
7. [Best Practices](#best-practices)
8. [Technical Details](#technical-details)

---

## Overview

The **Modal Dialog Stack** component (`Modal.qml`) is a reusable QML component that provides a sophisticated modal dialog system with support for **stacking multiple dialogs** on top of each other. It manages the lifecycle of dialogs, handles dimmed overlays, and provides smooth animations for opening and closing dialogs.

### Key Features

- **Dialog Stacking**: Open multiple dialogs sequentially, with each new dialog appearing on top
- **Automatic Overlay Management**: Handles dimmed background overlay automatically
- **Smooth Animations**: Built-in enter/exit animations with scale and opacity effects
- **Lifecycle Signals**: Get notified when dialogs open or close
- **Simple API**: Push and pop dialogs with minimal code
- **z-Index Management**: Automatically handles layering of stacked dialogs

---

## Why This Approach?

### The Problem

Traditional QML `Dialog` and `Popup` components have limitations when dealing with multiple overlapping dialogs:

- No built-in support for dialog stacking
- Manual management of multiple overlays becomes complex
- Difficult to track which dialogs are active
- Poor z-index management when multiple dialogs exist
- Inconsistent animations and transitions

### The Solution

This Modal component implements a **stack-based architecture** that:

1. **Centralizes Dialog Management**: Single point of control for all modal dialogs in your application
2. **Automatic Layering**: Each new dialog automatically appears above previous ones with proper z-indexing
3. **Unified Overlay**: Single dimmed overlay that persists across all stacked dialogs
4. **Lifecycle Tracking**: Built-in signals to monitor dialog stack changes
5. **Component-Based**: Dialogs are defined as reusable QML components, promoting separation of concerns

### Benefits

- **Cleaner Code**: No need to manually manage multiple `Popup` instances
- **Better UX**: Consistent animations and overlay behavior
- **Easier Testing**: Single component to test dialog behavior
- **Scalability**: Easily handle complex multi-dialog flows
- **Maintainability**: Dialog logic is centralized and reusable

---

## Component Architecture

```
Modal (root Item)
  └─ Popup (dimOverlay)
       └─ Item (contentItem)
            └─ Repeater
                 └─ Loader (for each dialog in stack)
                      └─ Dialog Content (loaded dynamically)
```

**Key Design Decisions:**

- **Stack Array**: Dialogs are stored in a JavaScript array (`_stack`), allowing LIFO (Last In, First Out) access
- **Repeater + Loader**: Each dialog is loaded dynamically using a `Loader`, enabling lazy instantiation
- **Single Popup**: Only one `Popup` instance is used, reducing overhead
- **z-Index via Repeater**: The `Repeater`'s `index` provides automatic z-ordering

---

## API Reference

### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `count` | `int` | readonly | The number of currently active dialogs in the stack |
| `_stack` | `Array` | private | Internal array holding dialog metadata (not meant for external use) |

### Signals

#### `dialogOpened(var dialog)`
Emitted when a new dialog is pushed onto the stack.

**Parameters:**
- `dialog` (Object): Contains `{ component, id }` of the opened dialog

**Example:**
```qml
modal.onDialogOpened: (dialog) => {
    console.log("Dialog opened with ID:", dialog.id)
}
```

#### `dialogClosed(var dialog)`
Emitted when a dialog is popped from the stack.

**Parameters:**
- `dialog` (Object): Contains `{ component, id }` of the closed dialog

**Example:**
```qml
modal.onDialogClosed: (dialog) => {
    console.log("Dialog closed with ID:", dialog.id)
}
```

### Methods

#### `push(component)`
Opens a new dialog by pushing it onto the stack.

**Parameters:**
- `component` (Component): A QML Component defining the dialog content

**Behavior:**
- Opens the overlay if this is the first dialog
- Adds the dialog to the top of the stack
- Emits `dialogOpened` signal
- Connects to the dialog's `closed()` signal automatically

**Example:**
```qml
modal.push(myDialogComponent)
```

#### `pop()`
Closes the topmost dialog in the stack.

**Behavior:**
- Removes the top dialog from the stack
- Closes the overlay if no dialogs remain
- Emits `dialogClosed` signal
- Returns early if stack is empty

**Example:**
```qml
modal.pop()
```

---

## Usage Examples

### Basic Modal Dialog

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import App.Components 1.0 as UI

Item {
    // Define your dialog as a Component
    Component {
        id: simpleDialog

        ColumnLayout {
            width: 300
            height: 200
            
            signal closed()  // Required signal

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: "Hello, Modal!"
                        font.pixelSize: 18
                    }

                    UI.Button {
                        text: "Close"
                        onClicked: closed()
                    }
                }
            }
        }
    }

    // Trigger button
    UI.Button {
        text: "Open Dialog"
        onClicked: modal.push(simpleDialog)
    }

    // The modal instance
    UI.Modal {
        id: modal
    }
}
```

### Stacked Dialogs

Opening a profile dialog, then a password dialog on top:

```qml
Component {
    id: profileDialog

    ColumnLayout {
        width: 450
        height: 400
        signal closed()

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.colors.surface
            radius: Theme.radius.lg

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s6

                Text {
                    text: "Edit Profile"
                    font.pixelSize: 24
                }

                UI.Input {
                    Layout.fillWidth: true
                    labelText: "Name"
                }

                // Button to open second dialog
                UI.Button {
                    text: "Change Password"
                    onClicked: modal.push(passwordDialog)  // Stack another dialog!
                }

                UI.Button {
                    text: "Save"
                    onClicked: closed()
                }
            }
        }
    }
}

Component {
    id: passwordDialog

    ColumnLayout {
        width: 400
        height: 300
        signal closed()

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.colors.surface

            ColumnLayout {
                anchors.fill: parent

                Text {
                    text: "Change Password"
                    font.pixelSize: 22
                }

                UI.Input {
                    labelText: "New Password"
                    textField.echoMode: TextInput.Password
                }

                UI.Button {
                    text: "Update"
                    onClicked: closed()  // This will pop only the password dialog
                }
            }
        }
    }
}
```

### Dialog with Form

```qml
Component {
    id: contactFormDialog

    ColumnLayout {
        width: 500
        height: 450
        signal closed()

        property alias name: nameInput.text
        property alias email: emailInput.text
        property alias message: messageInput.text

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.colors.surface
            radius: Theme.radius.lg

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s6
                spacing: Theme.spacing.s4

                Text {
                    text: "Contact Us"
                    font.pixelSize: 24
                    font.bold: true
                }

                UI.Input {
                    id: nameInput
                    Layout.fillWidth: true
                    labelText: "Name"
                    placeholderText: "Enter your name"
                }

                UI.Input {
                    id: emailInput
                    Layout.fillWidth: true
                    labelText: "Email"
                    placeholderText: "your.email@example.com"
                }

                UI.TextArea {
                    id: messageInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    labelText: "Message"
                    placeholderText: "Type your message here..."
                }

                RowLayout {
                    Layout.fillWidth: true

                    UI.Button {
                        Layout.fillWidth: true
                        text: "Send"
                        variant: "primary"
                        onClicked: {
                            // Handle form submission
                            console.log("Sending:", name, email, message)
                            closed()
                        }
                    }

                    UI.Button {
                        Layout.fillWidth: true
                        text: "Cancel"
                        variant: "ghost"
                        onClicked: closed()
                    }
                }
            }
        }
    }
}
```

---

## Styling & Theming

### Overlay Customization

The dimmed overlay can be customized by modifying the `Overlay.modal` property:

```qml
Popup {
    id: dimOverlay
    
    Overlay.modal: Rectangle {
        color: "black"          // Change overlay color
        opacity: 0.5            // Adjust transparency
    }
}
```

### Animation Customization

Modify the `Behavior` blocks in the `Loader` to change dialog animations:

```qml
Behavior on scale {
    NumberAnimation { 
        duration: 200              // Animation speed
        easing.type: Easing.OutBack  // Easing curve
    }
}
```

### Transition Customization

Change the overlay fade-in/fade-out:

```qml
enter: Transition {
    NumberAnimation { 
        property: "opacity"
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutQuad 
    }
}
```

---

## Best Practices

### 1. Always Include the `closed()` Signal

Every dialog component **must** define a `closed()` signal:

```qml
Component {
    id: myDialog
    
    ColumnLayout {
        signal closed()  // ✅ Required!
        
        // ... dialog content ...
    }
}
```

### 2. Emit `closed()` to Dismiss

Call `closed()` when the user should exit the dialog:

```qml
UI.Button {
    text: "OK"
    onClicked: closed()  // Automatically pops the dialog
}
```

### 3. Check Stack Count

Monitor the active dialog count for debugging or UI updates:

```qml
Text {
    text: "Active Dialogs: " + modal.count
}
```

### 4. Use Descriptive Dialog IDs

While the component auto-generates IDs, you can track them for logging:

```qml
modal.onDialogOpened: (dialog) => {
    console.log("Opened:", dialog.id)
}
```

### 5. Avoid Direct `pop()` Calls

Let the `closed()` signal handle dismissal instead of calling `modal.pop()` directly. This ensures proper cleanup.

### 6. Set Appropriate Dialog Sizes

Define explicit `width` and `height` for each dialog to ensure consistent appearance:

```qml
ColumnLayout {
    width: 400   // ✅ Explicit size
    height: 300  // ✅ Explicit size
    signal closed()
}
```

---

## Technical Details

### Stack Management

The component uses a reactive JavaScript array:

```javascript
property var _stack: []

function push(component) {
    _stack.push({ component, id: Date.now() })
    _stack = _stack  // Trigger property change notification
    // ...
}
```

The `_stack = _stack` assignment is a QML pattern to force re-evaluation of bindings.

### Signal Connection

When a dialog loads, its `closed()` signal is automatically connected:

```qml
onLoaded: {
    if (item && item.closed)
        item.closed.connect(root.pop)
}
```

This creates the automatic dismiss behavior.

### Z-Index Ordering

The `Repeater`'s `index` is used for z-ordering:

```qml
Loader {
    z: index + 1  // Each successive dialog appears above the previous
}
```

### Overlay Lifecycle

- Overlay opens when first dialog is pushed (`_stack.length === 1`)
- Overlay closes when last dialog is popped (`_stack.length === 0`)

---
