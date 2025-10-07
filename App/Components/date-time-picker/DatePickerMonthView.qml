import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0


GridView {
    id: root

    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()

    signal monthSelected(int month)

    model: 12
    cellWidth: width / 3
    cellHeight: height / 4

    Repeater {
        model: 4
        Rectangle {
            x: 0
            y: index * (root.height / 4)
            width: root.width
            height: (root.height / 4) - Theme.spacing.s2
            color: Qt.lighter(Theme.colors.primary800, 1.1)
            radius: Theme.radius.sm
            z: -1
        }
    }

    delegate: Rectangle {
        width: GridView.view.cellWidth - Theme.spacing.s1
        height: GridView.view.cellHeight - Theme.spacing.s1

        color: _isSelected ? Theme.colors.grey400 :
               _mouseArea.containsMouse ? Theme.colors.grey500 :
               Theme.colors.transparent
        radius: Theme.radius.sm

        property bool _isSelected: index === root.currentMonth

        Text {
            anchors.centerIn: parent
            text: Qt.locale().monthName(index, Locale.ShortFormat)
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: parent._isSelected ? Theme.colors.white500 : Theme.colors.text
        }

        MouseArea {
            id: _mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.monthSelected(index)
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
