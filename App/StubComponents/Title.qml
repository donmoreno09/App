import QtQuick 6.8

import App.Themes 1.0
import App.Features.Language 1.0

Rectangle {
    color: "transparent"

    Text {
        id: titleText
        anchors.centerIn: parent
        text: (TranslationManager.revision, qsTr("Overview"))
        color: Theme.colors.text
        font.pointSize: Theme.typography.sizeSm
    }

    Rectangle {
        anchors.top: titleText.bottom
        anchors.horizontalCenter: titleText.horizontalCenter
        anchors.topMargin: 4
        width: 16
        height: 4
        topLeftRadius: Theme.radius.sm
        topRightRadius: Theme.radius.sm
    }
}
