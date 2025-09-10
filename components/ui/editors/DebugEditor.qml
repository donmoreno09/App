import QtQuick 6.8
import QtLocation 6.8

BaseEditor {
    objectName: "DebugEditor"

    Rectangle {
        color: "red"
        anchors.fill: parent
        opacity: 0.5

        // Debug output per capire se è stato caricato
        Component.onCompleted: console.log("[EditorDummy] Caricato e visibile!")
    }
}
