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
    }

    Component.onCompleted: {
        console.log("[STEP 1] AlertZonePanel opened")
        console.log("[STEP 1a] Syncing data from MapModeController")
        syncData()
        console.log("[STEP 1b] Checking active mode:", MapModeController.activeMode)
        if (MapModeController.activeMode === MapModeRegistry.interactionMode) {
            console.log("[STEP 1c] Setting active mode to createPolygonMode")
            MapModeController.setActiveMode(MapModeRegistry.createPolygonMode)
        } else {
            console.log("[STEP 1c] Active mode already set:", MapModeController.activeMode)
        }
        console.log("[STEP 1d] Panel initialization complete")
    }

    Component.onDestruction: {
        MapModeController.setActiveMode(MapModeRegistry.interactionMode)
    }

    Connections {
        target: AlertZoneModel

        function onAppended() {
            console.log("[STEP 6] AlertZoneModel.appended signal received - closing panel")
            SidePanelController.close(true)
        }
        function onUpdated() {
            console.log("[STEP 6] AlertZoneModel.updated signal received - closing panel")
            SidePanelController.close(true)
        }
        function onRemoved() {
            console.log("[STEP 6] AlertZoneModel.removed signal received - closing panel")
            SidePanelController.close(true)
        }
        function onFetched() {
            console.log("[STEP 6] AlertZoneModel.fetched signal received - syncing data")
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

                UI.Input {
                    id: labelInput
                    Layout.fillWidth: true
                    labelText: qsTr("Label(*)")
                    placeholderText: qsTr("Label")

                    onTextEdited: if (MapModeController.isEditingAlertZone) MapModeController.alertZone.label = text
                }

                AlertZonePolygonForm {
                    id: polygonForm
                    Layout.fillWidth: true
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: qsTr("Note")

                    onTextEdited: if (MapModeController.isEditingAlertZone) MapModeController.alertZone.note = text
                }
            }
        }
    }

    function validate() {
        const labelValid = labelInput.text.trim() !== ""
        const polygonValid = polygonForm.isValid
        console.log("[VALIDATION] Label valid:", labelValid, "| Polygon valid:", polygonValid)
        if (!labelValid) return false;
        return polygonValid;
    }

    function save() {
        console.log("[STEP 5] Save button clicked")
        console.log("[STEP 5a] Building geometry from activeMode:", MapModeController.activeMode)

        const geometry = MapModeController.activeMode.buildGeometry()
        console.log("[STEP 5b] Geometry built:", JSON.stringify(geometry))

        const data = {
            label: labelInput.text,
            geometry: geometry,
            layerId: 2,
            layerName: Layers.alertZoneMapLayer(),
            note: noteTextArea.text
        }

        console.log("[STEP 5c] Data object created:", JSON.stringify(data))

        if (MapModeController.isEditingAlertZone) {
            console.log("[STEP 5d] Editing mode - updating existing alert zone:", MapModeController.alertZone.id)
            data.id = MapModeController.alertZone.id
            AlertZoneModel.update(data)
        } else {
            console.log("[STEP 5d] Creating mode - appending new alert zone")
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
