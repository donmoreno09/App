/*!
    \qmltype AlertBannerStyle
    \inqmlmodule App.Components
    \brief Value object holding all visual tokens for an AlertBanner variant.
*/

import QtQuick 6.8

QtObject {
    required property color backgroundColor
    required property color borderColor
    required property color accentColor
    required property color iconColor
    required property color titleColor
    required property color messageColor
    required property string iconText
}
