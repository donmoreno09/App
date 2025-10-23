import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    spacing: Theme.spacing.s4

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: centerLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Center Latitude(*)")
        }

        UI.InputCoordinate {
            id: centerLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Center Longitude(*)")
            type: UI.InputCoordinate.Longitude
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.Input {
            id: majorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Major Axis(*)")
            placeholderText: qsTr("Type length")
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
            }
        }

        UI.Input {
            id: minorAxisInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Minor Axis(*)")
            placeholderText: qsTr("Type length")
            validator: DoubleValidator {
                bottom: 0
                top: 9999
                notation: DoubleValidator.StandardNotation
            }
        }
    }
}
