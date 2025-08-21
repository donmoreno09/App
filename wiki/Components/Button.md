# Button Component Documentation

## Folder Architecture

### Location
```
App/
├── Components/
│   ├── Button.qml          # Base button component ← THIS FILE
│   ├── ButtonsTest.qml     # Test file for button variants
│   └── ...
├── Features/
├── Tests/
├── Themes/
│   └── Theme.qml           # Theme definitions used by Button
└── ...
```

### File Purpose

**`App/Components/Button.qml`** is the foundational button component for the entire design system.

#### Why This Location?

- **Components folder** - Houses reusable UI components
- **Base level** - Not nested since it's used by many other components
- **Foundation component** - Serves as the base for specialized buttons like:
  - `IconButton`
  - `MapToolButton` 
  - `NavRailItem`

#### Dependencies

```
Button.qml depends on:
├── QtQuick 6.8
├── QtQuick.Controls 6.8
└── App.Themes 1.0 (Theme.qml)
```

#### Used By

This component is imported and used by:
- Other button components (IconButton, etc.)
- Feature modules throughout the app
- Test files (ButtonsTest.qml)
- UI layouts requiring interactive elements

#### File Responsibility

The `Button.qml` file handles:
- ✅ Visual variant styling (primary, secondary, danger, etc.)
- ✅ Size variants (sm, md, lg)
- ✅ State management (hover, focus, pressed, disabled)
- ✅ Theme integration
- ✅ Accessibility support
- ✅ Content delegation to children

---

## Usage

### Basic Import

```qml
import App.Components 1.0 as UI
```

### Variants

#### Primary Button
```qml
UI.Button {
    variant: "primary"
    
    contentItem: Text {
        text: "Submit"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

#### Secondary Button
```qml
UI.Button {
    variant: "secondary"
    
    contentItem: Text {
        text: "Cancel"
        color: Theme.colors.text
        anchors.centerIn: parent
    }
}
```

#### Danger Button
```qml
UI.Button {
    variant: "danger"
    
    contentItem: Text {
        text: "Delete"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

#### Ghost Button
```qml
UI.Button {
    variant: "ghost"
    
    contentItem: Text {
        text: "Learn More"
        color: Theme.colors.text
        anchors.centerIn: parent
    }
}
```

#### Success Button
```qml
UI.Button {
    variant: "success"
    
    contentItem: Text {
        text: "Save"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

### Sizes

#### Small Button
```qml
UI.Button {
    variant: "primary"
    size: "sm"
    
    contentItem: Text {
        text: "Small"
        color: Theme.colors.primaryText
        font.pixelSize: Theme.typography.sizeSm
        anchors.centerIn: parent
    }
}
```

#### Medium Button (Default)
```qml
UI.Button {
    variant: "primary"
    size: "md"  // or omit (default)
    
    contentItem: Text {
        text: "Medium"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

#### Large Button
```qml
UI.Button {
    variant: "primary"
    size: "lg"
    
    contentItem: Text {
        text: "Large"
        color: Theme.colors.primaryText
        font.pixelSize: Theme.typography.sizeLg
        anchors.centerIn: parent
    }
}
```

### Icon Buttons

#### Icon Only
```qml
UI.Button {
    variant: "ghost"
    
    contentItem: Image {
        source: "qrc:/icons/settings.svg"
        width: 16
        height: 16
        anchors.centerIn: parent
    }
}
```

#### Icon + Text
```qml
UI.Button {
    variant: "secondary"
    
    contentItem:Row {
        spacing: Theme.spacing.s2
        anchors.centerIn: parent
        
        Image {
            source: "qrc:/icons/download.svg"
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: "Download"
            color: Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
```

### Custom Properties

#### Custom Radius
```qml
UI.Button {
    variant: "primary"
    radius: Theme.radius.lg
    
    contentItem: Text {
        text: "Rounded"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

#### Custom Focus Style
```qml
UI.Button {
    variant: "primary"
    focusColor: Theme.colors.success
    focusOutlineWidth: 3
    
    contentItem: Text {
        text: "Custom Focus"
        color: Theme.colors.primaryText
        anchors.centerIn: parent
    }
}
```

### Common Patterns

#### Form Buttons
```qml
Row {
    spacing: Theme.spacing.s3
    
    UI.Button {
        variant: "secondary"
        contentItem: Text {
            text: "Cancel"
            color: Theme.colors.text
            anchors.centerIn: parent
        }
    }
    
    UI.Button {
        variant: "primary"
        contentItem: Text {
            text: "Submit"
            color: Theme.colors.primaryText
            anchors.centerIn: parent
        }
    }
}
```

#### Toolbar Buttons
```qml
Row {
    spacing: Theme.spacing.s1
    
    UI.Button {
        variant: "ghost"
        size: "sm"
        contentItem: Image {
            source: "qrc:/icons/bold.svg"
            width: 16
            height: 16
            anchors.centerIn: parent
        }
    }
    
    UI.Button {
        variant: "ghost"
        size: "sm"
        contentItem: Image {
            source: "qrc:/icons/italic.svg"
            width: 16
            height: 16
            anchors.centerIn: parent
        }
    }
}
```

### Best Practices

#### Always Center Content
```qml
// ✅ Correct
Text {
    text: "Button Text"
    anchors.centerIn: parent
}

// ❌ Incorrect
Text {
    text: "Button Text"
    // No positioning
}
```

#### Use Theme Colors
```qml
// ✅ Correct - matches variant
UI.Button {
    variant: "primary"
    contentItem: Text {
        color: Theme.colors.primaryText
    }
}

// ❌ Incorrect - hardcoded color
UI.Button {
    variant: "primary"
    contentItem: Text {
        color: "white"
    }
}
```

#### Choose Appropriate Variants
- **primary** - Main actions (Submit, Save, Create)
- **secondary** - Secondary actions (Cancel, Back)
- **danger** - Destructive actions (Delete, Remove)
- **ghost** - Subtle actions (Settings, More options)
- **success** - Positive confirmations (Confirm, Accept)
