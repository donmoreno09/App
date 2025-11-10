import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Rectangle {
    id: root

    color: Theme.colors.surface
    radius: Theme.radius.sm
    z: 2

    onWidthChanged: {
            console.log("TableHeader width:", width)
        }

    required property var columns
    required property real contentX

    Flickable {
        id: headerFlickable
        anchors.fill: parent
        contentWidth: headerRow.implicitWidth
        contentX: root.contentX
        clip: true
        interactive: false // Controlled by ListView

        RowLayout {
            id: headerRow
            height: parent.height
            spacing: 0

            Repeater {
                model: root.columns

                delegate: Text {
                    required property var modelData

                    text: modelData.header
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: modelData.width
                    Layout.preferredHeight: Theme.spacing.s10
                    leftPadding: Theme.spacing.s2
                    rightPadding: Theme.spacing.s2
                }
            }
        }
    }
}
