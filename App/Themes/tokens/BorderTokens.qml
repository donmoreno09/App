/*!
    \qmltype BorderTokens
    \inqmlmodule App.Themes
    \brief Defines standard sizes for borders and focus outline rings.

    This token family centralizes stroke sizes for borders and focus rings.
    All values are device-independent pixels (dp).

    QML does not provide a generic "outline" property; implement it yourself
    as a sibling/overlay (see usage below).

    Usage:
    - Solid border:
        Rectangle {
            radius: Theme.radius.md
            border.width: Theme.borders.b2
            border.color: Theme.colors.textMuted
        }

    - Focus outline ring (outside the control):
        Item {
            width: 220
            height: 140

            // Border
            Rectangle {
                anchors.fill: parent
                radius: Theme.radius.md
                color: Theme.colors.surface
                border.width: Theme.borders.b2
                border.color: Theme.colors.textMuted
            }

            // Outline ring
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                anchors.margins: -Theme.borders.offset2 // expand outward
                border.width: Theme.borders.outline2
                radius: Theme.radius.md + Theme.borders.outline2
                border.color: Theme.colors.primary
                visible: <condition>
            }
        }

    Notes:
    - Rectangle.border.width is an int; Rectangle supports solid borders only.
    - For dashed/dotted borders, use Shape/ShapePath. Tokens for those can be
      added here later when needed.
*/

import QtQuick 2.15

QtObject {
    // Border widths (dp)
    readonly property int b0: 0
    readonly property int b1: 1
    readonly property int b2: 2
    readonly property int b4: 4
    readonly property int b6: 6
    readonly property int b8: 8

    // NOTE: QML has no built-in "outline"; implement rings as overlay siblings.
    // Focus outline ring widths (dp)
    readonly property int outline0: 0
    readonly property int outline1: 1
    readonly property int outline2: 2
    readonly property int outline4: 4
    readonly property int outline6: 6
    readonly property int outline8: 8

    // Outline offsets
    readonly property int offset0: 0
    readonly property int offset1: 1
    readonly property int offset2: 2
    readonly property int offset4: 4
}
