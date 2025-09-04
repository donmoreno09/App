import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Rectangle {
    id: root

    property bool exclusive: false

    property color containerColor: Theme.colors.surface
    property int containerRadius: Theme.radius.lg
    property int spacing: Theme.spacing.s1
    property int padding: Theme.spacing.s2

    ButtonGroup {
        id: buttonGroup
        exclusive: root.exclusive
    }

    color: containerColor
    radius: containerRadius
    border.width: Theme.borders.b1
    border.color: Qt.lighter(containerColor, 1.2)

    implicitWidth: buttonRow.implicitWidth + (padding * 2)
    implicitHeight: buttonRow.implicitHeight + (padding * 2)

    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: root.spacing
    }

    default property alias children: buttonRow.children

    onChildrenChanged: {
        if (exclusive) {
            for (let i = 0; i < buttonRow.children.length; i++) {
                const button = buttonRow.children[i]
                if (button && typeof button.checkable !== "undefined") {
                    buttonGroup.addButton(button)
                }
            }
        }
    }
}
