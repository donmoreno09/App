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

    // Imposta un titolo opzionale
    property var parentWindow: null

    windowWidth: parentWindow ? parentWindow.width : 1200
    windowHeight: parentWindow ? parentWindow.height : 740
    property string title: "Goliath Lifted Loads"
    property url source: "qrc:/App/assets/resources/Goliath_Lifted_Loads.jpg"

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.primary800

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacing.s2
            anchors.margins: Theme.spacing.s2

            Label {
                text: title
                color: Theme.colors.white500
                font.bold: true
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                Layout.leftMargin: Theme.spacing.s2
            }
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
