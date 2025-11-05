pragma Singleton

import QtQuick 6.8
import App.Features.Language 1.0

QtObject {

    Component.onCompleted: {
           console.log("TranslationHelper loaded!")
       }

    function tr(text){
        var _ = TranslationManager.revision // I know this looks useless, but I'm intentionally evaluating this expression for side effects (creating a binding dependency)
        return qsTr(text)
    }
}
