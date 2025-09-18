import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

/*!
    \qmltype DatePickerMonthView
    \brief Month selection grid for DatePicker
*/

GridView {
    id: root

    // Props
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()

    // Signals
    signal monthSelected(int month)

    // Grid configuration
    model: 12
    cellWidth: width / 3
    cellHeight: height / 4

    delegate: Rectangle {
        width: GridView.view.cellWidth - Theme.spacing.s1
        height: GridView.view.cellHeight - Theme.spacing.s1

        color: _isSelected ? Theme.colors.accent500 :
               _mouseArea.containsMouse ? Theme.colors.secondary500 :
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

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
