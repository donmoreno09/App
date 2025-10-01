import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

// Refactored to match OLD design exactly
Row {
    id: root
    spacing: 10

    property string icon: ""
    property string title: ""
    property string value: ""
    property bool isLoading: false

    // OLD DESIGN COLORS (from SidePannelStatCard.qml)
    readonly property color cardBackgroundColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property color borderColor: Theme.colors.secondary500
    readonly property color secondaryTextColor: Theme.colors.whiteA60
    readonly property color textColor: Theme.colors.white500

    // Icon container - EXACTLY like old design
    Rectangle {
        width: 50
        height: 50
        radius: Theme.radius.md
        color: root.cardBackgroundColor
        border.color: root.borderColor
        border.width: Theme.borders.b1

        Text {
            text: root.icon
            font.pixelSize: 24
            anchors.centerIn: parent
            color: root.textColor
        }
    }

    // Text content - EXACTLY like old design
    Column {
        spacing: 2
        width: root.width - 60

        Text {
            text: root.title
            font.pixelSize: Theme.typography.fontSize175
            font.family: Theme.typography.familySans
            color: root.secondaryTextColor
            font.weight: Theme.typography.weightMedium
        }

        Text {
            text: root.isLoading ? "..." : root.value
            font.pixelSize: Theme.typography.fontSize200
            font.family: Theme.typography.familySans
            font.weight: Theme.typography.weightBold
            color: root.textColor
        }
    }
}
