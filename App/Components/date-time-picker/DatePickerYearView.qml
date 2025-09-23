import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

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

    Layout.preferredWidth: 280
    Layout.preferredHeight: 176
    Layout.minimumWidth: 240
    Layout.minimumHeight: 144

    // Grid configuration
    model: _getYearRange()
    cellWidth: Math.floor(width / 3)
    cellHeight: 46

    // Row backgrounds (4 rows for 12 years)
    Repeater {
        model: 4 // 4 rows of years
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
        const startYear = Math.floor(currentYear / 12) * 12
        const years = []
        for (let i = 0; i < 12; i++) {
            years.push(startYear + i)
        }
        return years
    }

}
