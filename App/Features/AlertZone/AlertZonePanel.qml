import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Panels 1.0
import App.Features.Language 1.0
import App.Features.SidePanel 1.0

import "components"

PanelTemplate {
    id: root
    title.text: `${TranslationManager.revision}` && qsTr("Alert Zone")

    function syncData() {
        if (!MapModeController.isEditing) return

        labelInput.text = MapModeController.alertZone.label
        noteTextArea.text = MapModeController.alertZone.note ?? ""
        severityComboBox.currentIndex = MapModeController.alertZone.severity ?? 0
        layerSelection.setLayers(MapModeController.alertZone.layers ?? {})
        activeSwitch.checked = MapModeController.alertZone.active ?? true
    }

    Component.onCompleted: {
        syncData()
        if (!MapModeController.isEditing) {
            MapModeController.setActiveMode(MapModeRegistry.createPolygonMode)
        }
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

                RowLayout {
                    Layout.leftMargin: Theme.spacing.s2
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        visible: MapModeController.isEditing
                        text: activeSwitch.checked ?  `${TranslationManager.revision}` && qsTr("Deactivate") :  `${TranslationManager.revision}` && qsTr("Activate")
                        color: Theme.colors.text
                        font {
                            family: Theme.typography.bodySans25Family
                            pointSize: Theme.typography.bodySans25Size
                            weight: Theme.typography.bodySans25Weight
                        }
                    }

                    UI.Toggle {
                        id: activeSwitch
                        visible: MapModeController.isEditing
                        checked: true
                        onToggled: if (MapModeController.isEditing) MapModeController.alertZone.active = checked
                    }
                }

                UI.HorizontalDivider { visible: MapModeController.isEditing }

                SectionTitle { text: `${TranslationManager.revision}` && qsTr("General Info") }

                UI.HorizontalDivider {}

                UI.Input {
                    id: labelInput
                    Layout.fillWidth: true
                    labelText: `${TranslationManager.revision}` && qsTr("Label(*)")
                    placeholderText: `${TranslationManager.revision}` && qsTr("Label")

                    onTextEdited: if (MapModeController.isEditing) MapModeController.alertZone.label = text
                }

                Severity {
                    id: severityComboBox
                    Layout.fillWidth: true
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: `${TranslationManager.revision}` && qsTr("Note")

                    onTextEdited: if (MapModeController.isEditing) MapModeController.alertZone.note = text
                }

                UI.VerticalSpacer {}

                SectionTitle {
                    Layout.topMargin: Theme.spacing.s3
                    text: `${TranslationManager.revision}` && qsTr("Layer Selection")
                }

                UI.HorizontalDivider {}

                LayerSelection {
                    id: layerSelection
                    Layout.fillWidth: true
                }

                UI.VerticalSpacer {}

                SectionTitle {
                    Layout.topMargin: Theme.spacing.s3
                    text: `${TranslationManager.revision}` && qsTr("Drawing Tools")
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

        const layersJs = layerSelection.selectedLayers
        const layersMap = {}
        for (let key in layersJs) {
            layersMap[key] = layersJs[key]
        }

        const data = {
            label: labelInput.text,
            geometry: geometry,
            severity: severityComboBox.currentValue,
            active: activeSwitch.checked,
            layers: layersMap,
            details: {
                metadata: { note: noteTextArea.text }
            }
        }

        console.log("Sending layers:", JSON.stringify(layersMap))

        if (MapModeController.isEditing) {
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
                    text: `${TranslationManager.revision}` && qsTr("Back")
                    onClicked: SidePanelController.close(true)
                }

                UI.Button {
                    visible: !!MapModeController.alertZone
                    enabled: !AlertZoneModel.loading
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Danger
                    backgroundRect.border.width: Theme.borders.b0
                    text: `${TranslationManager.revision}` && qsTr("Remove")
                    onClicked: AlertZoneModel.remove(MapModeController.alertZone.id)
                }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("Save")
                    enabled: !AlertZoneModel.loading && validate()
                    onClicked: save()
                }
            }
        }
    }
}
