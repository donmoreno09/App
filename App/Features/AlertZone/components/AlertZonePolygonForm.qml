import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Language 1.0

ColumnLayout {
    spacing: Theme.spacing.s4

    readonly property bool isValid: validate()

    function validate() {
        if (MapModeController.isEditing) {
            return true
        }

        const coordCount = MapModeRegistry.createPolygonMode.coordinatesCount()
        const isClosed = MapModeRegistry.createPolygonMode.closed
        const isValid = coordCount >= 3 && isClosed

        return isValid
    }

    component CoordInputs : RowLayout {
        required property int index
        spacing: Theme.spacing.s4

        Connections {
            target: MapModeController.activeMode
            ignoreUnknownSignals: true

            function onCoordinatesChanged() {
                latInput.updateText()
                lonInput.updateText()
            }
        }

        UI.InputCoordinate {
            id: latInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText:  `${TranslationManager.revision}` && qsTr("Point Lat. #") + (index + 1)

            onValueChanged: {
                const alertZone = MapModeController.alertZone
                const oldCoord = (MapModeController.isEditing) ? alertZone.coordinates[index] : MapModeRegistry.createPolygonMode.getCoordinate(index)
                const coord = QtPositioning.coordinate(value, oldCoord.longitude)
                if (MapModeController.isEditing) AlertZoneModel.setCoordinate(alertZone.modelIndex, index, coord)
                else MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
            }

            function updateText() {
                let value
                if (MapModeController.isEditing) value = MapModeController.alertZone.coordinates[index].latitude
                else value = MapModeRegistry.createPolygonMode.getCoordinate(index).latitude
                setText(value)
            }
            Component.onCompleted: updateText()
        }

        UI.InputCoordinate {
            id: lonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: `${TranslationManager.revision}` && qsTr("Point Lon. #") + (index + 1)
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                const alertZone = MapModeController.alertZone
                const oldCoord = (MapModeController.isEditing) ? alertZone.coordinates[index] : MapModeRegistry.createPolygonMode.getCoordinate(index)
                const coord = QtPositioning.coordinate(oldCoord.latitude, value)
                if (MapModeController.isEditing) AlertZoneModel.setCoordinate(alertZone.modelIndex, index, coord)
                else MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
            }

            function updateText() {
                let value
                if (MapModeController.isEditing) value = MapModeController.alertZone.coordinates[index].longitude
                else value = MapModeRegistry.createPolygonMode.getCoordinate(index).longitude
                setText(value)
            }
            Component.onCompleted: updateText()
        }
    }

    Label {
        Layout.fillWidth: true
        visible: {
            if (MapModeController.isEditing) return MapModeController.alertZone.coordinates.length === 0
            else return MapModeRegistry.createPolygonMode.coordinatesCount() === 0
        }
        text: `${TranslationManager.revision}` && qsTr("No coordinates inserted. Click on the map to add points.")
        wrapMode: Text.Wrap
        leftPadding: Theme.spacing.s4
        rightPadding: Theme.spacing.s4
        bottomPadding: Theme.spacing.s4
        font {
            family: Theme.typography.bodySans25Family
            pointSize: Theme.typography.bodySans25Size
            weight: Theme.typography.bodySans25Weight
        }
    }

    Repeater {
        model: {
            if (MapModeController.isEditing) return MapModeController.alertZone.coordinates.length
            else return MapModeRegistry.createPolygonMode.coordinatesCount()
        }
        delegate: CoordInputs { }
    }
}
