import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

GridView {
    id: root

    property int currentYear: new Date().getFullYear()
    property int minimumYear: 1900
    property int maximumYear: 2100

    signal yearSelected(int year)

    model: _getYearRange()
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

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    function _getYearRange() {
        const startYear = Math.floor(currentYear / 12) * 12
        const years = []
        for (let i = 0; i < 12; i++) {
            years.push(startYear + i)
        }
        return years
    }

}
