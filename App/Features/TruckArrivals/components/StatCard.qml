import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

RowLayout {
    id: root
    spacing: 10
    Layout.fillWidth: true

    property string icon: ""
    property string title: ""
    property string value: ""

    Rectangle {
        Layout.preferredWidth: 50
        Layout.preferredHeight: 50
        Layout.alignment: Qt.AlignVCenter
        Layout.margins: Theme.spacing.s2
        radius: 8
        color: Theme.colors.glassWhite
        border.color: Theme.colors.border
        border.width: Theme.borders.b1

        Image {
            source: root.icon
            anchors.centerIn: parent
            width: Theme.spacing.s7
            height: Theme.spacing.s7
            fillMode: Image.PreserveAspectFit
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
            text: root.title
            font.pixelSize: 14
            font.weight: Font.Medium
            color: Theme.colors.textMuted
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
        }

        Text {
            text: root.value
            font.pixelSize: 18
            font.bold: true
            color: Theme.colors.white
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
        }
    }
}
