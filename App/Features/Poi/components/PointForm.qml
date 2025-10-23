import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    spacing: Theme.spacing.s4

    UI.InputCoordinate {
        id: latitudeInput
        Layout.fillWidth: true
        labelText: qsTr("Latitude(*)")
    }

    UI.InputCoordinate {
        id: longitudeInput
        Layout.fillWidth: true
        labelText: qsTr("Longitude(*)")
        type: UI.InputCoordinate.Longitude
    }
}
