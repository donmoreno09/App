import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

UI.Button {
    id: root

    Layout.fillWidth: true

    property alias source: image.source

    variant: UI.ButtonStyles.Ghost

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.s4
        anchors.rightMargin: Theme.spacing.s4
        spacing: Theme.spacing.s4
        Layout.alignment: Qt.AlignLeft

        Image {
            id: image
            width: Theme.icons.sizeLg
            fillMode: Image.PreserveAspectFit
            visible: root.icon.source !== ""
        }

        Label {
            Layout.fillWidth: true
            text: root.text
            elide: Text.ElideRight
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
    }

    backgroundRect.border.width: Theme.borders.b0
}
