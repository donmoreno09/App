import QtQuick 6.8
import QtQuick.Controls 6.8

MenuItem {
    contentItem: Text {
        text: parent.text
        font: parent.font
        color: "black"
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: 200
        color: parent.highlighted ? "#adbed9" : "transparent"
    }
}
