import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

/*!
    \qmltype DateTimePickerDay
    \brief Individual day cell in the calendar grid

    Micro-component for calendar days. Follows your design system patterns.
    Similar to how you might structure a notification item or button state.
*/

Item {
    id: root
    anchors.margins: Theme.spacing.s1

    // Props
    property date date
    property bool isCurrentMonth: false
    property bool isToday: false
    property bool isSelected: false
    property bool isDisabled: false

    // Signals
    signal clicked(date date)

    // Visual state - matching the design colors
    readonly property color _backgroundColor: {
        if (isDisabled) return Theme.colors.transparent
        if (isSelected) return Theme.colors.accent500  // Blue selection
        if (isToday && isCurrentMonth && !isSelected) return "transparent"  // Transparent for today
        if (mouseArea.containsMouse && isCurrentMonth && !isDisabled) return Theme.colors.secondary500
        return Theme.colors.transparent
    }

    readonly property color _textColor: {
        if (isDisabled) return Theme.colors.textMuted
        if (isSelected) return Theme.colors.white500
        if (!isCurrentMonth) return Theme.colors.textMuted
        return Theme.colors.text
    }

    // Day cell background
    Rectangle {
        width: Theme.spacing.s8  // 32px
        height: Theme.spacing.s8 // 32px
        anchors.centerIn: parent

        color: root._backgroundColor
        radius: Theme.radius.circle(width, height) // Always circular like the design

        // Remove today indicator border since we use background color
        border.width: root.isToday && root.isCurrentMonth ? Theme.borders.b1 : Theme.borders.b0
        border.color: root.isToday && root.isCurrentMonth ? "white" : "transparent"

        // Smooth transitions
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        // Day number text
        Text {
            anchors.centerIn: parent
            text: root.date.getDate().toString().padStart(2, '0') // Always 2 digits like design

            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: root._textColor
        }
    }

    // Click handling
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !isDisabled && isCurrentMonth
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (!isDisabled && isCurrentMonth) {
                root.clicked(root.date)
            }
        }
    }
}
