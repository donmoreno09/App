/*!
    \qmltype ToggleStyles
    \inqmlmodule App.Components
    \brief Singleton providing Toggle style variants.

    Defines the two main style states for the Toggle component as shown in Figma:
    Primary (active blue state) and the standard off/disabled states.
*/

pragma Singleton

import QtQuick 6.8
import App.Themes 1.0

QtObject {
    enum Variant {
        Primary
    }

    property ToggleStyle _primary: ToggleStyle {
        background: Theme.colors.grey400
        backgroundChecked: Theme.colors.accent500
        backgroundDisabled: Theme.colors.grey300
        knob: Theme.colors.white500
        knobDisabled: Theme.colors.grey200
    }

    function fromVariant(variant) {
        switch (variant) {
        case ToggleStyles.Primary: return _primary
        default: {
            console.warn("Invalid ToggleStyle variant:", variant)
            return _primary
        }
        }
    }
}
