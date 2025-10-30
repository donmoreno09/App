import QtQuick 6.8
import QtQuick.Controls 6.8
import QtMultimedia 6.8
import App.Components 1.0 as UI
import App.Themes 1.0
import QtQuick.Layouts

UI.FloatingWindow {
    id: videoWin
    width: 1200
    height: 740

    // Imposta un titolo opzionale
    property var parentWindow: null

    windowWidth: parentWindow ? parentWindow.width : 1200
    windowHeight: parentWindow ? parentWindow.height : 740
    property string title: "Video"
    property string videoTitle: "Video"
    property url source: "qrc:/App/assets/resources/Monitoraggio Goliath 2.mp4"

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.primary800

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacing.s2
            anchors.margins: Theme.spacing.s2

            Label {
                text: videoTitle
                color: Theme.colors.white500
                font.bold: true
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                Layout.leftMargin: Theme.spacing.s2
            }

            // Player
            Video {
                id: player
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: videoWin.source
                autoPlay: true
                loops: MediaPlayer.Infinite
                muted: false

                // Gestisci errori
                onErrorOccurred: (err, msg) => console.error("Video error:", err, msg)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacing.s3

                Button {
                    font.family: Theme.typography.familySans
                    text: player.playbackState === MediaPlayer.PlayingState ? "Pause" : "Play"
                    onClicked: {
                        player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                    }
                }
                Button {
                    font.family: Theme.typography.familySans
                    text: "Stop"
                    onClicked: player.stop()
                }
            }
        }
    }
}
