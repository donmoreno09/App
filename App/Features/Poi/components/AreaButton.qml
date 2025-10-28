import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

RadioButton {
    id: root

    Layout.preferredWidth: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 72
    indicator: null

    property alias source: image.source

    opacity: enabled ? Theme.opacity.o100 : Theme.opacity.o50

    contentItem: ColumnLayout {
        spacing: Theme.spacing.s2

        UI.VerticalSpacer { }

        Image {
            id: image
            width: 32
            height: 32
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: label
            text: root.text
            Layout.alignment: Qt.AlignHCenter
            color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
        }

        UI.VerticalSpacer { }
    }

    background: Rectangle {
        radius: Theme.radius.md
        color: root.checked ? Theme.colors.accent350 : Theme.colors.transparent
        opacity: root.enabled ? Theme.opacity.o100 : Theme.opacity.o50
    }
}
