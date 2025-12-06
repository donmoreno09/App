import QtQuick 6.8

Item {
    id: root

    property alias header: headerSlot.data
    default property alias content: contentSlot.data
    property alias footer: footerSlot.data

    Item {
        id: headerSlot
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: childrenRect.height
    }

    Item {
        id: contentSlot
        anchors.top: headerSlot.bottom
        anchors.bottom: footerSlot.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        id: footerSlot
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: childrenRect.height
    }
}
