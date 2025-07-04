import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Rectangle {
    id: timePicker

    property int headerFontSize: 12
    property int valueFontSize: 14
    property int buttonFontSize: 10
    property color highlightColor: "darkblue"
    property color textColor: "white"
    property color disabledColor: "#666666"
    property color backgroundColor: "#1e2f40"
    property color borderColor: "#444"

    width: 120
    height: 40
    radius: 6
    color: backgroundColor
    border.color: borderColor
    border.width: 1

    property int hour: new Date().getHours()
    property int minute: Math.floor(new Date().getMinutes() / 30) * 30
    property bool isStartPicker: false
    property date linkedDateTime: new Date()
    property date selectedDate: new Date()

    signal timeSelected(int hour, int minute)

    function isTimeValid(h, m) {
        var testDateTime = new Date(selectedDate)
        testDateTime.setHours(h)
        testDateTime.setMinutes(m)
        return isStartPicker ? testDateTime <= linkedDateTime
                             : testDateTime >= linkedDateTime
    }

    function updateLinkedDateTime(dt) {
        linkedDateTime = dt
        if (!isTimeValid(hour, minute)) {
            if (Qt.formatDate(selectedDate, "yyyy-MM-dd") === Qt.formatDate(linkedDateTime, "yyyy-MM-dd")) {
                var newHour = isStartPicker ? Math.min(hour, linkedDateTime.getHours())
                                            : Math.max(hour, linkedDateTime.getHours())
                var newMinute = minute

                if (newHour === linkedDateTime.getHours()) {
                    newMinute = isStartPicker ? Math.min(minute, linkedDateTime.getMinutes())
                                              : Math.max(minute, linkedDateTime.getMinutes())
                }
                setTime(newHour, newMinute)
            }
        }
    }

    Text {
        id: timeDisplay
        anchors.centerIn: parent
        text: Qt.formatTime(new Date(0, 0, 0, hour, minute), "hh:mm")
        font.pixelSize: valueFontSize
        font.bold: true
        color: isTimeValid(hour, minute) ? textColor : "#ff6b6b"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: dropdown.open()
    }

    Popup {
        id: dropdown
        y: parent.height + 4
        width: parent.width
        height: Math.min(300, timeList.contentHeight + 2)
        padding: 1
        modal: true
        focus: true

        background: Rectangle {
            color: Qt.darker(backgroundColor, 1.2)
            border.color: borderColor
            border.width: 1
            radius: 6
        }

        contentItem: ListView {
            id: timeList
            clip: true

            model: ListModel {
                id: timeModel
                Component.onCompleted: {
                    for (var h = 0; h < 24; h++) {
                        for (var m = 0; m < 60; m += 30) {
                            append({
                                hour: h,
                                minute: m,
                                display: Qt.formatTime(new Date(0, 0, 0, h, m), "hh:mm")
                            })
                        }
                    }
                }
            }

            delegate: Rectangle {
                width: dropdown.width
                height: 32
                color: ListView.isCurrentItem ? highlightColor :
                       (mouseArea.containsMouse ? Qt.darker(highlightColor, 1.3) : "transparent")
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: display
                    font.pixelSize: valueFontSize
                    color: {
                        if (ListView.isCurrentItem) return "white"
                        return isTimeValid(hour, minute) ? textColor : "#ff6b6b"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        timePicker.setTime(hour, minute)
                        dropdown.close()
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6

                background: Rectangle {
                    color: "#333"
                    radius: 3
                }

                contentItem: Rectangle {
                    color: "#666"
                    radius: 3
                }
            }

            currentIndex: {
                for (var i = 0; i < timeModel.count; i++) {
                    if (timeModel.get(i).hour === hour && timeModel.get(i).minute === minute) {
                        return i
                    }
                }
                return -1
            }
        }
    }

    function setTime(h, m) {
        var roundedMinute = Math.floor(m / 30) * 30
        hour = Math.max(0, Math.min(23, h))
        minute = roundedMinute
        timeSelected(hour, minute)
    }
}
