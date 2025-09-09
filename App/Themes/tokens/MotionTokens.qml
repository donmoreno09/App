/*!
    \qmltype MotionTokens
    \inqmlmodule App.Themes
    \brief Defines standard animation (or, "motion" for short) tokens.

    The \c {MotionTokens} family centralizes animation values.
*/

import QtQuick 6.8

QtObject {
    // Semantic Tokens
    readonly property int pulseMs: 1000
    readonly property int panelTransitionMs: 220
    readonly property real panelTransitionEasing: Easing.OutCubic
}
