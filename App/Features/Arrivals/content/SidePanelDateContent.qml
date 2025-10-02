import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.Arrivals 1.0
import App.Features.Language 1.0

ColumnLayout {
    id: root
    spacing: 20

    required property ShipArrivalController controller

    // Date range picker (replacing CalendarDateInterval)
    UI.DatePicker {
        id: rangePicker
        mode: "range"
        Layout.alignment: Qt.AlignHCenter

        // old panel triggered fetch on range selection — keep that behavior
        onRangeSelected: function(startDate, endDate) {
            controller.fetchDateRangeShipArrivals(startDate, endDate)
        }
    }

    // Selected range label (same UX, updated to DatePicker API)
    Text {
        Layout.fillWidth: true
        text: (rangePicker.startDate && rangePicker.endDate)
              ? (TranslationManager.revision, qsTr("Selected: %1 — %2"))
                    .arg(Qt.formatDate(rangePicker.startDate, "dd/MM/yyyy"))
                    .arg(Qt.formatDate(rangePicker.endDate,   "dd/MM/yyyy"))
              : (TranslationManager.revision, qsTr("Select a date range"))
        color: Theme.colors.text
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    // Stat card for the total in the selected date range
    StatCard {
        icon: "qrc:/App/assets/icons/truck.svg"
        title: (TranslationManager.revision, qsTr("Arrivals in range"))
        value: controller.dateRangeArrivalCount >= 0
               ? controller.dateRangeArrivalCount.toString()
               : "0"
        Layout.fillWidth: true
    }

    // Manual (re)fetch button (kept from original UX)
    UI.Button {
        enabled: !controller.isLoading && (rangePicker.startDate && rangePicker.endDate)
        contentItem: Text {
            text: (TranslationManager.revision, qsTr("Fetch Range"))
            color: Theme.colors.text
            anchors.centerIn: parent
        }
        onClicked: controller.fetchDateRangeShipArrivals(rangePicker.startDate, rangePicker.endDate)
    }

    // Default selection: today → tomorrow (as before)
    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today)
        tomorrow.setDate(today.getDate() + 1)
        rangePicker.startDate = today
        rangePicker.endDate = tomorrow
    }

}
