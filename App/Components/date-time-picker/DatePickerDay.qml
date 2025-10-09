import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Item {
    id: root

    property date date
    property bool isCurrentMonth: false
    property bool isToday: false
    property bool isSelected: false
    property bool isDisabled: false

    signal clicked(date date)

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

    Rectangle {
        id: dayCircle
        width: Theme.spacing.s8
        height: Theme.spacing.s8
        anchors.centerIn: parent

        color: root._backgroundColor
        radius: Theme.radius.circle(width, height)

        border.width: root.isToday && root.isCurrentMonth && !root.isSelected ? Theme.borders.b1 : Theme.borders.b0
        border.color: root.isToday && root.isCurrentMonth && !root.isSelected ? Theme.colors.accent500 : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.date.getDate().toString().padStart(2, '0')

            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: root.isSelected ? Theme.typography.weightMedium : Theme.typography.weightRegular
            color: root._textColor

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

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
