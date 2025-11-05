pragma Singleton
import QtQuick 6.8

QtObject {

    function translate(text) {
        TranslationManager.revision
        return qsTr(text)
    }

}
