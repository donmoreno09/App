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

        return MapModeRegistry.createRectangleMode.topLeft.isValid && MapModeRegistry.createRectangleMode.bottomRight.isValid
    }

    Connections {
        target: MapModeController.activeMode
        ignoreUnknownSignals: true

        function onTopLeftChanged() {
            topLeftLatInput.updateText()
            topLeftLonInput.updateText()
        }

        function onBottomRightChanged() {
            bottomRightLatInput.updateText()
            bottomRightLonInput.updateText()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: topLeftLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Top Left Latitude(*)")

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.poi.topLeft = QtPositioning.coordinate(value, MapModeController.poi.topLeft.longitude)
                else MapModeRegistry.createRectangleMode.setTopLeftLatitude(value)
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.topLeft.latitude: MapModeRegistry.createRectangleMode.topLeft.latitude) }
            Component.onCompleted: updateText()
        }

        UI.InputCoordinate {
            id: topLeftLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Top Left Longitude(*)")
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.poi.topLeft = QtPositioning.coordinate(MapModeController.poi.topLeft.latitude, value)
                else MapModeRegistry.createRectangleMode.setTopLeftLongitude(value)
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.topLeft.longitude : MapModeRegistry.createRectangleMode.topLeft.longitude) }
            Component.onCompleted: updateText()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: bottomRightLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Bottom Right Latitude(*)")

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.poi.bottomRight = QtPositioning.coordinate(value, MapModeController.poi.bottomRight.longitude)
                else MapModeRegistry.createRectangleMode.setBottomRightLatitude(value)
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.bottomRight.latitude : MapModeRegistry.createRectangleMode.bottomRight.latitude) }
            Component.onCompleted: updateText()
        }

        UI.InputCoordinate {
            id: bottomRightLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Bottom Right Longitude(*)")
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.poi.bottomRight = QtPositioning.coordinate(MapModeController.poi.bottomRight.latitude, value)
                else MapModeRegistry.createRectangleMode.setBottomRightLongitude(value)
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.poi.bottomRight.longitude : MapModeRegistry.createRectangleMode.bottomRight.longitude) }
            Component.onCompleted: updateText()
        }
    }
}
