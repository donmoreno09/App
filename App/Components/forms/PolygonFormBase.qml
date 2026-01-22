import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: polygonForm
    spacing: Theme.spacing.s4

    // Provided by callers
    property bool isEditing: false
    property var modeTarget: null
    property var readCount    // () -> int
    property var readCoord    // (index) -> geoCoordinate
    property var writeCoordinate // (index, coordinate) -> void
    property bool requireClosed: false
    property var readClosed   // () -> bool

    property string latLabelPattern: qsTr("Point Lat. #%1")
    property string lonLabelPattern: qsTr("Point Lon. #%1")
    property string emptyMessage: qsTr("No coordinates inserted. Start by clicking anywhere on the map to insert the first coordinate.")

    // Guard to avoid writing back while syncing UI from the model
    property bool syncingFromModel: false

    property var validateFn: null

    function validate() {
        if (validateFn)
            return validateFn()
        if (isEditing)
            return true

        const count = readCount ? Number(readCount()) : 0
        const closedOk = !requireClosed || (readClosed ? readClosed() : false)
        return count >= 3 && closedOk
    }

    component CoordInputs : RowLayout {
        required property int index
        spacing: Theme.spacing.s4

        Connections {
            target: polygonForm.modeTarget
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
            labelText: polygonForm.latLabelPattern.arg(index + 1)

            onValueChanged: {
                if (polygonForm.syncingFromModel)
                    return

                const oldCoord = polygonForm.readCoord ? polygonForm.readCoord(index) : null
                const coord = QtPositioning.coordinate(value, oldCoord ? oldCoord.longitude : 0)
                if (polygonForm.writeCoordinate)
                    polygonForm.writeCoordinate(index, coord)
            }

            function updateText() {
                const c = polygonForm.readCoord ? polygonForm.readCoord(index) : null
                if (c)
                    setText(c.latitude)
            }

            Component.onCompleted: {
                polygonForm.syncingFromModel = true
                updateText()
                polygonForm.syncingFromModel = false
            }
        }

        UI.InputCoordinate {
            id: lonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: polygonForm.lonLabelPattern.arg(index + 1)
            type: UI.InputCoordinate.Longitude

            onValueChanged: {
                if (polygonForm.syncingFromModel)
                    return

                const oldCoord = polygonForm.readCoord ? polygonForm.readCoord(index) : null
                const coord = QtPositioning.coordinate(oldCoord ? oldCoord.latitude : 0, value)
                if (polygonForm.writeCoordinate)
                    polygonForm.writeCoordinate(index, coord)
            }

            function updateText() {
                const c = polygonForm.readCoord ? polygonForm.readCoord(index) : null
                if (c)
                    setText(c.longitude)
            }

            Component.onCompleted: {
                polygonForm.syncingFromModel = true
                updateText()
                polygonForm.syncingFromModel = false
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: {
            if (!polygonForm.readCount)
                return true
            const count = polygonForm.readCount()
            return count === 0
        }
        text: polygonForm.emptyMessage
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
        model: polygonForm.readCount ? polygonForm.readCount() : 0
        delegate: CoordInputs { }
    }
}
