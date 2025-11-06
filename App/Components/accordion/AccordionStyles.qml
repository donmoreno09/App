pragma Singleton

import QtQuick 6.8
import App.Themes 1.0

QtObject {
    enum Variant { Default, Urgent, Warning, Success }

    property AccordionStyle _default: AccordionStyle {
        backgroundColor: Theme.colors.surface
        backgroundHover: Theme.colors.primaryA5
        borderColor: Theme.colors.secondary500
        textColor: Theme.colors.text
        iconColor: Theme.colors.text
    }

    property AccordionStyle _urgent: AccordionStyle {
        backgroundColor: Theme.colors.errorA5
        backgroundHover: Theme.colors.errorA10
        borderColor: Theme.colors.error500
        textColor: Theme.colors.text
        iconColor: Theme.colors.error500
    }

    property AccordionStyle _warning: AccordionStyle {
        backgroundColor: Theme.colors.cautionA5
        backgroundHover: Theme.colors.cautionA10
        borderColor: Theme.colors.caution500
        textColor: Theme.colors.text
        iconColor: Theme.colors.caution500
    }

    property AccordionStyle _success: AccordionStyle {
        backgroundColor: Theme.colors.successA5
        backgroundHover: Theme.colors.successA10
        borderColor: Theme.colors.success500
        textColor: Theme.colors.text
        iconColor: Theme.colors.success500
    }

    function fromVariant(variant) : AccordionStyle {
        switch (variant) {
        case AccordionStyles.Default: return _default
        case AccordionStyles.Urgent: return _urgent
        case AccordionStyles.Warning: return _warning
        case AccordionStyles.Success: return _success
        default: {
            console.warn("Invalid AccordionStyle variant:", variant)
            return _default
        }
        }
    }
}
