import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import ShipArrivalController 1.0
import ".."
import raise.singleton.language 1.0

ColumnLayout {
    id: root
    spacing: 20

    property color disabledColor: "#808080"

    required property ShipArrivalController controller

    // Automatic retranslation properties
    property string dateTimeRangeSelectionTitle: qsTr("Date Time Range Selection")
    property string startTimeLabel: qsTr("Start Time")
    property string endTimeLabel: qsTr("End Time")
    property string selectedPrefix: qsTr("Selected: ")
    property string selectDateRangeText: qsTr("Select a date range")
    property string arrivingTrucksTitle: qsTr("Arriving trucks")
    property string fetchArrivalsText: qsTr("Fetch Arrivals")
    property string truckSingular: qsTr(" truck")
    property string truckPlural: qsTr(" trucks")
    property string zeroTrucksText: qsTr("0 trucks")

    // Auto-retranslate when language changes
    function retranslateUi() {
        dateTimeRangeSelectionTitle = qsTr("Date Time Range Selection")
        startTimeLabel = qsTr("Start Time")
        endTimeLabel = qsTr("End Time")
        selectedPrefix = qsTr("Selected: ")
        selectDateRangeText = qsTr("Select a date range")
        arrivingTrucksTitle = qsTr("Arriving trucks")
        fetchArrivalsText = qsTr("Fetch Arrivals")
        truckSingular = qsTr(" truck")
        truckPlural = qsTr(" trucks")
        zeroTrucksText = qsTr("0 trucks")
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        running: controller.isLoading
        visible: controller.isLoading
        Layout.fillHeight: true
    }

    ColumnLayout {
        visible: !controller.isLoading
        spacing: 20
        Layout.fillWidth: true

        Text {
            text: root.dateTimeRangeSelectionTitle
            font.pixelSize: 18
            font.bold: true
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            height: 1
            color: "#dddddd"
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15

            CalendarDateInterval {
                id: rangeCalendar
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 300
                Layout.preferredHeight: 300
                sizeRatio: 0.9

                onRangeSelected: {
                    startDate = start
                    endDate = end
                    updateTimePickers()
                }
            }

            RowLayout {
                spacing: 20
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    Text {
                        text: root.startTimeLabel
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                    }

                    TimePicker {
                        id: startTimePicker
                        Layout.alignment: Qt.AlignHCenter
                        isStartPicker: true
                        linkedDateTime: getEndDateTime()
                        selectedDate: rangeCalendar.startDate
                    }
                }

                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    Text {
                        text: root.endTimeLabel
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                    }

                    TimePicker {
                        id: endTimePicker
                        Layout.alignment: Qt.AlignHCenter
                        isStartPicker: false
                        linkedDateTime: getStartDateTime()
                        selectedDate: rangeCalendar.endDate
                    }
                }
            }

            Text {
                text: rangeCalendar.startDate && rangeCalendar.endDate ?
                    root.selectedPrefix + Qt.formatDateTime(getStartDateTime(), "dd MMM yyyy hh:mm") +
                    " - " + Qt.formatDateTime(getEndDateTime(), "dd MMM yyyy hh:mm") :
                    root.selectDateRangeText
                font.pixelSize: 14
                color: isDateTimeRangeValid() ? "#CCCCCC" : "#ff0000"
                Layout.alignment: Qt.AlignHCenter
            }

            SidePannelStatCard {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 10
                icon: "🚚"
                title: root.arrivingTrucksTitle
                value: controller.dateTimeRangeArrivalCount >= 0 ?
                    controller.dateTimeRangeArrivalCount + (controller.dateTimeRangeArrivalCount === 1 ? root.truckSingular : root.truckPlural) :
                    root.zeroTrucksText
            }
        }

        Button {
            text: root.fetchArrivalsText
            enabled: !controller.isLoading && rangeCalendar.startDate && rangeCalendar.endDate
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            background: Rectangle {
                radius: 8
                color: enabled ? "#1565C0" : disabledColor
                border.color: "#444"
                border.width: 1
                opacity: enabled ? 0.95 : 0.6

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: parent.color = Qt.darker("#1565C0", 1.2)
                    onReleased: parent.color = "#1565C0"
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.95
                }
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                controller.fetchDateTimeRangeShipArrivals(
                    getStartDateTime(),
                    getEndDateTime()
                )
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    function getStartDateTime() {
        if (!rangeCalendar.startDate) return new Date()
        var dt = new Date(rangeCalendar.startDate)
        dt.setHours(startTimePicker.hour)
        dt.setMinutes(startTimePicker.minute)
        return dt
    }

    function getEndDateTime() {
        if (!rangeCalendar.endDate) return new Date()
        var dt = new Date(rangeCalendar.endDate)
        dt.setHours(endTimePicker.hour)
        dt.setMinutes(endTimePicker.minute)
        return dt
    }

    function isDateTimeRangeValid() {
        return getStartDateTime() < getEndDateTime()
    }

    function updateTimePickers() {
        startTimePicker.updateLinkedDateTime(getEndDateTime())
        endTimePicker.updateLinkedDateTime(getStartDateTime())
    }

    Component.onCompleted: {
        var today = new Date()
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)

        rangeCalendar.startDate = today
        rangeCalendar.endDate = tomorrow
        updateTimePickers()
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            root.retranslateUi()
        }

        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
