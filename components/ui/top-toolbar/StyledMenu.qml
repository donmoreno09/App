import QtQuick 6.8
import QtQuick.Controls 6.8

Menu {
    background: Rectangle {
        implicitWidth: 200
        radius: 2
        border.color: "#dddddd"
        border.width: 1
    }

    delegate: StyledMenuItem {
        arrow: MenuItemArrow {}
    }
}
