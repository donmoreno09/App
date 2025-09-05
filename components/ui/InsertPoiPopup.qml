import QtQuick 2.15
import raise.singleton.language 1.0

import "../"

PoiPopup {
    // TODO: Either to be removed or extract the save button functionality here
    id: poiPopup
    title: popupTitle
    visible: false

    // Automatic retranslation properties
    property string popupTitle: qsTr("Insert new POI")

    // Auto-retranslate when language changes
    function retranslateUi() {
        popupTitle = qsTr("Insert new POI")
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            poiPopup.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
