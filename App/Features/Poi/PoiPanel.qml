import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapTools 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    id: root

    title.text: (TranslationManager.revision, qsTr("Point of Interest"))

    function updateTexts() {
        latitudeInput.updateText()
        longitudeInput.updateText()
        if (ToolRegistry.pointTool.editable) {
            nameInput.text = ToolRegistry.pointTool.editable.label
            noteTextArea.text = ToolRegistry.pointTool.editable.note ?? ""
            categoryComboBox.currentIndex = categoryComboBox.comboBox.indexOfValue(ToolRegistry.pointTool.editable.categoryId)
            typeComboBox.currentIndex = typeComboBox.comboBox.indexOfValue(ToolRegistry.pointTool.editable.typeId)
            healthStatusComboBox.currentIndex = healthStatusComboBox.comboBox.indexOfValue(ToolRegistry.pointTool.editable.healthStatusId)
            operationalStateComboBox.currentIndex = operationalStateComboBox.comboBox.indexOfValue(ToolRegistry.pointTool.editable.operationalStateId)
        }
    }

    Connections {
        target: PoiModel

        function onAppended() { SidePanelController.close(true) }
        function onUpdated() { SidePanelController.close(true) }
        function onRemoved() { SidePanelController.close(true) }
        function onFetched() { root.updateTexts() }
    }

    Connections {
        target: ToolRegistry.pointTool

        function onMapInputted() { root.updateTexts() }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        Component.onCompleted: updateTexts()

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

                    onTextEdited: if (ToolRegistry.pointTool.editable) ToolRegistry.pointTool.editable.label = text
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

                UI.InputCoordinate {
                    id: latitudeInput
                    Layout.fillWidth: true
                    labelText: qsTr("Latitude(*)")

                    onValueChanged: {
                        ToolRegistry.pointTool.setLatitude(value)
                        if (ToolRegistry.pointTool.editable) ToolRegistry.pointTool.editable.latitude = value
                    }

                    function updateText() { latitudeInput.setText(ToolRegistry.pointTool.coord.latitude) }
                    Component.onCompleted: updateText()
                }

                UI.InputCoordinate {
                    id: longitudeInput
                    Layout.fillWidth: true
                    labelText: qsTr("Longitude(*)")
                    type: UI.InputCoordinate.Longitude

                    onValueChanged: {
                        ToolRegistry.pointTool.setLongitude(value)
                        if (ToolRegistry.pointTool.editable) ToolRegistry.pointTool.editable.longitude = value
                    }

                    function updateText() { longitudeInput.setText(ToolRegistry.pointTool.coord.longitude) }
                    Component.onCompleted: updateText()
                }

                UI.TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    labelText: qsTr("Note")

                    onTextEdited: if (ToolRegistry.pointTool.editable) ToolRegistry.pointTool.editable.note = text
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
                    visible: !!ToolRegistry.pointTool.editable
                    enabled: !PoiModel.loading
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    variant: UI.ButtonStyles.Danger
                    backgroundRect.border.width: Theme.borders.b0
                    text: qsTr("Remove")
                    onClicked: PoiModel.remove(ToolRegistry.pointTool.editable.id)
                }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: !PoiModel.loading
                    onClicked: {
                        const data = {
                            label: nameInput.text,
                            geometry: {
                               shapeTypeId: 1,
                               coordinate: { x: ToolRegistry.pointTool.coord.longitude, y: ToolRegistry.pointTool.coord.latitude },
                            },
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

                        if (ToolRegistry.pointTool.editable) {
                            data.id = ToolRegistry.pointTool.editable.id
                            PoiModel.update(data)
                        } else {
                            PoiModel.append(data)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: ToolController.activeTool = ToolRegistry.pointTool
    Component.onDestruction: {
        ToolRegistry.pointTool.editable = null
        ToolController.activeTool = null
        PoiModel.discardChanges()
    }
}
