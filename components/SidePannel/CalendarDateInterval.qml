import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Rectangle {
    id: calendar

    // ===== CALENDAR SIZE CONFIGURATION =====
    property real sizeRatio: 1.0
    property int maxSize: 400
    property int minSize: 150

    // ===== COMPONENT SIZE PROPERTIES =====
    property int calendarMargin: 4
    property int headerFontSize: Math.max(14, width * 0.06)
    property int headerTopMargin: 2
    property int dayNamesHeight: Math.max(16, width * 0.07)
    property int dayNamesFontSize: Math.max(12, width * 0.045)
    property int cellSpacing: 3
    property real dayCheckboxSizeRatio: 0.7
    property int dayNumberFontSize: Math.max(12, width * 0.045)
    property int navButtonHeight: Math.max(20, width * 0.07)
    property int navButtonFontSize: Math.max(12, width * 0.045)

    // ===== COLOR PROPERTIES =====
    property color accentColor: "#00BCD4"
    property color accentColorDark: "#00838F"
    property color rangeHighlightColor: Qt.rgba(0, 0.737, 0.831, 0.3)
    property color textColor: "#ffffff"
    property color disabledTextColor: "#666666"
    property color dayNamesColor: "#cccccc"

    width: Math.min(Math.max(minSize, parent ? Math.min(parent.width, parent.height) * sizeRatio : minSize), maxSize)
    height: width
    color: "transparent"
    radius: 8

    // Gradient background
    Rectangle {
        anchors.fill: parent
        z: -1
        radius: 8
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f21f3154" }
            GradientStop { position: 1.0; color: "#0F1F35" }
        }
        border.color: "#404040"
        border.width: 1
    }

    property date startDate: new Date()
    property date endDate: new Date()
    property date minimumDate: new Date(2000, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property bool selectionInProgress: false

    property date currentViewDate: new Date()

    signal rangeSelected(date startDate, date endDate)

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(month, year) {
        return new Date(year, month, 1).getDay()
    }

    function isDateInRange(date) {
        if (!startDate || !endDate) return false
        return date >= startDate && date <= endDate
    }

    function isFirstDayOfRange(date) {
        return Qt.formatDate(date, "yyyy-MM-dd") === Qt.formatDate(startDate, "yyyy-MM-dd")
    }

    function isLastDayOfRange(date) {
        return Qt.formatDate(date, "yyyy-MM-dd") === Qt.formatDate(endDate, "yyyy-MM-dd")
    }

    function isDateSelectable(date) {
        return date >= minimumDate && date <= maximumDate
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: calendarMargin
        spacing: calendarMargin

        // Header
        Text {
            id: monthHeader
            text: Qt.locale().monthName(calendar.currentViewDate.getMonth()).substring(0, 3).toUpperCase() + " " + calendar.currentViewDate.getFullYear()
            font.bold: true
            font.pixelSize: headerFontSize
            horizontalAlignment: Text.AlignHCenter
            color: textColor
            Layout.fillWidth: true
            Layout.topMargin: headerTopMargin
        }

        // Day names row
        GridLayout {
            id: dayNamesGrid
            columns: 7
            Layout.fillWidth: true
            rowSpacing: 0
            columnSpacing: 0
            Layout.preferredHeight: dayNamesHeight

            Repeater {
                model: 7
                Text {
                    text: Qt.locale().dayName(index, Locale.ShortFormat).substring(0, 2).toUpperCase()
                    font.bold: true
                    font.pixelSize: dayNamesFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: dayNamesColor
                    Layout.fillWidth: true
                }
            }
        }

        // Calendar day grid
        GridLayout {
            id: daysGrid
            columns: 7
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: cellSpacing
            columnSpacing: cellSpacing

            property int currentMonth: calendar.currentViewDate.getMonth()
            property int currentYear: calendar.currentViewDate.getFullYear()

            Repeater {
                model: firstDayOfMonth(currentMonth, currentYear)
                Item { Layout.fillWidth: true; Layout.fillHeight: true }
            }

            Repeater {
                model: daysInMonth(daysGrid.currentMonth, daysGrid.currentYear)

                Item {
                    property date cellDate: new Date(daysGrid.currentYear, daysGrid.currentMonth, index + 1)
                    property bool isInRange: calendar.isDateInRange(cellDate)
                    property bool isFirstDay: calendar.isFirstDayOfRange(cellDate)
                    property bool isLastDay: calendar.isLastDayOfRange(cellDate)
                    property bool isSelectable: calendar.isDateSelectable(cellDate)
                    property bool isCurrentMonth: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        color: "transparent"

                        Rectangle {
                            anchors {
                                fill: parent
                                leftMargin: isFirstDay ? parent.width / 2 : 0
                                rightMargin: isLastDay ? parent.width / 2 : 0
                            }
                            color: isInRange ? rangeHighlightColor : "transparent"
                        }

                        Rectangle {
                            width: parent.width * dayCheckboxSizeRatio
                            height: width
                            anchors.centerIn: parent
                            radius: width / 2
                            border.color: (isFirstDay || isLastDay) ? accentColorDark : (isSelectable ? "#444" : "#333")
                            border.width: 1
                            color: (isFirstDay || isLastDay) ? accentColor : (isSelectable ? "transparent" : Qt.rgba(0.2, 0.2, 0.2, 0.5))
                        }

                        Text {
                            text: index + 1
                            anchors.centerIn: parent
                            color: {
                                if (isFirstDay || isLastDay) return "white"
                                return isSelectable ? (isInRange ? accentColor : textColor) : disabledTextColor
                            }
                            font.pixelSize: dayNumberFontSize
                            font.bold: isFirstDay || isLastDay
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: isSelectable
                            onClicked: {
                                if (!selectionInProgress || !startDate) {
                                    selectionInProgress = true
                                    startDate = cellDate
                                    endDate = cellDate
                                } else {
                                    selectionInProgress = false
                                    if (cellDate > startDate) {
                                        endDate = cellDate
                                    } else {
                                        endDate = startDate
                                        startDate = cellDate
                                    }
                                    rangeSelected(startDate, endDate)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Navigation arrows
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: navButtonHeight
            spacing: 0

            Button {
                id: prevButton
                text: "◀"
                font.pixelSize: navButtonFontSize
                flat: true
                hoverEnabled: true
                onClicked: {
                    var d = new Date(calendar.currentViewDate)
                    d.setMonth(d.getMonth() - 1)
                    if (d >= calendar.minimumDate)
                        calendar.currentViewDate = d
                }
                background: Rectangle {
                    color: prevButton.hovered ? "#404040" : "transparent"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: prevButton.hovered ? "#FFFFFF" : textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                id: nextButton
                text: "▶"
                font.pixelSize: navButtonFontSize
                flat: true
                hoverEnabled: true
                onClicked: {
                    var d = new Date(calendar.currentViewDate)
                    d.setMonth(d.getMonth() + 1)
                    if (d <= calendar.maximumDate)
                        calendar.currentViewDate = d
                }
                background: Rectangle {
                    color: nextButton.hovered ? "#404040" : "transparent"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: nextButton.hovered ? "#FFFFFF" : textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
