import QtQuick 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("New Mission")

    WizardPageTest { }
}
