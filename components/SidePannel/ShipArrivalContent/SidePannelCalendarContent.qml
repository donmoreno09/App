import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import ShipArrivalController 1.0
import "../"
import raise.singleton.language 1.0

ColumnLayout {
    id: root
    spacing: 20

    property color backgroundColor: "#cc1e2f40"
    property color highlightColor: "#4CAF50"
    property color textColor: "white"
    property color disabledColor: "#666666"
    property color borderColor: "#444"

    required property ShipArrivalController controller

    // Automatic retranslation properties
    property string dateRangeSelectionTitle: qsTr("Date Range Selection")
    property string selectedPrefix: qsTr("Selected: ")
    property string selectDateRangeText: qsTr("Select a date range")
    property string arrivingTrucksTitle: qsTr("Arriving Trucks")
    property string fetchArrivalsText: qsTr("Fetch Arrivals")
    property string truckSingular: qsTr(" truck")
    property string truckPlural: qsTr(" trucks")
    property string zeroTrucksText: qsTr("0 trucks")

    // Auto-retranslate when language changes
    function retranslateUi() {
        dateRangeSelectionTitle = qsTr("Date Range Selection")
        selectedPrefix = qsTr("Selected: ")
        selectDateRangeText = qsTr("Select a date range")
        arrivingTrucksTitle = qsTr("Arriving Trucks")
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
            text: root.dateRangeSelectionTitle
            font.pixelSize: 18
            font.bold: true
            color: textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            height: 1
            color: borderColor
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
                    controller.fetchDateRangeShipArrivals(start, end)
                }
            }

            Text {
                text: rangeCalendar.startDate && rangeCalendar.endDate ?
                    root.selectedPrefix + Qt.formatDate(rangeCalendar.startDate, "dd MMM yyyy") +
                    " - " + Qt.formatDate(rangeCalendar.endDate, "dd MMM yyyy") :
                    root.selectDateRangeText
                font.pixelSize: 14
                color: disabledColor
                Layout.alignment: Qt.AlignHCenter
            }

            SidePannelStatCard {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 10
                icon: "🚚️"
                title: root.arrivingTrucksTitle
                value: controller.dateRangeArrivalCount >= 0 ?
                    controller.dateRangeArrivalCount + (controller.dateRangeArrivalCount === 1 ? root.truckSingular : root.truckPlural) :
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
                border.color: borderColor
                border.width: 1
                opacity: enabled ? 0.95 : 0.6

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
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
                controller.fetchDateRangeShipArrivals(
                    rangeCalendar.startDate,
                    rangeCalendar.endDate
                )
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        var today = new Date()
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)

        rangeCalendar.startDate = today
        rangeCalendar.endDate = tomorrow
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
