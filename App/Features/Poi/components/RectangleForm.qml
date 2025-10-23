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
            id: topLeftLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Top Left Latitude(*)")
        }

        UI.InputCoordinate {
            id: topLeftLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Top Left Longitude(*)")
            type: UI.InputCoordinate.Longitude
        }
    }

    RowLayout {
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            id: bottomRightLatInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Bottom Right Latitude(*)")
        }

        UI.InputCoordinate {
            id: bottomRightLonInput
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: qsTr("Bottom Right Longitude(*)")
            type: UI.InputCoordinate.Longitude
        }
    }
}
