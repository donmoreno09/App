/*!
    \qmltype DateTimeTest
    \inqmlmodule App.Playground
    \brief Simple test interface for the DateTime component.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import App.Themes 1.0
import App.Components 1.0 as UI

RowLayout {
    UI.DateTime {
        id: dateTimeComponent
    }
}
