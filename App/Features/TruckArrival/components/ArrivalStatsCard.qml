import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string value: ""
    property bool isLoading: false

    implicitWidth: 280
    implicitHeight: 80

    color: Theme.colors.primary700
    radius: Theme.radius.md
    border.width: Theme.borders.b1
    border.color: Theme.colors.secondary500

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s4

        // Icon
        Text {
            text: root.icon
            font.pixelSize: Theme.typography.fontSize400
            Layout.alignment: Qt.AlignVCenter
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s2

            Text {
                text: root.title
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                font.weight: Theme.typography.weightMedium
                color: Theme.colors.textMuted
            }

            Text {
                text: root.loading ? "..." : root.value
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize250
                font.weight: Theme.typography.weightBold
                color: Theme.colors.text
            }
        }
    }
}
