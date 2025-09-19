pragma Singleton
import QtQuick 6.8
import App.Features.Language 1.0

QtObject {
    id: titleBarController

    property string currentTitleKey: "Overview"
    property string currentTitle: translateTitle(currentTitleKey)

    function setTitle(titleKey) {
        if (currentTitleKey !== titleKey) {
            currentTitleKey = titleKey
            currentTitle = translateTitle(titleKey)
        }
    }

    function translateTitle(key) {
        switch(key) {
            case "Overview": return qsTr("Overview")
            case "Languages": return qsTr("Languages")
            case "Mission": return qsTr("Mission")
            case "Pod": return qsTr("Pod")
            case "Notifications": return qsTr("Notifications")
            case "Map Tilesets": return qsTr("Map Tilesets")
            default: return key
        }
    }

    property Connections translationConnection: Connections {
        target: TranslationManager
        function onRevisionChanged() {
            currentTitle = translateTitle(currentTitleKey)
        }
    }
}
