import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

/*!
    \qmltype DatePickerYearView
    \brief Year selection grid for DatePicker
*/

GridView {
    id: root

    // Props
    property int currentYear: new Date().getFullYear()
    property int minimumYear: 1900
    property int maximumYear: 2100

    // Signals
    signal yearSelected(int year)

    // Grid configuration
    model: _getYearRange()
    cellWidth: width / 4
    cellHeight: height / 5

    delegate: Rectangle {
        width: GridView.view.cellWidth - Theme.spacing.s1
        height: GridView.view.cellHeight - Theme.spacing.s1

        color: _isSelected ? Theme.colors.accent500 :
               _mouseArea.containsMouse ? Theme.colors.secondary500 :
               Theme.colors.transparent
        radius: Theme.radius.sm

        property bool _isSelected: modelData === root.currentYear
        property bool _isDisabled: modelData < root.minimumYear || modelData > root.maximumYear

        Text {
            anchors.centerIn: parent
            text: modelData.toString()
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize150
            font.weight: Theme.typography.weightRegular
            color: parent._isDisabled ? Theme.colors.textMuted :
                   parent._isSelected ? Theme.colors.white500 :
                   Theme.colors.text
        }

        MouseArea {
            id: _mouseArea
            anchors.fill: parent
            hoverEnabled: !parent._isDisabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: !parent._isDisabled

            onClicked: {
                if (enabled) {
                    root.yearSelected(modelData)
                }
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

    // Helper functions
    function _getYearRange() {
        const startYear = Math.floor(currentYear / 20) * 20
        const years = []
        for (let i = 0; i < 20; i++) {
            years.push(startYear + i)
        }
        return years
    }
}
