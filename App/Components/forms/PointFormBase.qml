import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: pointForm
    spacing: Theme.spacing.s4

    // Provided by callers
    property bool isEditing: false
    property var modeTarget: null
    property var readCoord
    property var writeLatitude
    property var writeLongitude

    property string latitudeLabel: qsTr("Latitude(*)")
    property string longitudeLabel: qsTr("Longitude(*)")

    // Guard to avoid writing back while syncing UI from the model
    property bool syncingFromModel: false

    property var validateFn: null

    function validate() {
        if (validateFn)
            return validateFn()
        if (isEditing)
            return true

        const c = readCoord ? readCoord() : null
        return c && c.isValid
    }

    function syncFromModel() {
        syncingFromModel = true
        latitudeInput.updateText()
        longitudeInput.updateText()
        syncingFromModel = false
    }

    Connections {
        target: pointForm.modeTarget
        ignoreUnknownSignals: true

        function onCoordChanged() {
            pointForm.syncFromModel()
        }
    }

    UI.InputCoordinate {
        id: latitudeInput
        Layout.fillWidth: true
        labelText: pointForm.latitudeLabel

        onValueChanged: {
            if (pointForm.syncingFromModel)
                return
            if (pointForm.writeLatitude)
                pointForm.writeLatitude(value)
        }

        function updateText() {
            const coord = pointForm.readCoord ? pointForm.readCoord() : null
            if (coord)
                setText(coord.latitude)
        }

        Component.onCompleted: {
            pointForm.syncingFromModel = true
            updateText()
            pointForm.syncingFromModel = false
        }
    }

    UI.InputCoordinate {
        id: longitudeInput
        Layout.fillWidth: true
        labelText: pointForm.longitudeLabel
        type: UI.InputCoordinate.Longitude

        onValueChanged: {
            if (pointForm.syncingFromModel)
                return
            if (pointForm.writeLongitude)
                pointForm.writeLongitude(value)
        }

        function updateText() {
            const coord = pointForm.readCoord ? pointForm.readCoord() : null
            if (coord)
                setText(coord.longitude)
        }

        Component.onCompleted: {
            pointForm.syncingFromModel = true
            updateText()
            pointForm.syncingFromModel = false
        }
    }
}
