import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

Rectangle {
    id: root

    property alias textField: textField

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

    OutlineRect { target: textField }

    // Content
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.s3
        anchors.rightMargin: Theme.spacing.s3
        spacing: Theme.spacing.s1

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
