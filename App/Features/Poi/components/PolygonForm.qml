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

        return MapModeRegistry.createPolygonMode.coordinatesCount() >= 3
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
            labelText: qsTr("Point Lat. #") + (index + 1)

            onValueChanged: {
                const poi = MapModeController.poi
                const oldCoord = (MapModeController.isEditing) ? poi.coordinates[index] : MapModeRegistry.createPolygonMode.getCoordinate(index)
                const coord = QtPositioning.coordinate(value, oldCoord.longitude)
                if (MapModeController.isEditing) PoiModel.setCoordinate(poi.modelIndex, index, coord)
                else MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
            }

            function updateText() {
                let value
                if (MapModeController.isEditing) value = MapModeController.poi.coordinates[index].latitude
                else value = MapModeRegistry.createPolygonMode.getCoordinate(index).latitude
                setText(value)
            }
            Component.onCompleted: updateText()
        }

        UI.InputCoordinate {
            id: lonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Point Lon. #") + (index + 1)
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                const poi = MapModeController.poi
                const oldCoord = (MapModeController.isEditing) ? poi.coordinates[index] : MapModeRegistry.createPolygonMode.getCoordinate(index)
                const coord = QtPositioning.coordinate(oldCoord.latitude, value)
                if (MapModeController.isEditing) PoiModel.setCoordinate(poi.modelIndex, index, coord)
                else MapModeRegistry.createPolygonMode.setCoordinate(index, coord)
            }

            function updateText() {
                let value
                if (MapModeController.isEditing) value = MapModeController.poi.coordinates[index].longitude
                else value = MapModeRegistry.createPolygonMode.getCoordinate(index).longitude
                setText(value)
            }
            Component.onCompleted: updateText()
        }
    }

    Label {
        Layout.fillWidth: true
        visible: {
            if (MapModeController.isEditing) return MapModeController.poi.coordinates.length === 0
            else return MapModeRegistry.createPolygonMode.coordinatesCount() === 0
        }
        text: qsTr("No coordinates inserted. Start by clicking anywhere on the map to insert the first coordinate.")
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
            if (MapModeController.isEditing) return MapModeController.poi.coordinates.length
            else return MapModeRegistry.createPolygonMode.coordinatesCount()
        }
        delegate: CoordInputs { }
    }
}
