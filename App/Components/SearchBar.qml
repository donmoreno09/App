import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

Rectangle {
    id: root

    property alias textField: textField

    readonly property bool visualFocus: textField.activeFocus && (textField.focusReason === Qt.TabFocusReason || textField.focusReason === Qt.BacktabFocusReason)

    radius: Theme.radius.sm
    color: Theme.colors.glassWhite

    // Let the whole search bar be clickable to focus the text field
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        onPressed: function (mouse) {
            textField.forceActiveFocus(Qt.MouseFocusReason)
            mouse.accepted = false // let the text field also handle the click
        }
    }

    // Outline
    Rectangle {
        visible: visualFocus
        anchors.fill: parent
        anchors.margins: -Theme.borders.offset2
        color: Theme.colors.transparent
        radius: root.radius + Theme.borders.outline2
        border.width: Theme.borders.outline2
        border.color: Qt.lighter(Theme.colors.textMuted, 1.6)
    }

    // Content
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.s3
        anchors.rightMargin: Theme.spacing.s3
        spacing: Theme.spacing.s3

        Image {
            Layout.preferredWidth: Theme.icons.sizeXs
            source: "qrc:/App/assets/icons/magnifying-glass.svg"
        }

        TextField {
            id: textField
            Layout.fillWidth: true
            color: Theme.colors.text
            background: Rectangle { color: "transparent" }

            Accessible.name: placeholderText
            Accessible.role: Accessible.EditableText
        }
    }
}
