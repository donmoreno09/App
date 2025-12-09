import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects

import App.Components 1.0 as UI
import App.Themes 1.0
import App.Features.TruckArrivals 1.0
import App.Features.Language 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Theme.spacing.s5

    required property TruckArrivalController controller

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.DateTimePicker {
        id: dtRange
        mode: "range"
        is24Hour: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 10
        visible: !controller.isLoading
    }

    Text {
        visible: !controller.isLoading
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        color: Theme.colors.textMuted
        text: dtRange.rangeText
    }

    StatCard {
        visible: !controller.isLoading
        icon: "qrc:/App/assets/icons/truck.svg"
        title: `${TranslationManager.revision}` && qsTr("Arriving Trucks")
        value: controller.dateTimeRangeArrivalCount.toString() + " " + qsTr(" trucks")
        Layout.fillWidth: true
    }

    UI.VerticalSpacer {}

    UI.Button {
        visible: !controller.isLoading
        variant: UI.ButtonStyles.Primary
        text: `${TranslationManager.revision}` && qsTr("Fetch Arrivals")
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.margins: 10
        enabled: dtRange.hasValidSelection && !controller.isLoading
        onClicked: {
            const startDT = dtRange._combineDateTime(dtRange.startDate, dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)
            const endDT   = dtRange._combineDateTime(dtRange.endDate,   dtRange.endHour,     dtRange.endMinute,     dtRange.endAMPM)

            console.log("========== QML DATETIME DEBUG ==========")
            console.log("Start Date:", dtRange.startDate)
            console.log("Start Hour:", dtRange.selectedHour)
            console.log("Start Minute:", dtRange.selectedMinute)
            console.log("Start AM/PM:", dtRange.selectedAMPM)
            console.log("Start DateTime Combined:", startDT)
            console.log("Start DateTime ISO:", startDT.toISOString())
            console.log("Start DateTime LocaleString:", startDT.toLocaleString())
            console.log("")
            console.log("End Date:", dtRange.endDate)
            console.log("End Hour:", dtRange.endHour)
            console.log("End Minute:", dtRange.endMinute)
            console.log("End AM/PM:", dtRange.endAMPM)
            console.log("End DateTime Combined:", endDT)
            console.log("End DateTime ISO:", endDT.toISOString())
            console.log("End DateTime LocaleString:", endDT.toLocaleString())
            console.log("==========================================")

            controller.fetchDateTimeRangeShipArrivals(startDT, endDT)
        }
    }

    Component.onCompleted: {
        const today = new Date()
        const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1)
        dtRange.setDateRange(today, tomorrow)
    }
}
