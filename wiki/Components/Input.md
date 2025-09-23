# Input

[[_TOC_]]

## Overview

A styled single-line text input built on top of TextField, with optional label, tooltip (info badge), right-side icon button, and a message row. Visual appearance adapts to theme tokens (Light, Dark) and variant (Default, Success, Warning, Error).

The `Input` component is divided into three sections: label, input, and message. The label can have a tooltip. The input can have an icon button on its right.

## Usage

### Complete (with tooltip, icon, and message)

```qml
UI.Input {
    variant: UI.InputStyles.Default

    labelText: "Label(*)"
    tooltipText: "Some tooltip message"
    placeholderText: "Placeholder"
    messageText: "Message goes here"

    iconSource: "qrc:/App/assets/icons/icon.svg"
}
```

Most components within the `Input` component will not show if their associated properties are not set, for example:

- If `labelText` is not set, then the entire label section won't show.
- If `tooltipText` is not set, then the icon besides the label won't show.
- If `messageText` is not set, then the entire message section won't show.
- If `iconSource` is not set, then the icon within the input won't show.

### Lean

If you just need an `Input` without any labels or messages, you can simply write:

```qml
UI.Input {
    variant: UI.InputStyles.Default
    placeholderText: "Input here..."
}
```

### Validation state

```qml
UI.Input {
    labelText: "Email"
    placeholderText: "name@example.com"
    variant: InputStyles.Error
    messageText: "Please enter a valid email"
}
```

### Password

```qml
UI.Input {
    labelText: "Password"
    echoMode: TextInput.Password
}
```

> You need to import `QtQuick.Controls` to use `TextInput.Password`.

### Disabled

```qml
UI.Input {
    labelText: "API Key"
    text: "somesecret"
    enabled: false
}
```

### Customizing the inner TextField

Under the hood, `Input` wraps around the `TextField` component. If you ever need to access its properties, methods, or signals, you can use the aliased property `textField`.

```qml
UI.Input {
    id: input
}

UI.Button {
    text: "Clear"
    onClicked: input.textField.clear()
}
```
