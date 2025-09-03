import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0
import App.Themes 1.0
import App.Features.TitleBar 1.0

GlobalBackgroundConsumer {
    id: root

    ColumnLayout {
        spacing: Theme.spacing.s4
        anchors.fill: parent

        Button {
            id: languageButton
            variant: checked ? "primary" : "ghost"
            size: "lg"
            display: AbstractButton.IconOnly

            icon.source: "qrc:/App/assets/icons/home.svg"
            icon.width: Theme.icons.sizeLg
            icon.height: Theme.icons.sizeLg
            icon.color: checked ? Theme.colors.primaryText : Theme.colors.text


            onClicked: {
                TitleBarController.setTitle("Language Settings")
            }

            ToolTip {
                visible: parent.hovered
                text: "Language Settings"
                delay: 800
            }
        }


        Button {
            id: wizardButton
            variant: checked ? "primary" : "ghost"
            size: "lg"
            display: AbstractButton.IconOnly

            icon.source: "qrc:/App/assets/icons/plus.svg"
            icon.width: Theme.icons.sizeLg
            icon.height: Theme.icons.sizeLg
            icon.color: checked ? Theme.colors.primaryText : Theme.colors.text

            onClicked: {
                TitleBarController.setTitle("Mission Wizard")
            }

            ToolTip {
                visible: parent.hovered
                text: "Mission Wizard"
                delay: 800
            }
        }
    }
}
