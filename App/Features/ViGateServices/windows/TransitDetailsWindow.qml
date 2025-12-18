import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.ViGateServices 1.0
import App.Features.Language 1.0

UI.FloatingWindow {
    id: window
    windowTitle: `${TranslationManager.revision}` && qsTr("Transit Details")

    minWidth: 1000
    minHeight: 600

    windowWidth: parentWindow ? parentWindow.width : 1920
    windowHeight: parentWindow ? parentWindow.height : 1080

    // Receive the controller from WindowRouter
    required property var controller
    required property bool pedestriansToggled
    required property bool vehiclesToggled

    property var parentWindow: null
    readonly property string title: windowTitle


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        ColumnLayout {
            visible: !controller.isLoadingPage
            Layout.fillWidth: true
            spacing: Theme.spacing.s0

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s3

                Text {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("Transits")
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize175
                    color: Theme.colors.text
                }

                RowLayout {
                    visible: vehiclesToggled && pedestriansToggled
                    Text {
                        text: `${TranslationManager.revision}` && qsTr("Filters:")
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize175
                        color: Theme.colors.text
                    }

                    UI.Toggle {
                        Layout.preferredWidth: childrenRect.width
                        id: vehiclesToggle
                        rightLabel: `${TranslationManager.revision}` && qsTr("Vehicles")
                        checked: vehiclesToggled
                        enabled: (pedestriansToggle.checked && vehiclesToggled) && (!checked || (pedestriansToggle.checked && vehiclesToggled))

                        onCheckedChanged: {
                            if (controller.hasData) {
                                updateTransitFilter()
                            }
                        }
                    }

                    UI.Toggle {
                        Layout.preferredWidth: childrenRect.width
                        id: pedestriansToggle
                        rightLabel: `${TranslationManager.revision}` && qsTr("Pedestrians")
                        checked: pedestriansToggled
                        enabled: (vehiclesToggle.checked && pedestriansToggled) && (!checked || (vehiclesToggle.checked && pedestriansToggled))

                        onCheckedChanged: {
                            if (controller.hasData) {
                                updateTransitFilter()
                            }
                        }
                    }
                }
            }

            // The main table
            TransitsTable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: controller.transitsModel
            }
        }

        // Pagination controls
        RowLayout {
            Layout.fillWidth: true
            Layout.maximumHeight: Theme.spacing.s10
            spacing: Theme.spacing.s3
            visible: controller.totalPages > 0 && !controller.isLoadingPage

            UI.HorizontalSpacer{}

            Text {
                text: `${TranslationManager.revision}` && qsTr("Page %1 of %2")
                    .arg(controller.currentPage)
                    .arg(controller.totalPages)
                font.family: Theme.typography.familySans
                font.weight: Theme.typography.weightMedium
                color: Theme.colors.text
                horizontalAlignment: Text.AlignHCenter
            }

            UI.VerticalDivider { color: Theme.colors.whiteA10 }

            Text {
                text: `${TranslationManager.revision}` && qsTr("Total Items: %1")
                    .arg(controller.totalItems)
                font.family: Theme.typography.familySans
                color: Theme.colors.textMuted
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            UI.VerticalDivider { color: Theme.colors.whiteA10 }

            Text {
                text: `${TranslationManager.revision}` && qsTr("Items per page:")
                font.family: Theme.typography.familySans
                color: Theme.colors.text
            }

            UI.ComboBox {
                id: itemsPerPageComboBox
                comboBoxHeight: Theme.spacing.s6
                itemDelegateHeight: Theme.spacing.s4
                contentPadding: Theme.spacing.s1
                popupPadding: Theme.spacing.s1
                model: [5, 10, 25, 50]
                currentIndex: {
                    const idx = model.indexOf(controller.pageSize)
                    return idx >= 0 ? idx : 0
                }
                fontFamily: Theme.typography.familySans
                fontSize: Theme.spacing.s2 + 1
                fontWeight: Theme.spacing.s2 + 1

                onActivated: function(index) {
                    controller.pageSize = model[index]
                }
            }

            UI.HorizontalSpacer{}
        }

        RowLayout {
            visible: controller.totalPages > 1 && !controller.isLoadingPage
            Layout.fillWidth: true
            spacing: Theme.spacing.s3

            Item { Layout.fillWidth: true }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: `${TranslationManager.revision}` && qsTr("« First")
                enabled: controller.currentPage > 1
                onClicked: controller.goToPage(1)
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: `${TranslationManager.revision}` && qsTr("‹ Previous")
                enabled: controller.currentPage > 1
                onClicked: controller.previousPage()
            }

            RowLayout {
                spacing: Theme.spacing.s0

                Text {
                    text: `${TranslationManager.revision}` && qsTr("Go to page:")
                    font.family: Theme.typography.familySans
                    color: Theme.colors.text
                }

                TextField {
                    id: pageJumpInput
                    Layout.preferredWidth: 35
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

                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            text = controller.currentPage.toString()
                        }
                    }
                }

                Text {
                    text: `${TranslationManager.revision}` && qsTr("of %1").arg(controller.totalPages)
                    font.family: Theme.typography.familySans
                    color: Theme.colors.textMuted
                }
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: `${TranslationManager.revision}` && qsTr("Next ›")
                enabled: controller.currentPage < controller.totalPages
                onClicked: controller.nextPage()
            }

            UI.Button {
                variant: UI.ButtonStyles.Ghost
                text: `${TranslationManager.revision}` && qsTr("Last »")
                enabled: controller.currentPage < controller.totalPages
                onClicked: controller.goToPage(controller.totalPages)
            }

            Item { Layout.fillWidth: true }
        }

        // Loading overlay
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.isLoadingPage

            BusyIndicator {
                anchors.centerIn: parent
                width: Theme.spacing.s12
                height: Theme.spacing.s12
                running: true
                layer.enabled: true
                layer.effect: ColorOverlay { color: Theme.colors.text }
            }
        }
    }

    function updateTransitFilter() {
        let types = []
        if (vehiclesToggle.checked) types.push("VEHICLE")
        if (pedestriansToggle.checked) types.push("WALK")

        const filterStr = types.length > 0 ? types.join(",") : "ALL"
        controller.transitsModel.laneTypeFilter = filterStr

        console.log("[TransitDetailsWindow] Filter applied:", filterStr)
    }
}
