import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

Rectangle {

       property string message: ""
       property color messageColor: Theme.colors.text
       property color bgColor: Theme.colors.success500

       Layout.fillWidth: true
       Layout.preferredHeight: messageText.implicitHeight + Theme.spacing.s6
       color: bgColor
       radius: Theme.radius.sm
       opacity: 0.15

       Text {
           id: messageText
           anchors.centerIn: parent
           width: parent.width - Theme.spacing.s8
           text: message
           color: messageColor
           wrapMode: Text.WordWrap
           horizontalAlignment: Text.AlignHCenter
           font.family: Theme.typography.familySans
           font.pixelSize: Theme.typography.fontSize150
       }
}
