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
    title.text: `${TranslationManager.revision}` && qsTr("Alert Zone")

    function syncData() {
        if (!MapModeController.isEditingAlertZone) return

        labelInput.text = MapModeController.alertZone.label
        noteTextArea.text = MapModeController.alertZone.note ?? ""
        severityComboBox.currentIndex = severityComboBox.comboBox.indexOfValue(MapModeController.alertZone.severity ?? "low")
        layerSelection.setLayers(MapModeController.alertZone.targetLayers ?? [])
        activeSwitch.checked = MapModeController.alertZone.active ?? true
    }

    Component.onCompleted: {
        syncData()
        if (MapModeController.activeMode === MapModeRegistry.interactionMode) {
            MapModeController.setActiveMode(MapModeRegistry.createPolygonMode)
        }
    }

    Component.onDestruction: {
        MapModeController.setActiveMode(MapModeRegistry.interactionMode)
    }

    Connections {
        target: AlertZoneModel

        function onAppended() {
            SidePanelController.close(true)
        }
        function onUpdated() {
            SidePanelController.close(true)
        }
        function onRemoved() {
            SidePanelController.close(true)
        }
        function onFetched() {
            root.syncData()
        }
    }

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

                SectionTitle { text: qsTr("General Info") }

                UI.HorizontalDivider {}

                UI.Input {
                    id: labelInput
                    Layout.fillWidth: true
                    labelText: qsTr("Label(*)")
                    placeholderText: qsTr("Label")

                    onTextEdited: if (MapModeController.isEditingAlertZone) MapModeController.alertZone.label = text
                }

                Severity {
                    id: severityComboBox
                    Layout.fillWidth: true
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: qsTr("Note")

                    onTextEdited: if (MapModeController.isEditingAlertZone) MapModeController.alertZone.note = text
                }

                UI.Toggle {
                    id: activeSwitch
                    Layout.fillWidth: true
                    visible: MapModeController.isEditingAlertZone
                    leftLabel: checked ? qsTr("Deactivate") : qsTr("Activate")
                    checked: true
                    onToggled: if (MapModeController.isEditingAlertZone) MapModeController.alertZone.active = checked
                }

                UI.VerticalSpacer {}

                SectionTitle {
                    Layout.topMargin: Theme.spacing.s3
                    text: qsTr("Layer Selection")
                }

                UI.HorizontalDivider {}

                LayerSelection {
                    id: layerSelection
                    Layout.fillWidth: true
                }

                UI.VerticalSpacer {}

                SectionTitle {
                    Layout.topMargin: Theme.spacing.s3
                    text: qsTr("Drawing Tools")
                }

                UI.HorizontalDivider {}

                AreaForm {
                    id: areaForm
                    Layout.fillWidth: true
                }
            }
        }
    }

    function validate() {
        const labelValid = labelInput.text.trim() !== ""
        const layersValid = layerSelection.isValid
        if (!labelValid) return false;
        if (!layersValid) return false
        return areaForm.isValid;
    }

    function save() {

        const geometry = MapModeController.activeMode.buildGeometry()

        const data = {
            label: labelInput.text,
            geometry: geometry,
            layerId: 2,
            layerName: Layers.alertZoneMapLayer(),
            severity: severityComboBox.currentValue,
            note: noteTextArea.text,
            active: activeSwitch.checked,
            targetLayers: layerSelection.selectedLayers
        }

        if (MapModeController.isEditingAlertZone) {
            data.id = MapModeController.alertZone.id
            AlertZoneModel.update(data)
        } else {
            AlertZoneModel.append(data)
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
                    visible: !!MapModeController.alertZone
                    enabled: !AlertZoneModel.loading
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Danger
                    backgroundRect.border.width: Theme.borders.b0
                    text: qsTr("Remove")
                    onClicked: AlertZoneModel.remove(MapModeController.alertZone.id)
                }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: !AlertZoneModel.loading && validate()
                    onClicked: save()
                }
            }
        }
    }
}
