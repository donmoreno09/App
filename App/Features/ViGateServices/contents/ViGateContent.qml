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

    // Loading Indicator
    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    // Filters and Controls Section
    ColumnLayout {
        visible: !controller.isLoading
        Layout.fillWidth: true
        Layout.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        // Gate Selection ComboBox
        UI.ComboBox {
            id: gateComboBox
            Layout.fillWidth: true
            labelText: (TranslationManager.revision, qsTr("Select Gate"))

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

        // Gate Loading Indicator
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
                text: (TranslationManager.revision, qsTr("Loading gates..."))
                color: Theme.colors.textMuted
                font.family: Theme.typography.familySans
            }
        }

        // Date Range Button
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

        // Filters Row
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

                onCheckedChanged: {
                    if (controller.hasData) {
                        updateTransitFilter()
                    }
                }
            }

            UI.Toggle {
                id: pedestriansToggle
                Layout.fillWidth: true
                rightLabel: (TranslationManager.revision, qsTr("Pedestrians"))
                checked: true

                onCheckedChanged: {
                    if (controller.hasData) {
                        updateTransitFilter()
                    }
                }
            }
        }

        // Fetch Data Button
        UI.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.spacing.s10
            variant: UI.ButtonStyles.Primary
            text: (TranslationManager.revision, qsTr("Fetch Data"))
            enabled: canFetch && !controller.isLoading

            readonly property bool canFetch: {
                return gateComboBox.currentIndex >= 0 &&
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

                const selectedGateId = gateComboBox.currentValue
                console.log("Fetching data for gate ID:", selectedGateId)

                controller.fetchGateData(
                    selectedGateId,
                    startDT,
                    endDT,
                    vehiclesToggle.checked,
                    pedestriansToggle.checked
                )
            }
        }

        UI.HorizontalDivider { Layout.fillWidth: true }
    }

    // Data Display Section
    ColumnLayout {
        visible: !controller.isLoading && controller.hasData
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        // Summary Table
        SummaryTable {
            Layout.fillWidth: true
            controller: root.controller
        }

        // Transits Table
        TransitsTable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.controller.transitsModel

            Component.onCompleted: {
                // Set initial filter when table is created
                updateTransitFilter()
            }
        }

        // Pagination Info Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.minimumHeight: Theme.spacing.s10
            color: Theme.colors.surface
            radius: Theme.radius.sm
            visible: controller.totalPages > 0

            RowLayout {
                anchors.fill: parent

                Text {
                    Layout.fillWidth: true
                    text: (TranslationManager.revision, qsTr("Page %1 of %2")
                        .arg(controller.currentPage)
                        .arg(controller.totalPages))
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightMedium
                    color: Theme.colors.text
                    horizontalAlignment: Text.AlignHCenter
                }

                UI.VerticalDivider {
                    Layout.fillHeight: true
                    color: Theme.colors.textMuted
                }

                Text {
                    Layout.fillWidth: true
                    text: (TranslationManager.revision, qsTr("Total Items: %1")
                        .arg(controller.totalItems))
                    font.family: Theme.typography.familySans
                    color: Theme.colors.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                UI.VerticalDivider {
                    Layout.fillHeight: true
                    color: Theme.colors.textMuted
                }

                Text {
                    Layout.fillWidth: true
                    text: (TranslationManager.revision, qsTr("Showing %1-%2")
                        .arg((controller.currentPage - 1) * controller.pageSize + 1)
                        .arg(Math.min(controller.currentPage * controller.pageSize, controller.totalItems)))
                    font.family: Theme.typography.familySans
                    color: Theme.colors.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                UI.VerticalDivider {
                    Layout.fillHeight: true
                    color: Theme.colors.textMuted
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: (TranslationManager.revision, qsTr("Items per page:"))
                        font.family: Theme.typography.familySans
                        color: Theme.colors.text
                    }

                    ComboBox {
                        id: pageSizeCombo
                        Layout.fillWidth: true
                        Layout.maximumWidth: 80
                        model: [25, 50, 100, 200]
                        currentIndex: 1 // Default to 50

                        onCurrentValueChanged: {
                            if (currentValue) {
                                controller.pageSize = currentValue
                            }
                        }

                        delegate: ItemDelegate {
                            width: pageSizeCombo.width
                            contentItem: Text {
                                text: modelData
                                color: Theme.colors.text
                                font: pageSizeCombo.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: pageSizeCombo.highlightedIndex === index
                        }

                        contentItem: Text {
                            leftPadding: Theme.spacing.s2
                            rightPadding: pageSizeCombo.indicator.width + pageSizeCombo.spacing
                            text: pageSizeCombo.displayText
                            font: pageSizeCombo.font
                            color: Theme.colors.text
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 80
                            implicitHeight: Theme.spacing.s8
                            color: Theme.colors.surface
                            radius: Theme.radius.sm
                        }
                    }
                }
            }
        }

        // Pagination Controls
        RowLayout {
            visible: controller.totalPages > 1
            Layout.fillWidth: true
            spacing: Theme.spacing.s2

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: (TranslationManager.revision, qsTr("« First"))
                enabled: controller.currentPage > 1
                onClicked: controller.goToPage(1)
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: (TranslationManager.revision, qsTr("‹ Previous"))
                enabled: controller.currentPage > 1
                onClicked: controller.previousPage()
            }

            Item { Layout.fillWidth: true }

            // Page Number Display with Quick Jump
            RowLayout {
                spacing: Theme.spacing.s2

                Text {
                    text: (TranslationManager.revision, qsTr("Go to page:"))
                    font.family: Theme.typography.familySans
                    color: Theme.colors.text
                }

                TextField {
                    id: pageJumpInput
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignHCenter
                    text: controller.currentPage.toString()
                    validator: IntValidator {
                        bottom: 1
                        top: controller.totalPages
                    }

                    background: Rectangle {
                        color: Theme.colors.surface
                        radius: Theme.radius.sm
                        border.color: pageJumpInput.activeFocus ? Theme.colors.primary : Theme.colors.transparent
                        border.width: 2
                    }

                    color: Theme.colors.text
                    font.family: Theme.typography.familySans

                    onAccepted: {
                        const page = parseInt(text)
                        if (page >= 1 && page <= controller.totalPages) {
                            controller.goToPage(page)
                        } else {
                            text = controller.currentPage.toString()
                        }
                    }

                    // Reset to current page when focus is lost
                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            text = controller.currentPage.toString()
                        }
                    }
                }

                Text {
                    text: (TranslationManager.revision, qsTr("of %1").arg(controller.totalPages))
                    font.family: Theme.typography.familySans
                    color: Theme.colors.textMuted
                }
            }

            Item { Layout.fillWidth: true }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: (TranslationManager.revision, qsTr("Next ›"))
                enabled: controller.currentPage < controller.totalPages
                onClicked: controller.nextPage()
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: (TranslationManager.revision, qsTr("Last »"))
                enabled: controller.currentPage < controller.totalPages
                onClicked: controller.goToPage(controller.totalPages)
            }
        }
    }

    // No Data Message
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

    // Error Message
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

    // Date Picker Overlay
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

    // Connection to update filter when data is loaded
    Connections {
        target: root.controller
        function onHasDataChanged() {
            if (root.controller.hasData) {
                console.log("ViGateContent: Data loaded, applying initial filter")
                updateTransitFilter()
            }
        }
    }

    // Function to update model filter based on toggle states
    function updateTransitFilter() {
        let types = []
        if (vehiclesToggle.checked) types.push("VEHICLE")
        if (pedestriansToggle.checked) types.push("WALK")

        const filterStr = types.length > 0 ? types.join(",") : "NONE"
        console.log("ViGateContent: Updating filter to", filterStr)
        root.controller.transitsModel.laneTypeFilter = filterStr
    }
}
