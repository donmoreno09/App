import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    property var model: []
    property int currentIndex: 0

    signal itemClicked(int index)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    focusPolicy: Qt.StrongFocus

    Keys.onRightPressed:  {
        if (currentIndex < model.length - 1){
            currentIndex++
            itemClicked(currentIndex)
        }
    }

    Keys.onLeftPressed:  {
        if (currentIndex > 0){
            currentIndex--
            itemClicked(currentIndex)
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.colors.text
        border.width: Theme.borders.b1
        radius: Theme.radius.md
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: Theme.spacing.s1

        Repeater {
            model: root.model

            UI.Button {
                text: modelData
                Layout.fillWidth: true
                Layout.minimumWidth: 60
                Layout.margins: 4
                variant: index === root.currentIndex ? UI.ButtonStyles.Primary : UI.ButtonStyles.Ghost

                background: Rectangle {
                    color: variant === UI.ButtonStyles.Primary ? Theme.colors.primary500 : "transparent"
                    border.width: 0
                    radius: Theme.radius.sm
                }

                onClicked: {
                    root.currentIndex = index
                    root.itemClicked(index)
                }
            }
        }
    }
}
