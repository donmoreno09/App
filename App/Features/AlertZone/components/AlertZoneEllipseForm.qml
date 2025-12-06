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

    function validate() {
        if (MapModeController.isEditing) return true

        return MapModeRegistry.createEllipseMode.coord.isValid
                && MapModeRegistry.createEllipseMode.radiusA > 0
                && MapModeRegistry.createEllipseMode.radiusB > 0
    }

    Connections {
        target: MapModeController.activeMode
        ignoreUnknownSignals: true

        function onCoordChanged() {
            centerLatInput.updateText()
            centerLonInput.updateText()
        }

        function onMajorAxisChanged() {
            majorAxisInput.updateText()
        }

        function onMinorAxisChanged() {
            minorAxisInput.updateText()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: centerLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: `${TranslationManager.revision}` && qsTr("Center Latitude(*)")

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.alertZone.coordinate = QtPositioning.coordinate(value, MapModeController.alertZone.coordinate.longitude)
                else MapModeRegistry.createEllipseMode.coord.latitude = value
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.alertZone.coordinate.latitude : MapModeRegistry.createEllipseMode.coord.latitude) }
            Component.onCompleted: updateText()
        }

        UI.InputCoordinate {
            id: centerLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: `${TranslationManager.revision}` && qsTr("Center Longitude(*)")
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (MapModeController.isEditing) MapModeController.alertZone.coordinate = QtPositioning.coordinate(MapModeController.alertZone.coordinate.latitude, value)
                else MapModeRegistry.createEllipseMode.coord.longitude = value
            }

            function updateText() { setText((MapModeController.isEditing) ? MapModeController.alertZone.coordinate.longitude : MapModeRegistry.createEllipseMode.coord.longitude) }
            Component.onCompleted: updateText()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.Input {
            id: majorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: `${TranslationManager.revision}` && qsTr("Major Axis(*)")
            placeholderText: `${TranslationManager.revision}` && qsTr("Type length")
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }

            onTextEdited: {
                const value = Number(text) || 0
                if (MapModeController.isEditing) MapModeController.alertZone.radiusA = value
                else MapModeRegistry.createEllipseMode.radiusA = value
            }

            function updateText() {
                const value = (MapModeController.isEditing) ? MapModeController.alertZone.radiusA : MapModeRegistry.createEllipseMode.radiusA
                text = value.toFixed(6)
            }

            Component.onCompleted: updateText()
        }

        UI.Input {
            id: minorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: `${TranslationManager.revision}` && qsTr("Minor Axis(*)")
            placeholderText: `${TranslationManager.revision}` && qsTr("Type length")
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }

            onTextEdited: {
                const value = Number(text) || 0
                console.log("text:", text, "value:", value)
                if (MapModeController.isEditing) MapModeController.alertZone.radiusB = value
                else MapModeRegistry.createEllipseMode.radiusB = value
            }

            function updateText() {
                const value = (MapModeController.isEditing) ? MapModeController.alertZone.radiusB : MapModeRegistry.createEllipseMode.radiusB
                text = value.toFixed(6)
            }

            Component.onCompleted: updateText()
        }
    }
}
