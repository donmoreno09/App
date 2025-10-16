import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.ViGateServices 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: Theme.spacing.s4

    required property ViGateController controller

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    ColumnLayout {
        visible: !controller.isLoading
        Layout.fillWidth: true
        Layout.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        UI.Input {
            id: gateIdInput
            Layout.fillWidth: true
            labelText: (TranslationManager.revision, qsTr("Gate ID"))
            placeholderText: (TranslationManager.revision, qsTr("Enter gate ID"))
            textField.inputMethodHints: Qt.ImhDigitsOnly
            textField.validator: IntValidator { bottom: 1 }
        }

        UI.Button {
            id: dateRangeButton
            Layout.fillWidth: true
            variant: UI.ButtonStyles.Primary
            text: {
                TranslationManager.revision
                if (dateTimePicker.hasValidSelection) {
                    const start = dateTimePicker._combineDateTime(
                        dateTimePicker.startDate,
                        dateTimePicker.selectedHour,
                        dateTimePicker.selectedMinute,
                        dateTimePicker.selectedAMPM
                    )
                    const end = dateTimePicker._combineDateTime(
                        dateTimePicker.endDate,
                        dateTimePicker.endHour,
                        dateTimePicker.endMinute,
                        dateTimePicker.endAMPM
                    )
                    return qsTr("Date Range: %1 - %2")
                        .arg(Qt.formatDateTime(start, "dd/MM HH:mm"))
                        .arg(Qt.formatDateTime(end, "dd/MM HH:mm"))
                }
                return qsTr("Select Date Range")
            }

            onClicked: datePickerOverlay.open()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s3

            Text {
                text: (TranslationManager.revision, qsTr("Filters:"))
                font.family: Theme.typography.familySans
                color: Theme.colors.text
            }

            UI.Toggle {
                id: vehiclesToggle
                Layout.fillWidth: true
                rightLabel: (TranslationManager.revision, qsTr("Vehicles"))
                checked: true
            }

            UI.Toggle {
                id: pedestriansToggle
                Layout.fillWidth: true
                rightLabel: (TranslationManager.revision, qsTr("Pedestrians"))
                checked: true
            }
        }

        UI.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s10
            variant: UI.ButtonStyles.Primary
            text: (TranslationManager.revision, qsTr("Fetch Data"))
            enabled: canFetch && !controller.isLoading

            readonly property bool canFetch: {
                return gateIdInput.text !== "" &&
                       dateTimePicker.hasValidSelection &&
                       (vehiclesToggle.checked || pedestriansToggle.checked)
            }

            onClicked: {
                Qt.inputMethod.commit()

                const startDT = dateTimePicker._combineDateTime(
                    dateTimePicker.startDate,
                    dateTimePicker.selectedHour,
                    dateTimePicker.selectedMinute,
                    dateTimePicker.selectedAMPM
                )
                const endDT = dateTimePicker._combineDateTime(
                    dateTimePicker.endDate,
                    dateTimePicker.endHour,
                    dateTimePicker.endMinute,
                    dateTimePicker.endAMPM
                )

                controller.fetchGateData(
                    parseInt(gateIdInput.text),
                    startDT,
                    endDT,
                    vehiclesToggle.checked,
                    pedestriansToggle.checked
                )
            }
        }

        UI.HorizontalDivider { Layout.fillWidth: true }
    }

    ColumnLayout {
        visible: !controller.isLoading && controller.hasData
        Layout.fillWidth: true
        Layout.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        SummaryTable {
            Layout.fillWidth: true
            controller: root.controller
        }

        VehiclesTable {
            visible: vehiclesToggle.checked
            Layout.fillWidth: true
            model: root.controller.vehiclesModel
        }

        PedestriansTable {
            visible:  pedestriansToggle.checked
            Layout.fillWidth: true
            model: root.controller.pedestriansModel
        }
    }

    Text {
        visible: !controller.isLoading && !controller.hasData && !controller.hasError
        text: (TranslationManager.revision, qsTr("No data available. Please select filters and fetch."))
        color: Theme.colors.textMuted
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Theme.spacing.s8
        font {
            family: Theme.typography.bodySans25Family
            pointSize: Theme.typography.bodySans25Size
            weight: Theme.typography.bodySans25Weight
        }
    }

    Text {
        visible: !controller.isLoading && controller.hasError
        text: (TranslationManager.revision, qsTr("Error loading data. Please try again."))
        color: Theme.colors.error
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Theme.spacing.s8
        font {
            family: Theme.typography.bodySans25Family
            pointSize: Theme.typography.bodySans25Size
            weight: Theme.typography.bodySans25Weight
        }
    }

    UI.VerticalSpacer {}

    UI.Overlay {
        id: datePickerOverlay
        width: 400
        height: 600

        ColumnLayout {
            anchors.fill: parent

            UI.DateTimePicker {
                id: dateTimePicker
                Layout.fillWidth: true
                Layout.fillHeight: true
                mode: "range"
                is24Hour: true

                Component.onCompleted: {
                    const now = new Date()
                    const tomorrow = new Date(now)
                    tomorrow.setDate(now.getDate() + 1)
                    setDateRange(now, tomorrow)
                }
            }

            RowLayout {
                Layout.fillWidth: true

                UI.Button {
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Ghost
                    text: (TranslationManager.revision, qsTr("Cancel"))
                    onClicked: datePickerOverlay.close()
                }

                UI.Button {
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Primary
                    text: (TranslationManager.revision, qsTr("Apply"))
                    enabled: dateTimePicker.hasValidSelection
                    onClicked: datePickerOverlay.close()
                }
            }
        }
    }
}
