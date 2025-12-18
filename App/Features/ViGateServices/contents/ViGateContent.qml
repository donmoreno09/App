import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.SidePanel 1.0
import App.Features.ViGateServices 1.0

import "qrc:/App/Components/floating-window/windowRoutes.js" as WinRoutes

ColumnLayout {
    id: root
    width: parent.width
    spacing: Theme.spacing.s4

    required property ViGateController controller

    readonly property var startDT: dateTimePicker._combineDateTime(
        dateTimePicker.startDate,
        dateTimePicker.selectedHour,
        dateTimePicker.selectedMinute,
        dateTimePicker.selectedAMPM
    )
    readonly property var endDT: dateTimePicker._combineDateTime(
        dateTimePicker.endDate,
        dateTimePicker.endHour,
        dateTimePicker.endMinute,
        dateTimePicker.endAMPM
    )
    readonly property var selectedGateId: gateComboBox.currentValue
    readonly property bool vehiclesChecked: vehiclesToggle.checked
    readonly property bool pedestriansChecked: pedestriansToggle.checked
    readonly property bool canFetch: {
        return gateComboBox.currentIndex >= 0 && dateTimePicker.hasValidSelection && (vehiclesToggle.checked || pedestriansToggle.checked)
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 250
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    ColumnLayout {
        visible: !controller.isLoading
        Layout.fillWidth: true
        spacing: Theme.spacing.s3

        UI.ComboBox {
            id: gateComboBox
            Layout.fillWidth: true
            labelText: `${TranslationManager.revision}` && qsTr("Select Gate")

            model: controller.activeGates
            textRole: "name"
            valueRole: "id"

            displayText: currentIndex >= 0 ? currentValue + " - " + currentText : ""

            enabled: !controller.isLoadingGates && controller.activeGates.length > 0

            Component.onCompleted: {
                if (controller.activeGates.length > 0) {
                    currentIndex = 0
                }
            }

            onModelChanged: {
                if (model.length > 0 && currentIndex < 0) {
                    currentIndex = 0
                }
            }
        }

        RowLayout {
            visible: controller.isLoadingGates
            Layout.fillWidth: true
            spacing: Theme.spacing.s2

            BusyIndicator {
                Layout.preferredWidth: Theme.spacing.s6
                Layout.preferredHeight: Theme.spacing.s6
                running: true
            }

            Text {
                text: `${TranslationManager.revision}` && qsTr("Loading gates...")
                color: Theme.colors.textMuted
                font.family: Theme.typography.familySans
            }
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
                Layout.fillWidth: true
                text: `${TranslationManager.revision}` && qsTr("Filters:")
                font.family: Theme.typography.familySans
                color: Theme.colors.text
            }

            UI.Toggle {
                id: vehiclesToggle
                Layout.fillWidth: true
                rightLabel: `${TranslationManager.revision}` && qsTr("Vehicles")
                checked: controller.vehiclesToggled
            }

            UI.Toggle {
                id: pedestriansToggle
                Layout.fillWidth: true
                rightLabel: `${TranslationManager.revision}` && qsTr("Pedestrians")
                checked: controller.pedestriansToggled
            }
        }

        UI.HorizontalDivider { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: dataDisplayLayout
        visible: !controller.isLoading && (controller.totalItems > 0)
        width: parent.width
        Layout.fillHeight: true
        Layout.maximumWidth: parent.width
        spacing: Theme.spacing.s4

        SummaryTable {
            Layout.fillWidth: true
            controller: root.controller
            visible: !controller.isLoadingPage
        }

        // Results summary + Open Details button
        Rectangle {
            visible: !controller.isLoadingPage
            Layout.fillWidth: true
            implicitHeight: childrenRect.height + Theme.spacing.s4 * 2
            color: Theme.colors.surface
            radius: Theme.radius.sm

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.s4
                }
                spacing: Theme.spacing.s3

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: `${TranslationManager.revision}` && qsTr("Found %1 transit(s)")
                        .arg(controller.totalItems)
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                }

                UI.Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    variant: UI.ButtonStyles.Primary
                    text: `${TranslationManager.revision}` && qsTr("Open Details")

                    onClicked: {
                        const window =UI.WindowRouter.open(WinRoutes.TRANSIT_DETAILS, Window.window, {
                                controller: root.controller,
                                x: 120, y: 90, width: 1200, height: 740,
                                pedestriansToggled: pedestriansToggle.checked,
                                vehiclesToggled: vehiclesToggle.checked,
                                title: qsTr("Transit Details")
                            })
                        if (!window) {
                            console.warn("[ViGateContent] I can't open floating window");
                        } else {
                            SidePanelController.close(true)
                        }
                    }
                }
            }
        }

        UI.VerticalSpacer {}
    }

    Text {
        visible: !controller.isLoading && !controller.hasError && (controller.totalItems === 0)
        text: `${TranslationManager.revision}` && qsTr("No data available.")
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
        text: `${TranslationManager.revision}` && qsTr("Error loading data. Please try again.")
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
                    text: `${TranslationManager.revision}` && qsTr("Cancel")
                    onClicked: datePickerOverlay.close()
                }

                UI.Button {
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Primary
                    text: `${TranslationManager.revision}` && qsTr("Apply")
                    enabled: dateTimePicker.hasValidSelection
                    onClicked: datePickerOverlay.close()
                }
            }
        }
    }
}
