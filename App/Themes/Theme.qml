// Themes/Theme.qml
pragma Singleton

import QtQuick

import "tokens"
import "variants"

QtObject {
    id: root

    // States
    property int currentVariant: Themes.Fincantieri
    property BaseTheme current: null

    // Token facades
    readonly property ColorTokens       colors:     current ? current.colors     : null
    readonly property TypographyTokens  typography: current ? current.typography : null
    readonly property SpacingTokens     spacing:    current ? current.spacing    : null
    readonly property RadiusTokens      radius:     current ? current.radius     : null
    readonly property BorderTokens      borders:    current ? current.borders    : null
    readonly property ElevationTokens   elevation:  current ? current.elevation  : null
    readonly property OpacityTokens     opacity:    current ? current.opacity    : null
    readonly property IconTokens        icons:      current ? current.icons      : null
    readonly property EffectTokens      effects:    current ? current.effects    : null
    readonly property LayoutTokens      layout:     current ? current.layout     : null

    // Signals
    signal themeAboutToChange(int fromVariant, int toVariant)
    signal themeChanged(int variant)

    // Slots
    Component.onCompleted: setTheme(currentVariant)

    // Methods
    function setTheme(variant) {
        if (variant === currentVariant && current) return true

        let url = ""
        switch (variant) {
        case Themes.Fincantieri:
            url = Qt.resolvedUrl("variants/Fincantieri.qml")
            break
        case Themes.FincantieriLight:
            url = Qt.resolvedUrl("variants/FincantieriLight.qml")
            break
        default:
            console.error("Theme.setTheme: unknown variant:", variant)
            return false
        }

        const themeComponent = Qt.createComponent(url)
        if (themeComponent.status === Component.Error) {
            console.error("Theme: load error:", themeComponent.errorString())
            return false
        }

        const theme = themeComponent.createObject(root)
        if (!theme) {
            console.error("Theme: invalid BaseTheme instance for", url)
            if (theme) theme.destroy()
            return false
        }

        const fromVariant = currentVariant
        themeAboutToChange(fromVariant, variant)

        const oldTheme = current
        current = theme
        currentVariant = variant
        if (oldTheme) oldTheme.destroy()

        themeChanged(currentVariant)
        return true
    }
}
