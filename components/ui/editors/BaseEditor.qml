import QtQuick 6.8
import QtLocation 6.8
import "../../"
import raise.singleton.language 1.0

MapItemGroup {
    id: baseRoot
    property Map map
    // couple this for now for the poi editors and poi popups to be able to work together
    property WMSMapLayer wms

    // Automatic retranslation properties
    property string loadedMessage: qsTr("Loaded")
    property string destroyingMessage: qsTr("Destroying")

    // Auto-retranslate when language changes
    function retranslateUi() {
        loadedMessage = qsTr("Loaded")
        destroyingMessage = qsTr("Destroying")
    }

    Component.onCompleted: {
        console.log(baseRoot.loadedMessage + " " + baseRoot.objectName)
    }

    Component.onDestruction: {
        console.log(baseRoot.destroyingMessage + " " + baseRoot.objectName)
        map.removeMapItemGroup(baseRoot)
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            baseRoot.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
