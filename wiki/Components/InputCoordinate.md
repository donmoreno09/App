# InputCoordinate

[[_TOC_]]

## Overview

A specialized `Input` component for entering geographic coordinates in decimal degrees. It enforces a strict format with **6 decimal places** and a **hemisphere suffix** (`N/S` for latitude, `E/W` for longitude).

Validation, input masks, and auto-fix logic ensure that the hemisphere letter is always present and consistent.

You can get the numeric calculated value using the `value` property.

## Usage

### Latitude

```qml
UI.InputCoordinate {
    type: InputCoordinate.Latitude
}
```

Considerations:

- Example format: `12.345678° N`
- Acceptable hemispheres: `N`, `S`
- Range: `-90.000000` to `90.000000`

---

### Longitude

```qml
UI.InputCoordinate {
    type: InputCoordinate.Longitude
}
```

Considerations:

- Example format: `123.456789° E`
- Acceptable hemispheres: `E`, `W`
- Range: `-180.000000` to `180.000000`

### Accessing the numeric value

```qml
UI.InputCoordinate {
    id: coord
    type: InputCoordinate.Latitude
}

UI.Button {
    text: "Print Value"
    onClicked: console.log(coord.value) // returns signed decimal degrees
}
```

Examples:

- `coord.value` becomes `12.345678` for `12.345678° N`
- `coord.value` becomes `-12.345678` for `12.345678° S`

### Behavior notes

- The field starts with a default template (`00.000000° N` or `000.000000° E`).
- Input is restricted via `inputMask` and `RegularExpressionValidator`.
- If the hemisphere letter is deleted or replaced with an invalid character, it is automatically restored when focus is lost or editing finishes.
