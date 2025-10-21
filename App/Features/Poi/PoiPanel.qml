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

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        padding: Theme.spacing.s8

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
                model: ListModel {
                    id: categoryModel
                    ListElement { name: "Buildings" }
                    ListElement { name: "Docking" }
                    ListElement { name: "Terminals" }
                }

                function getKey() {
                    return currentIndex + 1
                }
            }

            UI.ComboBox {
                id: typeComboBox
                Layout.fillWidth: true
                labelText: qsTr("Type")
                model: [buildingsModel, dockingModel, terminalsModel][categoryComboBox.currentIndex]

                ListModel {
                    id: buildingsModel
                    readonly property int keyStart: 1
                    ListElement { value: "Office" }
                    ListElement { value: "Fuel station" }
                    ListElement { value: "Mechanical workshop" }
                    ListElement { value: "Maintenance Building" }
                    ListElement { value: "Worksite" }
                }

                ListModel {
                    id: dockingModel
                    readonly property int keyStart: 6
                    ListElement { value: "Dock A" }
                    ListElement { value: "Dock B" }
                }

                ListModel {
                    id: terminalsModel
                    readonly property int keyStart: 8
                    ListElement { value: "Container Terminal" }
                    ListElement { value: "Ro-Ro Terminal" }
                }

                function getKey() {
                    return model.keyStart + currentIndex
                }
            }

            UI.ComboBox {
                id: healthStatusComboBox
                Layout.fillWidth: true
                labelText: qsTr("Health Status(*)")
                model: ListModel {
                    id: healthStatusModel
                    ListElement { name: "Active" }
                    ListElement { name: "Off" }
                    ListElement { name: "Degraded" }
                    ListElement { name: "Maintenance" }
                }

                function getKey() {
                    return currentIndex + 1
                }
            }

            UI.ComboBox {
                id: operationalStateComboBox
                Layout.fillWidth: true
                labelText: qsTr("Operational State(*)")
                model: ListModel {
                    id: operationalStateModel
                    ListElement { name: "Standby" }
                    ListElement { name: "Operating" }
                    ListElement { name: "In transit" }
                    ListElement { name: "Waiting" }
                }

                function getKey() {
                    return currentIndex + 1
                }
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
                    onClicked: PoiModel.append({
                        label: nameInput.text,
                        geometry: {
                           shapeTypeId: 1,
                           coordinate: { x: ToolRegistry.pointTool.coord.longitude, y: ToolRegistry.pointTool.coord.latitude },
                        },
                        layerId: 1,
                        layerName: Layers.poiMapLayer(),
                        categoryId: categoryComboBox.getKey(),
                        categoryName: categoryComboBox.currentValue,
                        typeId: typeComboBox.getKey(),
                        typeName: typeComboBox.currentValue,
                        healthStatusId: healthStatusComboBox.getKey(),
                        healthStatusName: healthStatusComboBox.currentValue,
                        operationalStateId: operationalStateComboBox.getKey(),
                        operationalStateName: operationalStateComboBox.currentValue,
                        details: {
                            metadata: { note: noteTextArea.text }
                        }
                    })
                }
            }
        }
    }
}
