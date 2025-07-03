import QtQuick 6.8
import QtQuick.Controls 6.8

Rectangle {
    id: testRect
    width: 500
    height: 500
    color: "red"
    border.color: "white"
    border.width: 2
    anchors.left: parent.left
    anchors.top: parent.top

    LayersList {
        id: lefttoolbar
        anchors.fill: parent
    }
}
