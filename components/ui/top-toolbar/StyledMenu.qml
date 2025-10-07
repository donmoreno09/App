import QtQuick 6.8
import QtQuick.Controls 6.8

Menu {
    background: Rectangle {
        color:"#f21f3154"
        implicitWidth: 200
        radius: 2
        border.color: "#404040"
        border.width: 1
    }

    delegate: StyledMenuItem {
        arrow: MenuItemArrow {}
    }
}
