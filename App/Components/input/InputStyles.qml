pragma Singleton

import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

QtObject {
    enum Variant { Default, Success, Warning, Error }

    property InputStyle _default: InputStyle {
        borderColor: Theme.colors.textMuted
        borderColorFocused: Theme.colors.accent
        msgIconSource: "qrc:/App/assets/icons/circle-info.svg"
    }

    property InputStyle _success: InputStyle {
        borderColor: Theme.colors.textMuted
        borderColorFocused: Theme.colors.success
        msgIconSource: "qrc:/App/assets/icons/circle-check.svg"
    }

    property InputStyle _warning: InputStyle {
        borderColor: Theme.colors.textMuted
        borderColorFocused: Theme.colors.warning
        msgIconSource: "qrc:/App/assets/icons/triangle-exclamation.svg"
    }

    property InputStyle _error: InputStyle {
        borderColor: Theme.colors.textMuted
        borderColorFocused: Theme.colors.error
        msgIconSource: "qrc:/App/assets/icons/circle-xmark.svg"
    }

    function fromVariant(variant) : InputStyle {
        switch (variant) {
        case InputStyles.Default: return _default
        case InputStyles.Success: return _success
        case InputStyles.Warning: return _warning
        case InputStyles.Error: return _error
        default: {
            console.warn("Invalid InputStyle: ", variant)
            return _default
        }
        }
    }
}
