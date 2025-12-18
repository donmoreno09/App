import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: ellipseForm
    spacing: Theme.spacing.s4

    // Provided by callers
    property bool isEditing: false
    property var modeTarget: null
    property var readCenter
    property var readRadiusA
    property var readRadiusB
    property var writeCenterLat
    property var writeCenterLon
    property var writeRadiusA
    property var writeRadiusB

    property string centerLatLabel: qsTr("Center Latitude(*)")
    property string centerLonLabel: qsTr("Center Longitude(*)")
    property string majorAxisLabel: qsTr("Major Axis(*)")
    property string minorAxisLabel: qsTr("Minor Axis(*)")
    property string majorAxisPlaceholder: qsTr("Type length")
    property string minorAxisPlaceholder: qsTr("Type length")

    // Guard to avoid writing back while syncing UI from the model
    property bool syncingFromModel: false

    property var validateFn: null

    function validate() {
        if (validateFn)
            return validateFn()
        if (isEditing)
            return true

        const c = readCenter ? readCenter() : null
        const a = readRadiusA ? readRadiusA() : 0
        const b = readRadiusB ? readRadiusB() : 0
        return c && c.isValid && a > 0 && b > 0
    }

    function syncFromModel() {
        syncingFromModel = true
        centerLatInput.updateText()
        centerLonInput.updateText()
        majorAxisInput.updateText()
        minorAxisInput.updateText()
        syncingFromModel = false
    }

    Connections {
        target: ellipseForm.modeTarget
        ignoreUnknownSignals: true

        function onCoordChanged() {
            ellipseForm.syncFromModel()
        }

        function onMajorAxisChanged() {
            ellipseForm.syncFromModel()
        }

        function onMinorAxisChanged() {
            ellipseForm.syncFromModel()
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: centerLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: ellipseForm.centerLatLabel

            onValueChanged: {
                if (ellipseForm.syncingFromModel)
                    return
                if (ellipseForm.writeCenterLat)
                    ellipseForm.writeCenterLat(value)
            }

            function updateText() {
                const c = ellipseForm.readCenter ? ellipseForm.readCenter() : null
                if (c)
                    setText(c.latitude)
            }

            Component.onCompleted: {
                ellipseForm.syncingFromModel = true
                updateText()
                ellipseForm.syncingFromModel = false
            }
        }

        UI.InputCoordinate {
            id: centerLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: ellipseForm.centerLonLabel
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (ellipseForm.syncingFromModel)
                    return
                if (ellipseForm.writeCenterLon)
                    ellipseForm.writeCenterLon(value)
            }

            function updateText() {
                const c = ellipseForm.readCenter ? ellipseForm.readCenter() : null
                if (c)
                    setText(c.longitude)
            }

            Component.onCompleted: {
                ellipseForm.syncingFromModel = true
                updateText()
                ellipseForm.syncingFromModel = false
            }
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.Input {
            id: majorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: ellipseForm.majorAxisLabel
            placeholderText: ellipseForm.majorAxisPlaceholder
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }

            onTextEdited: {
                if (ellipseForm.syncingFromModel)
                    return
                const value = Number(text) || 0
                if (ellipseForm.writeRadiusA)
                    ellipseForm.writeRadiusA(value)
            }

            function updateText() {
                const value = ellipseForm.readRadiusA ? ellipseForm.readRadiusA() : 0
                text = Number(value || 0).toFixed(6)
            }

            Component.onCompleted: {
                ellipseForm.syncingFromModel = true
                updateText()
                ellipseForm.syncingFromModel = false
            }
        }

        UI.Input {
            id: minorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: ellipseForm.minorAxisLabel
            placeholderText: ellipseForm.minorAxisPlaceholder
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }

            onTextEdited: {
                if (ellipseForm.syncingFromModel)
                    return
                const value = Number(text) || 0
                if (ellipseForm.writeRadiusB)
                    ellipseForm.writeRadiusB(value)
            }

            function updateText() {
                const value = ellipseForm.readRadiusB ? ellipseForm.readRadiusB() : 0
                text = Number(value || 0).toFixed(6)
            }

            Component.onCompleted: {
                ellipseForm.syncingFromModel = true
                updateText()
                ellipseForm.syncingFromModel = false
            }
        }
    }
}
