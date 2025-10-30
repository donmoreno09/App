import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0

ColumnLayout {
    spacing: Theme.spacing.s4

    function validate() {
        if (MapModeController.isEditing) return true

        return MapModeRegistry.createPointMode.coord.isValid
    }

    Connections {
        target: MapModeController.activeMode
        ignoreUnknownSignals: true

        function onCoordChanged() {
            latitudeInput.updateText()
            longitudeInput.updateText()
        }
    }

    UI.InputCoordinate {
        id: latitudeInput
        Layout.fillWidth: true
        labelText: qsTr("Latitude(*)")

        onValueChanged: {
            if (MapModeController.isEditing) MapModeController.poi.coordinate = QtPositioning.coordinate(value, MapModeController.poi.coordinate.longitude)
            else MapModeRegistry.createPointMode.coord.latitude = value
        }

        function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.coordinate.latitude : MapModeRegistry.createPointMode.coord.latitude) }
        Component.onCompleted: updateText()
    }

    UI.InputCoordinate {
        id: longitudeInput
        Layout.fillWidth: true
        labelText: qsTr("Longitude(*)")
        type: UI.InputCoordinate.Longitude

        onValueChanged: {
            if (MapModeController.isEditing) MapModeController.poi.coordinate = QtPositioning.coordinate(MapModeController.poi.coordinate.latitude, value)
            else MapModeRegistry.createPointMode.coord.longitude = value
        }

        function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.coordinate.longitude : MapModeRegistry.createPointMode.coord.longitude) }
        Component.onCompleted: updateText()
    }
}
