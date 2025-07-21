import QtQuick 6.8
import QtQuick.Controls 6.8

MenuSeparator {
    property var text

    topPadding: 4
    bottomPadding: 4
    leftPadding: 6
    rightPadding: 6

    contentItem: Text {
        text: parent.text
        color: "white"
        width: parent.width
        font.pixelSize: 12
        anchors.verticalCenter: parent.verticalCenter
    }
}
