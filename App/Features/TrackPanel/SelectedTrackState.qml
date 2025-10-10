pragma Singleton
import QtQuick 6.8
import App

QtObject {
    property var model: null
    property int index: -1     // Selected Row (index)

    function select(m, i) {
        console.log(m)
        console.log(i)
        model = m
        index = i
    }
}
