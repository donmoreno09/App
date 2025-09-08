import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import Qt5Compat.GraphicalEffects
import App.Themes 1.0
import App.Features.TitleBar 1.0
import App.Features.Language 1.0

Rectangle {
    color: "transparent"


    Text {
        id: titleText
        anchors.centerIn: parent
        text: TitleBarController.currentTitle
        color: Theme.colors.text
        font.pointSize: Theme.typography.sizeSm
        opacity: 0

        SequentialAnimation on opacity {
            id: fadeAnim
            running: false
            PropertyAnimation { to: 0; duration: 0 }
            PauseAnimation { duration: 200 }
            PropertyAnimation { to: 1; duration: 1000 }
        }

        onTextChanged: fadeAnim.restart()
    }

    Rectangle {
        id: glowRect
        anchors.top: titleText.bottom
        anchors.horizontalCenter: titleText.horizontalCenter
        anchors.topMargin: 4
        width: 16
        height: 4
        topLeftRadius: Theme.radius.sm
        topRightRadius: Theme.radius.sm
        color: Theme.colors.primaryText
    }

    Glow {
        id: titleGlowEffect
        source: glowRect
        anchors.fill: glowRect
        color: "#5281c6f0"
        radius: 8
    }
}
