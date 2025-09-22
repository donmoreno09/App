/*!
    \qmltype ToggleStyle
    \inqmlmodule App.Components
    \brief Style contract/interface for Toggle component variants.

    Defines the required color properties that each toggle variant must provide.
    This ensures consistent theming and enables autocomplete for variant styles.
*/

import QtQuick 6.8

QtObject {
    required property color background
    required property color backgroundChecked
    required property color backgroundDisabled
    required property color knob
    required property color knobDisabled
}
