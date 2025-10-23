import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

import "components"

PanelTemplate {
    id: root

    title.text: (TranslationManager.revision, qsTr("Point of Interest"))

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        Pane {
            anchors.fill: parent
            padding: Theme.spacing.s8
            background: Rectangle { color: Theme.colors.transparent }

            ColumnLayout {
                width: parent.width
                spacing: Theme.spacing.s4

                UI.Input {
                    id: nameInput
                    Layout.fillWidth: true
                    labelText: qsTr("Name(*)")
                    placeholderText: qsTr("Name")
                }

                UI.ComboBox {
                    id: categoryComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Category(*)")

                    model: PoiOptions.categories
                    textRole: "name"
                    valueRole: "key"
                }

                UI.ComboBox {
                    id: typeComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Type(*)")

                    model: PoiOptions.typesForCategory(categoryComboBox.currentValue)
                    textRole: "value"
                    valueRole: "key"
                }

                UI.ComboBox {
                    id: healthStatusComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Health Status(*)")

                    model: PoiOptions.healthStatuses
                    textRole: "value"
                    valueRole: "key"
                }

                UI.ComboBox {
                    id: operationalStateComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Operational State(*)")

                    model: PoiOptions.operationalStates
                    textRole: "value"
                    valueRole: "key"
                }

                Loader {
                    Layout.fillWidth: true
                    source: (categoryComboBox.currentValue >= PoiOptions.pointCategoriesStartIndex) ? "components/PointForm.qml" : "components/AreaForm.qml"
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: qsTr("Note")
                }
            }
        }
    }

    footer: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.spacing.s0

        UI.HorizontalDivider {
            color: Theme.colors.whiteA10
        }

        Pane {
            Layout.fillWidth: true
            padding: Theme.spacing.s8
            background: Rectangle { color: Theme.colors.transparent }

            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Ghost
                    backgroundRect.border.width: Theme.borders.b0
                    text: qsTr("Back")
                    onClicked: SidePanelController.close(true)
                }

                UI.Button {
                    visible: !!MapModeController.poi
                    enabled: !PoiModel.loading
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Danger
                    backgroundRect.border.width: Theme.borders.b0
                    text: qsTr("Remove")
                    onClicked: PoiModel.remove(MapModeController.poi.id)
                }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: !PoiModel.loading
                }
            }
        }
    }

    Component.onCompleted: {
        if (MapModeController.activeMode === MapModeRegistry.interactionMode) {
            MapModeController.setActiveMode(MapModeRegistry.createPointMode)
        }
    }

    Component.onDestruction: {
        MapModeController.setActiveMode(MapModeRegistry.interactionMode)
    }
}
