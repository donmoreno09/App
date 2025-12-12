import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: rectForm
    spacing: Theme.spacing.s4

    // Provided by callers
    property bool isEditing: false
    property var modeTarget: null
    property var readTopLeft
    property var readBottomRight
    property var writeTopLeftLat
    property var writeTopLeftLon
    property var writeBottomRightLat
    property var writeBottomRightLon

    property string topLeftLatLabel: qsTr("Top Left Latitude(*)")
    property string topLeftLonLabel: qsTr("Top Left Longitude(*)")
    property string bottomRightLatLabel: qsTr("Bottom Right Latitude(*)")
    property string bottomRightLonLabel: qsTr("Bottom Right Longitude(*)")

    // Guard to avoid writing back while syncing UI from the model
    property bool syncingFromModel: false

    property var validateFn: null

    function validate() {
        if (validateFn)
            return validateFn()
        if (isEditing)
            return true

        const tl = readTopLeft ? readTopLeft() : null
        const br = readBottomRight ? readBottomRight() : null
        return tl && br && tl.isValid && br.isValid
    }

    function syncFromModel() {
        syncingFromModel = true
        topLeftLatInput.updateText()
        topLeftLonInput.updateText()
        bottomRightLatInput.updateText()
        bottomRightLonInput.updateText()
        syncingFromModel = false
    }

    Connections {
        target: rectForm.modeTarget
        ignoreUnknownSignals: true

        function onTopLeftChanged() {
            rectForm.syncFromModel()
        }

        function onBottomRightChanged() {
            rectForm.syncFromModel()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: topLeftLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: rectForm.topLeftLatLabel

            onValueChanged: {
                if (rectForm.syncingFromModel)
                    return
                if (rectForm.writeTopLeftLat)
                    rectForm.writeTopLeftLat(value)
            }

            function updateText() {
                const c = rectForm.readTopLeft ? rectForm.readTopLeft() : null
                if (c)
                    setText(c.latitude)
            }

            Component.onCompleted: {
                rectForm.syncingFromModel = true
                updateText()
                rectForm.syncingFromModel = false
            }
        }

        UI.InputCoordinate {
            id: topLeftLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: rectForm.topLeftLonLabel
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (rectForm.syncingFromModel)
                    return
                if (rectForm.writeTopLeftLon)
                    rectForm.writeTopLeftLon(value)
            }

            function updateText() {
                const c = rectForm.readTopLeft ? rectForm.readTopLeft() : null
                if (c)
                    setText(c.longitude)
            }

            Component.onCompleted: {
                rectForm.syncingFromModel = true
                updateText()
                rectForm.syncingFromModel = false
            }
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: bottomRightLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: rectForm.bottomRightLatLabel

            onValueChanged: {
                if (rectForm.syncingFromModel)
                    return
                if (rectForm.writeBottomRightLat)
                    rectForm.writeBottomRightLat(value)
            }

            function updateText() {
                const c = rectForm.readBottomRight ? rectForm.readBottomRight() : null
                if (c)
                    setText(c.latitude)
            }

            Component.onCompleted: {
                rectForm.syncingFromModel = true
                updateText()
                rectForm.syncingFromModel = false
            }
        }

        UI.InputCoordinate {
            id: bottomRightLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: rectForm.bottomRightLonLabel
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (rectForm.syncingFromModel)
                    return
                if (rectForm.writeBottomRightLon)
                    rectForm.writeBottomRightLon(value)
            }

            function updateText() {
                const c = rectForm.readBottomRight ? rectForm.readBottomRight() : null
                if (c)
                    setText(c.longitude)
            }

            Component.onCompleted: {
                rectForm.syncingFromModel = true
                updateText()
                rectForm.syncingFromModel = false
            }
        }
    }
}
