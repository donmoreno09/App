/*!
    \qmltype AlertBannerStyles
    \inqmlmodule App.Components
    \brief Singleton factory for AlertBanner variant styles.

    Mirrors the ButtonStyles / InputStyles / AccordionStyles pattern:
    an enum + fromVariant() function so call-sites bind a single int.
*/

pragma Singleton

import QtQuick 6.8
import App.Themes 1.0

QtObject {
    enum Variant { Error, Warning, Success, Info }

    property AlertBannerStyle _error: AlertBannerStyle {
        backgroundColor: Theme.colors.errorA5
        borderColor:     Theme.colors.errorA20
        accentColor:     Theme.colors.error
        iconColor:       Theme.colors.error
        titleColor:      Theme.colors.text
        messageColor:    Theme.colors.textMuted
        iconText:        "\u2297"   // ⊗  circled times — matches screenshot
    }

    property AlertBannerStyle _warning: AlertBannerStyle {
        backgroundColor: Theme.colors.warningA5
        borderColor:     Theme.colors.warningA20
        accentColor:     Theme.colors.warning500
        iconColor:       Theme.colors.warning500
        titleColor:      Theme.colors.text
        messageColor:    Theme.colors.textMuted
        iconText:        "\u26A0"   // ⚠
    }

    property AlertBannerStyle _success: AlertBannerStyle {
        backgroundColor: Theme.colors.successA5
        borderColor:     Theme.colors.successA20
        accentColor:     Theme.colors.success500
        iconColor:       Theme.colors.success500
        titleColor:      Theme.colors.text
        messageColor:    Theme.colors.textMuted
        iconText:        "\u2713"   // ✓
    }

    property AlertBannerStyle _info: AlertBannerStyle {
        backgroundColor: Theme.colors.primaryA5
        borderColor:     Theme.colors.primaryA20
        accentColor:     Theme.colors.accent500
        iconColor:       Theme.colors.accent500
        titleColor:      Theme.colors.text
        messageColor:    Theme.colors.textMuted
        iconText:        "\u24D8"   // ⓘ
    }

    function fromVariant(variant) : AlertBannerStyle {
        switch (variant) {
        case AlertBannerStyles.Error:   return _error
        case AlertBannerStyles.Warning: return _warning
        case AlertBannerStyles.Success: return _success
        case AlertBannerStyles.Info:    return _info
        default: {
            console.warn("Invalid AlertBannerStyles variant:", variant)
            return _error
        }
        }
    }
}
