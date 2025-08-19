/*!
    \qmltype RadiusTokens
    \inqmlmodule App.Themes
    \brief Defines the standard corner radius scale and special helpers for rounded shapes.

    This token family standardizes corner radii across components.
    All values are device-independent pixels (dp) and follow a 4px rhythm.

    Usage:
    - Bind directly to radius properties:
        Rectangle { radius: Theme.radius.md }
    - For per-corner radii (Qt 6.7+):
        Rectangle {
            topLeftRadius: Theme.radius.lg
            topRightRadius: Theme.radius.lg
            bottomLeftRadius: Theme.radius.none
            bottomRightRadius: Theme.radius.none
        }
    - Pill shape:
        Rectangle {
            width: 160; height: 32
            radius: Theme.radius.full(height)   // 16
        }
    - Perfect circle:
        Rectangle {
            width: 64; height: 64
            radius: Theme.radius.circle(width, height) // 32
            clip: true
        }

    Clipping:
    - Rounded Rectangle does NOT clip children. Only set clip: true when
      children must not overflow rounded edges (e.g., images, scroll content).
*/

import QtQuick 2.15

QtObject {
    // Core scale (device-independent pixels)
    readonly property int none: 0
    readonly property int xs:   2
    readonly property int sm:   4
    readonly property int md:   8
    readonly property int lg:   12
    readonly property int xl:   16
    readonly property int x2l:  24
    readonly property int x3l:  32

    // Specials
    function full(height) {
        // Pill radius: typically height / 2
        return Math.max(0, Math.floor(height / 2))
    }

    function circle(width, height) {
        // Perfect circle radius: min(width, height) / 2
        return Math.max(0, Math.floor(Math.min(width, height) / 2))
    }
}
