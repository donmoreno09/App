import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePickerPopup
    \brief Calendar popup for date selection

    Separated from main component to keep it focused.
    Uses your theme system and Button components.
*/

Popup {
    id: root

    // Props from parent
    property date selectedDate
    property date minimumDate
    property date maximumDate
    property var disabledDates: []
    property string dateFormat

    // Signals
    signal dateSelected(date date)
    signal cleared()

    // Popup positioning - anchors to input field
    x: 0
    y: parent.height
    width: parent.width
    height: 380

    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Background with dark theme styling
    background: Rectangle {
        color: Theme.colors.primary800  // Dark background like the design
        border.color: Theme.colors.secondary500
        border.width: Theme.borders.b1
        radius: Theme.radius.md

        // Drop shadow
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: Theme.spacing.s1
            anchors.leftMargin: Theme.spacing.s1
            z: Theme.elevation.background
            color: Theme.colors.blackA40
            radius: parent.radius
        }
    }

    // Calendar content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        // Month/Year header with navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s10

            // Previous month button - styled arrow
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s8
                Layout.preferredHeight: Theme.spacing.s8
                variant: "ghost"
                display: AbstractButton.IconOnly
                backgroundRect.color: Theme.colors.transparent
                backgroundRect.border.width: Theme.borders.b0

                contentItem: Text {
                    anchors.centerIn: parent
                    text: "❮"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.text
                }

                onClicked: {
                    if (monthGrid.month === 0) {
                        monthGrid.month = 11
                        monthGrid.year--
                    } else {
                        monthGrid.month--
                    }
                }
            }

            // Month/Year title
            Text {
                Layout.fillWidth: true
                text: Qt.locale().monthName(monthGrid.month) + " " + monthGrid.year

                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightMedium
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.text
            }

            // Next month button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s8
                Layout.preferredHeight: Theme.spacing.s8
                variant: "ghost"
                display: AbstractButton.IconOnly
                backgroundRect.color: Theme.colors.transparent
                backgroundRect.border.width: Theme.borders.b0

                contentItem: Text {
                    anchors.centerIn: parent
                    text: "❯"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.text
                }

                onClicked: {
                    if (monthGrid.month === 11) {
                        monthGrid.month = 0
                        monthGrid.year++
                    } else {
                        monthGrid.month++
                    }
                }
            }
        }

        // Day of week header - styled like design
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

        // Calendar grid
        MonthGrid {
            id: monthGrid
            Layout.fillWidth: true
            Layout.fillHeight: true

            month: {
                if (root.selectedDate && !isNaN(root.selectedDate.getTime())) {
                    return root.selectedDate.getMonth()
                }
                return new Date().getMonth()
            }

            year: {
                if (root.selectedDate && !isNaN(root.selectedDate.getTime())) {
                    return root.selectedDate.getFullYear()
                }
                return new Date().getFullYear()
            }

            delegate: DateTimePickerDay {
                required property var model

                date: model.date
                isCurrentMonth: model.month === monthGrid.month
                isToday: model.date.toDateString() === new Date().toDateString()
                isSelected: !_isEmpty(root.selectedDate) && model.date.toDateString() === root.selectedDate.toDateString()
                isDisabled: _isDateDisabled(model.date)

                onClicked: function(date) {
                    if (!isDisabled && isCurrentMonth) {
                        // Just update the selected date, don't close popup
                        root.selectedDate = date
                    }
                }
            }
        }

        // Action buttons - styled to match design exactly
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.s4
            spacing: Theme.spacing.s3

            // Clear button - subtle text button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.s10
                color: Theme.colors.transparent

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightRegular
                    color: root._isEmpty(root.selectedDate) ? Theme.colors.textMuted : Theme.colors.text
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !root._isEmpty(root.selectedDate)
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        if (enabled) {
                            root.cleared()
                            root.close()
                        }
                    }
                }
            }

            // Apply button - solid blue button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.s10
                color: enabled ? Theme.colors.accent500 : Theme.colors.secondary500
                radius: Theme.radius.sm

                property bool enabled: !root._isEmpty(root.selectedDate) && root._isValidDate(root.selectedDate)

                Text {
                    anchors.centerIn: parent
                    text: "Apply"
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    font.weight: Theme.typography.weightRegular
                    color: parent.enabled ? Theme.colors.white500 : Theme.colors.textMuted
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: parent.enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        if (enabled) {
                            root.dateSelected(root.selectedDate)
                            root.close()
                        }
                    }
                }

                // Smooth color transition
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    // Helper functions
    function toggle() {
        if (opened) {
            close()
        } else {
            // Initialize calendar to current date or selected date
            if (!_isEmpty(root.selectedDate)) {
                monthGrid.month = root.selectedDate.getMonth()
                monthGrid.year = root.selectedDate.getFullYear()
            }
            open()
        }
    }

    function _isEmpty(date) {
        return !date || isNaN(date.getTime())
    }

    function _isValidDate(date) {
        if (_isEmpty(date)) return false
        if (date < root.minimumDate || date > root.maximumDate) return false
        return !_isDateDisabled(date)
    }

    function _isDateDisabled(date) {
        if (!root.disabledDates || root.disabledDates.length === 0) return false
        const dateString = date.toDateString()
        return root.disabledDates.some(d => d.toDateString() === dateString)
    }
}
