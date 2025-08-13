import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls

import App.Themes 1.0

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Theming System")

    background: Rectangle {
        color: Theme.colors.background
    }

    Button {
        contentItem: Text {
            text: "Change Theme"
            color: Theme.colors.primaryText
            font.family: Theme.typography.familyMono
        }

        background: Rectangle {
            color: Theme.colors.primary
        }

        onClicked: {
            if (Theme.current === Theme.fincantieriTheme) {
                Theme.current = Theme.fincantieriLightTheme
            } else {
                Theme.current = Theme.fincantieriTheme
            }
        }
    }
}
