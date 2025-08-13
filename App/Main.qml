import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls

import App.Themes 1.0

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Theming System")

    Text {
        text: "Sample text"
        color: Theme.current.colors.text
    }
}
