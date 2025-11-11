import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

import "components"

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Languages")

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s1

        LanguageItem {
            source: "qrc:/App/assets/icons/flag-it.svg"
            text: `${TranslationManager.revision}` && qsTr("Italian")
            active: LanguageController.currentLanguage === "it"

            onClicked: LanguageController.currentLanguage = "it"
        }

        LanguageItem {
            source: "qrc:/App/assets/icons/flag-gb.svg"
            text: `${TranslationManager.revision}` && qsTr("English")
            active: LanguageController.currentLanguage === "en"

            onClicked: LanguageController.currentLanguage = "en"
        }
    }
}
