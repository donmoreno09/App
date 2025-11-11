import QtQuick 6.8

import App.Themes 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Panel Not Found")
}
