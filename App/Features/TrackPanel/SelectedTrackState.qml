pragma Singleton
import QtQuick 6.8
import App

QtObject {
    property QtObject selectedItem: null

    function select(item : QtObject) {
        selectedItem = item
    }
}
