import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls
import App.Themes 1.0
import App.Playground 1.0 as Playground

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: qsTr("DateTime Component Testing")

    background: Rectangle {
        color: Theme.colors.background
    }

    Playground.DateTimeTest {
        anchors.fill: parent
    }
}
