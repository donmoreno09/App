import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Effects 6.8

import App.Auth 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

UI.Overlay {
    id: root

    signal settingsRequested()

    width: Theme.layout.userMenuWidth
    showBackdrop: false
    anchors.centerIn: undefined
    transformOrigin: Item.BottomLeft
    padding: 0

    background: Rectangle {
        radius: Theme.radius.lg
        color: Theme.colors.whiteA10
        border.width: Theme.borders.b1
        border.color: Theme.colors.whiteA10
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0;    to: 1.0;  duration: 200; easing.type: Easing.OutBack }
            NumberAnimation { property: "scale";   from: 0.92; to: 1.0;  duration: 200; easing.type: Easing.OutBack }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0;    duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale";   from: 1.0; to: 0.92; duration: 150; easing.type: Easing.InCubic }
        }
    }

    function _labelFor(action) {
        if (action === "settings") return qsTr("Settings")
        if (action === "logout")   return qsTr("Log out")
        return ""
    }

    function _handleAction(action) {
        root.close()
        if      (action === "settings") root.settingsRequested()
        else if (action === "logout")   AuthManager.requestLogout()
    }

    ListModel {
        id: menuModel
        ListElement { action: "settings"; icon: "" }
        ListElement { action: "logout";   icon: "qrc:/App/assets/icons/logout.svg" }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Repeater {
            model: menuModel
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MenuRow {
                    Layout.fillWidth: true
                    text: root._labelFor(model.action)
                    iconSource: model.icon
                    onClicked: root._handleAction(model.action)
                }
            }
        }
    }

    component MenuRow: Rectangle {
        id: menuRow

        property alias text: label.text
        property string iconSource

        signal clicked()

        implicitHeight: Theme.spacing.s10
        color: hoverHandler.hovered ? Theme.colors.whiteA5 : "transparent"
        radius: Theme.radius.lg

        Behavior on color {
            ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.spacing.s4
                rightMargin: Theme.spacing.s4
            }
            spacing: Theme.spacing.s2

            Image {
                visible: menuRow.iconSource.length > 0
                source: menuRow.iconSource
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: Theme.icons.sizeSm
                Layout.preferredHeight: Theme.icons.sizeSm

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorizationColor: Theme.colors.text
                    colorization: 1.0
                }
            }

            Text {
                id: label
                color: Theme.colors.text
                font.family:    Theme.typography.bodySans25Family
                font.pointSize: Theme.typography.bodySans25Size
                font.weight:    Theme.typography.bodySans25Weight
            }
        }

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: menuRow.clicked()
        }
    }
}
