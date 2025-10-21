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
    title.text: (TranslationManager.revision, qsTr("Point of Interest"))

    Connections {
        target: PoiModel

        function onAppended() { SidePanelController.close(true) }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        // I have no idea why top/bottom padding
        // don't have scrollbars all the way there.
        leftPadding: Theme.spacing.s8
        rightPadding: Theme.spacing.s8

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.s4

            UI.VerticalPadding { }

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

            UI.InputCoordinate {
                id: latitudeInput
                Layout.fillWidth: true
                labelText: qsTr("Latitude(*)")

                onValueChanged: ToolRegistry.pointTool.setLatitude(value)

                function updateText() { latitudeInput.setText(ToolRegistry.pointTool.coord.latitude) }
                Component.onCompleted: updateText()
                Connections { target: ToolRegistry.pointTool; function onMapInputted() { latitudeInput.updateText() }}
            }

            UI.InputCoordinate {
                id: longitudeInput
                Layout.fillWidth: true
                labelText: qsTr("Longitude(*)")
                type: UI.InputCoordinate.Longitude

                onValueChanged: ToolRegistry.pointTool.setLongitude(value)

                function updateText() { longitudeInput.setText(ToolRegistry.pointTool.coord.longitude) }
                Component.onCompleted: updateText()
                Connections { target: ToolRegistry.pointTool; function onMapInputted() { longitudeInput.updateText() }}
            }

            UI.TextArea {
                id: noteTextArea
                Layout.fillWidth: true
                labelText: qsTr("Note")
            }

            UI.VerticalPadding { }
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
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: !PoiModel.saving
                    onClicked: PoiModel.append({
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
                    })
                }
            }
        }
    }

    Component.onCompleted: ToolController.activeTool = ToolRegistry.pointTool
    Component.onDestruction: ToolController.activeTool = null
}
