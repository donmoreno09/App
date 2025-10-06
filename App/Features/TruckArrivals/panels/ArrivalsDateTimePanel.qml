import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.TruckArrivals 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

PanelTemplate {
    title.text: qsTr("Date Time Range Selection")

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TruckArrivalController { id: ctrl }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            SidePanelDateTimeContent {
                controller: ctrl
                Layout.fillWidth: true
            }
        }

        UI.Button {
            variant: UI.ButtonStyles.Primary
            text: (TranslationManager.revision, qsTr("Fetch Arrivals"))
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.margins: 10
            enabled: dtRange.hasValidSelection && !controller.isLoading
            onClicked: {
                const startDT = dtRange._combineDateTime(dtRange.startDate, dtRange.selectedHour, dtRange.selectedMinute, dtRange.selectedAMPM)
                const endDT   = dtRange._combineDateTime(dtRange.endDate,   dtRange.endHour,     dtRange.endMinute,     dtRange.endAMPM)
                controller.fetchDateTimeRangeShipArrivals(startDT, endDT)
            }
        }
    }
}
