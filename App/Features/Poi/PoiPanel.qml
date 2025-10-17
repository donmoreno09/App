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
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s1

        UI.Input {
            id: nameInput
            Layout.fillWidth: true
            labelText: "Name(*)"
            placeholderText: qsTr("Name")
        }

        UI.Input {
            id: latitudeInput
            Layout.fillWidth: true
            labelText: "Latitude(*)"
            placeholderText: "0.000000"

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
            labelText: "Longitude(*)"
            placeholderText: "0.000000"

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
}
