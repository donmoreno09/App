import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

// Main container
Rectangle {
    width: childrenRect.width + 16
    height: childrenRect.height + 16
    anchors.centerIn: parent
    color: Theme.colors.grey600
    radius: 5
    border.width: 1
    border.color: Qt.lighter(Theme.colors.grey600, 1.2)

    // ButtonGroup
    ButtonGroup {
        id: toolbarGroup
        exclusive: true
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 18

        RowLayout {
            spacing: 4

            UI.Button {
                icon.source: "qrc:/App/assets/icons/map.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: UI.ButtonStyles.Ghost
                checkable: true
                ButtonGroup.group: toolbarGroup

                implicitWidth: 36
                implicitHeight: 36

                backgroundRect.color: "#00182C"
                backgroundRect.radius: 4
                backgroundRect.border.width: 0

                onCheckedChanged: {
                    backgroundRect.color = checked ? "#2a2a2a" : "#00182C"
                }
            }

            UI.Button {
                icon.source: "qrc:/App/assets/icons/home.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: UI.ButtonStyles.Ghost
                checkable: true
                ButtonGroup.group: toolbarGroup

                implicitWidth: 36
                implicitHeight: 36

                backgroundRect.color: "#00182C"
                backgroundRect.radius: 4
                backgroundRect.border.width: 0

                onCheckedChanged: {
                    backgroundRect.color = checked ? "#2a2a2a" : "#00182C"
                }
            }
        }


        RowLayout {
            spacing: 4

            UI.Button {
                icon.source: "qrc:/App/assets/icons/send.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: UI.ButtonStyles.Ghost
                checkable: true
                ButtonGroup.group: toolbarGroup

                implicitWidth: 36
                implicitHeight: 36

                backgroundRect.color: "#00182C"
                backgroundRect.radius: 4
                backgroundRect.border.width: 0

                onCheckedChanged: {
                    backgroundRect.color = checked ? "#2a2a2a" : "#00182C"
                }
            }

            UI.Button {
                icon.source: "qrc:/App/assets/icons/plus.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: UI.ButtonStyles.Ghost
                checkable: true
                ButtonGroup.group: toolbarGroup

                implicitWidth: 36
                implicitHeight: 36

                backgroundRect.color: "#00182C"
                backgroundRect.radius: 4
                backgroundRect.border.width: 0

                onCheckedChanged: {
                    backgroundRect.color = checked ? "#2a2a2a" : "#00182C"
                }
            }

            UI.Button {
                icon.source: "qrc:/App/assets/icons/minus.svg"
                icon.width: Theme.icons.sizeLg
                icon.height: Theme.icons.sizeLg
                display: AbstractButton.IconOnly
                variant: UI.ButtonStyles.Ghost
                checkable: true
                ButtonGroup.group: toolbarGroup

                implicitWidth: 36
                implicitHeight: 36

                backgroundRect.color: "#00182C"
                backgroundRect.radius: 4
                backgroundRect.border.width: 0

                onCheckedChanged: {
                    backgroundRect.color = checked ? "#2a2a2a" : "#00182C"
                }
            }
        }
    }
}
