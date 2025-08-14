import QtQuick 6.8
import QtLocation 6.8

BaseEditor {
    objectName: "DebugEditor"

    // Automatic retranslation properties
    property string debugLoadedMessage: qsTr("[EditorDummy] Loaded and visible!")

    // Auto-retranslate when language changes
    function retranslateUi() {
        debugLoadedMessage = qsTr("[EditorDummy] Loaded and visible!")
    }

    Rectangle {
        color: "red"
        anchors.fill: parent
        opacity: 0.5

        Component.onCompleted: console.log(parent.debugLoadedMessage)
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
