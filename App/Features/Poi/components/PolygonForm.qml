import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    spacing: Theme.spacing.s4

    component CoordInputs : RowLayout {
        required property string latLabel
        required property string lonLabel
        spacing: Theme.spacing.s4

        UI.InputCoordinate {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: latLabel
        }

        UI.InputCoordinate {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            labelText: lonLabel
            type: UI.InputCoordinate.Longitude
        }
    }

    CoordInputs {
        latLabel: qsTr("Point 1 Lat.")
        lonLabel: qsTr("Point 1 Lon.")
    }

    CoordInputs {
        latLabel: qsTr("Point 2 Lat.")
        lonLabel: qsTr("Point 2 Lon.")
    }

    CoordInputs {
        latLabel: qsTr("Point 3 Lat.")
        lonLabel: qsTr("Point 3 Lon.")
    }
}
