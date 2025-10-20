import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapTools 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Point of Interest"))

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s8
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

        UI.Input {
            id: latitudeInput
            Layout.fillWidth: true
            labelText: qsTr("Latitude(*)")
            placeholderText: qsTr("0.000000")

            Binding {
                target: latitudeInput
                property: "text"
                value: {
                    const latitude = Number(ToolRegistry.pointTool.coord.latitude)
                    if (latitude) return latitude.toFixed(6)
                    return "";
                }

                when: !latitudeInput.activeFocus
                restoreMode: Binding.RestoreBindingOrValue
            }

            onTextEdited: ToolRegistry.pointTool.setLatitude(parseFloat(text) || 0)
        }

        UI.Input {
            id: longitudeInput
            Layout.fillWidth: true
            labelText: qsTr("Longitude(*)")
            placeholderText: qsTr("0.000000")

            Binding {
                target: longitudeInput
                property: "text"
                value: {
                    const longitude = Number(ToolRegistry.pointTool.coord.longitude)
                    if (longitude) return longitude.toFixed(6)
                    return "";
                }

                when: !longitudeInput.activeFocus
                restoreMode: Binding.RestoreBindingOrValue
            }

            onTextEdited: ToolRegistry.pointTool.setLongitude(parseFloat(text) || 0)
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
                }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Save")
                }
            }
        }
    }
}
