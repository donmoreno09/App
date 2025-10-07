import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: root

    property string mode: "single"
    property int currentMonth: 0
    property int currentYear: 2025

    property date selectedDate
    property date startDate
    property date endDate
    property date rangeStartTemp

    property date minimumDate
    property date maximumDate
    property var disabledDates: []

    signal dateClicked(date date)

    spacing: Theme.spacing.s3

    DayOfWeekRow {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.spacing.s6

        delegate: Text {
            text: shortName.substring(0, 3)
            font.family: Theme.typography.familySans
            font.pixelSize: Theme.typography.fontSize125
            font.weight: Theme.typography.weightRegular
            color: Theme.colors.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            required property string shortName
        }
    }

    MonthGrid {
        id: monthGrid
        Layout.fillWidth: true
        Layout.fillHeight: true

        month: root.currentMonth
        year: root.currentYear

        delegate: Item {
            required property var model

            property bool isRangeStart: root.mode === "range" && !_isEmpty(root.startDate) &&
                                       model.date.toDateString() === root.startDate.toDateString()
            property bool isRangeEnd: root.mode === "range" && !_isEmpty(root.endDate) &&
                                     model.date.toDateString() === root.endDate.toDateString()
            property bool isInRange: root.mode === "range" && root._isInRange(model.date)
            property bool isSingleDayRange: isRangeStart && isRangeEnd

            Rectangle {
                visible: model.date.getDay() === 0
                x: -parent.x
                y: 0
                width: monthGrid.width
                height: parent.height
                color: Qt.lighter(Theme.colors.primary800, 1.1)
                radius: Theme.radius.sm
                z: -1
            }

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: isRangeStart ? parent.width / 2 : 0
                    rightMargin: isRangeEnd ? parent.width / 2 : 0
                }
                visible: isInRange
                color: Theme.colors.accent100
                opacity: 0.3
                z: 0
            }

            UI.DatePickerDay {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s1

                date: model.date
                isCurrentMonth: model.month === root.currentMonth
                isToday: model.date.toDateString() === new Date().toDateString()
                isSelected: root._isDaySelected(model.date)
                isDisabled: root._isDateDisabled(model.date)

                onClicked: function(date) {
                    root.dateClicked(date)
                }
            }
        }
    }

    function _isDaySelected(date) {
        if (mode === "single") {
            return !_isEmpty(selectedDate) &&
                   date.toDateString() === selectedDate.toDateString()
        } else if (mode === "range") {
            if (!_isEmpty(startDate) && date.toDateString() === startDate.toDateString()) return true
            if (!_isEmpty(endDate) && date.toDateString() === endDate.toDateString()) return true
            if (!_isEmpty(rangeStartTemp) && date.toDateString() === rangeStartTemp.toDateString()) return true
        }
        return false
    }

    function _isInRange(date) {
        if (mode !== "range") return false
        if (_isEmpty(startDate) || _isEmpty(endDate)) return false
        return date >= startDate && date <= endDate
    }

    function _isDateDisabled(date) {
        if (date < minimumDate || date > maximumDate) return true
        if (!disabledDates || disabledDates.length === 0) return false

        const dateString = date.toDateString()
        return disabledDates.some(d => d.toDateString() === dateString)
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }
}
