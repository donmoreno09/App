import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0
import App.Components 1.0 as UI

GroupBox {
    title: qsTr("Summary")
    Layout.fillWidth: true
    required property var controller

    contentItem: ScrollView {
        clip: true

        GridLayout {
            width: parent.parent.width
            columns: 3
            rowSpacing: Theme.spacing.s3
            columnSpacing: Theme.spacing.s4

            Text { text: ""; color: Theme.colors.textMuted }
            Text {
                text: qsTr("Entries")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.success
                horizontalAlignment: Text.AlignCenter
            }
            Text {
                text: qsTr("Exits")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.warning
                horizontalAlignment: Text.AlignCenter
            }

            Text { text: qsTr("Vehicles"); color: Theme.colors.textMuted }
            Text {
                text: controller.totalVehicleEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }
            Text {
                text: controller.totalVehicleExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }

            Text { text: qsTr("Pedestrians"); color: Theme.colors.textMuted }
            Text {
                text: controller.totalPedestrianEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }
            Text {
                text: controller.totalPedestrianExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }

            UI.HorizontalDivider { Layout.columnSpan: 3; color: Theme.colors.white}

            Text {
                text: qsTr("Total")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }
            Text {
                text: controller.totalEntries
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.success
            }
            Text {
                text: controller.totalExits
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.warning
            }
        }
    }
}
