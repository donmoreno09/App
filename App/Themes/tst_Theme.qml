import QtQuick
import QtTest

import App.Themes 1.0

TestCase {
    name: "ThemeSingleton"

    // Spies for the Theme singleton signals
    SignalSpy { id: aboutToChangeSpy; target: Theme; signalName: "themeAboutToChange" }
    SignalSpy { id: changedSpy;       target: Theme; signalName: "themeChanged" }

    function clearSpies() {
        aboutToChangeSpy.clear()
        changedSpy.clear()
    }

    function init() {
        Theme.setTheme(Themes.Fincantieri)
        clearSpies()
    }

    function cleanup() {
        // Restore default after each test
        Theme.setTheme(Themes.Fincantieri)
        clearSpies()
    }

    function test_token_facades_initial_state_non_null() {
        verify(Theme.current !== null, "Theme.current should be set after init")
        compare(Theme.currentVariant, Themes.Fincantieri)

        // Token facades should be available when current != null
        verify(Theme.colors      !== null)
        verify(Theme.typography  !== null)
        verify(Theme.spacing     !== null)
        verify(Theme.radius      !== null)
        verify(Theme.borders     !== null)
        verify(Theme.elevation   !== null)
        verify(Theme.opacity     !== null)
        verify(Theme.icons       !== null)
        verify(Theme.effects     !== null)
    }

    function test_switch_variant_emits_signals_and_updates_state() {
        const oldCurrent = Theme.current

        const hasChangedTheme = Theme.setTheme(Themes.FincantieriLight)

        verify(hasChangedTheme, "setTheme should return true when switching variants")
        // Signals
        // The signal arguments contains a list of objects with
        // numbered keys corresponding to the signal's arguments
        compare(aboutToChangeSpy.count, 1)
        compare(aboutToChangeSpy.signalArguments[0][0], Themes.Fincantieri)        // fromVariant
        compare(aboutToChangeSpy.signalArguments[0][1], Themes.FincantieriLight)   // toVariant
        compare(changedSpy.count, 1)
        compare(changedSpy.signalArguments[0][0], Themes.FincantieriLight)   // variant
        // Current theme state
        compare(Theme.currentVariant, Themes.FincantieriLight)
        verify(Theme.current !== null)
        verify(Theme.current !== oldCurrent, "Theme.current should be a new theme object after switch")
        // Check if facades still wired
        verify(Theme.colors !== null)
    }

    function test_switch_same_variant_does_nothing() {
        // Make sure we're on Light
        Theme.setTheme(Themes.FincantieriLight)
        clearSpies()

        const hasChangedTheme = Theme.setTheme(Themes.FincantieriLight) // same as current

        verify(hasChangedTheme, "setTheme returns true even if variant is unchanged")
        compare(aboutToChangeSpy.count, 0)
        compare(changedSpy.count, 0)
        compare(Theme.currentVariant, Themes.FincantieriLight)
    }

    function test_invalid_variant_returns_false_and_no_change() {
        const beforeVariant = Theme.currentVariant
        const beforeObj = Theme.current
        clearSpies()

        const hasChangedTheme = Theme.setTheme(-1) // invalid theme

        verify(!hasChangedTheme, "setTheme should return false on unknown variant")
        compare(aboutToChangeSpy.count, 0)
        compare(changedSpy.count, 0)
        compare(Theme.currentVariant, beforeVariant)
        compare(Theme.current, beforeObj)
    }
}
