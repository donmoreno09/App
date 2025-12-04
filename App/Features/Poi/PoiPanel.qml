import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Panels 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

import "components"

PanelTemplate {
    id: root
    title.text: `${TranslationManager.revision}` && qsTr("Point of Interest")

    function syncData() {
        if (!MapModeController.isEditing) return

        labelInput.text = MapModeController.poi.label
        noteTextArea.text = MapModeController.poi.note ?? ""
        categoryComboBox.currentIndex = categoryComboBox.comboBox.indexOfValue(MapModeController.poi.categoryId)
        typeComboBox.currentIndex = typeComboBox.comboBox.indexOfValue(MapModeController.poi.typeId)
        healthStatusComboBox.currentIndex = healthStatusComboBox.comboBox.indexOfValue(MapModeController.poi.healthStatusId)
        operationalStateComboBox.currentIndex = operationalStateComboBox.comboBox.indexOfValue(MapModeController.poi.operationalStateId)
    }

    Component.onCompleted: {
        syncData()
        if (!MapModeController.isEditing) {
            MapModeController.setActiveMode(MapModeRegistry.createPointMode)
        }
    }

    Connections {
        target: PoiModel

        function onAppended() { SidePanelController.close(true) }
        function onUpdated() { SidePanelController.close(true) }
        function onRemoved() { SidePanelController.close(true) }
        function onFetched() { root.syncData() }
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

                    onTextEdited: if (MapModeController.isEditing) MapModeController.poi.label = text
                }

                UI.ComboBox {
                    id: categoryComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Category(*)")
                    textRole: "name"
                    valueRole: "key"
                    model: PoiOptions.categories
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
                    enabled: false
                    visible: !MapModeController.isCreating

                    model: PoiOptions.healthStatuses
                    textRole: "value"
                    valueRole: "key"
                }

                UI.ComboBox {
                    id: operationalStateComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Operational State(*)")
                    enabled: false
                    visible: !MapModeController.isCreating

                    model: PoiOptions.operationalStates
                    textRole: "value"
                    valueRole: "key"
                }

                // For legacy reasons, it's still called AreaForm but should be called ShapeForm instead, feel free to change it
                AreaForm {
                    id: areaForm
                    Layout.fillWidth: true
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: qsTr("Note")

                    onTextEdited: if (MapModeController.isEditing) MapModeController.poi.note = text
                }
            }
        }
    }

    function validate() {
        if (labelInput.text.trim() === "") return false;
        return areaForm.isValid;
    }

    function save() {
        const data = {
            label: labelInput.text,
            geometry: MapModeController.activeMode.buildGeometry(),
            layerId: 1,
            layerName: Layers.poiMapLayer(),
            categoryId: categoryComboBox.currentValue,
            categoryName: categoryComboBox.currentText,
            typeId: typeComboBox.currentValue,
            typeName: typeComboBox.currentText,
            healthStatusId: healthStatusComboBox.currentValue,
            healthStatusName: healthStatusComboBox.currentText,
            operationalStateId: operationalStateComboBox.currentValue,
            operationalStateName: operationalStateComboBox.currentText,
            details: {
                metadata: { note: noteTextArea.text }
            }
        }

        if (MapModeController.isEditing) {
            data.id = MapModeController.poi.id
            PoiModel.update(data)
        } else {
            PoiModel.append(data)
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
                    enabled: !PoiModel.loading && validate()
                    onClicked: save()
                }
            }
        }
    }
}
