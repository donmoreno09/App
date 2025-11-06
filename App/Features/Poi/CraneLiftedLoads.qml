import QtQuick 6.8
import QtQuick.Controls 6.8
import QtMultimedia 6.8
import App.Components 1.0 as UI
import App.Themes 1.0
import QtQuick.Layouts

UI.FloatingWindow {
    id: loadsWin
    width: 1200
    height: 740
    windowTitle: "Lifted Loads"

    property var parentWindow: null // needed by WindowRouter
    readonly property string title: windowTitle // needed by WindowRouter

    windowWidth: parentWindow ? parentWindow.width : 1200
    windowHeight: parentWindow ? parentWindow.height : 740
    property url source: "qrc:/App/assets/resources/Goliath_Lifted_Loads.jpg"

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.primary800

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacing.s2
            anchors.margins: Theme.spacing.s2

            // L'immagine che riempie lo spazio rimanente
            Image {
                id: loadsImage
                source: loadsWin.source
                fillMode: Image.PreserveAspectFit  // mantiene le proporzioni
                Layout.fillWidth: true
                Layout.fillHeight: true
                smooth: true
            }
        }
    }
}
