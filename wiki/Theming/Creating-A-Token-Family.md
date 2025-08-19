[[_TOC_]]

This guide explains how to add a new **token family** to the theming system. A token family encapsulates one type of design decision.

## 1. Create the Token File

Add a new file under `App/Themes/tokens` and name it `XxxTokens.qml`.

For example:

```
App/Themes/tokens/MotionTokens.qml
```

## 2. Update CMakeLists

In `App/Themes/CMakeLists.txt`, remove the auto-generated entry for `XxxTokens.qml` from `qt_add_qml_module`. Instead, add it manually under `set(qml_files ...)`.

This ensures consistency within the CMakeLists file.

## 3. Update BaseTheme.qml

Add a new required property for the token family. Use a lowercased name, for example:

```qml
required property MotionTokens motion
```

## 4. Update Each Variant

Inside every file under `App/Themes/variants`, instantiate the new family:

```qml
motion: MotionTokens { }
```

> I am aware it is tedious and it _can_ be automated with CMake, however, since token families don't really change much. We'll skip the automation complexity.

## 5. Expose in Theme.qml

Finally, expose the token family via the Theme singleton for direct usage:

```qml
readonly property MotionTokens motion: current.motion
```

## Example: Adding Motion Tokens

```qml
// MotionTokens.qml
QtObject {
    readonly property int fast: 150   // ms
    readonly property int normal: 300
    readonly property int slow: 600
}

// BaseTheme.qml
QtObject {
    required property MotionTokens motion
}

// Fincantieri.qml
BaseTheme {
    motion: MotionTokens { }
}

// Theme.qml
readonly property MotionTokens motion: current.motion
```
