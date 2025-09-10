import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    width: 80
    height: 24

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        opacity: enabled ? 1 : 0.3
        color: control.hovered && control.enabled ? "#404040" : "transparent"
        border.color: "#888888"
        border.width: 1
        radius: 2
    }
}
