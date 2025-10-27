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

            // Header Row
            Text {
                text: ""
                color: Theme.colors.textMuted
            }
            Text {
                text: qsTr("Entries")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.success
                horizontalAlignment: Text.AlignCenter
                Layout.fillWidth: true
            }
            Text {
                text: qsTr("Exits")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.warning
                horizontalAlignment: Text.AlignCenter
                Layout.fillWidth: true
            }

            // Vehicles Row
            Text {
                text: qsTr("Vehicles")
                color: Theme.colors.textMuted
                font.family: Theme.typography.familySans
            }
            Text {
                text: controller.totalVehicleEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
                font.family: Theme.typography.familySans
                Layout.fillWidth: true
            }
            Text {
                text: controller.totalVehicleExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
                font.family: Theme.typography.familySans
                Layout.fillWidth: true
            }

            // Pedestrians Row
            Text {
                text: qsTr("Pedestrians")
                color: Theme.colors.textMuted
                font.family: Theme.typography.familySans
            }
            Text {
                text: controller.totalPedestrianEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
                font.family: Theme.typography.familySans
                Layout.fillWidth: true
            }
            Text {
                text: controller.totalPedestrianExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
                font.family: Theme.typography.familySans
                Layout.fillWidth: true
            }

            // Divider
            UI.HorizontalDivider {
                Layout.columnSpan: 3
                color: Theme.colors.white
            }

            // Total Row
            Text {
                text: qsTr("Total")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
                font.family: Theme.typography.familySans
            }
            Text {
                text: controller.totalEntries
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.success
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.bodySans25Size * 1.2
                Layout.fillWidth: true
            }
            Text {
                text: controller.totalExits
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.warning
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.bodySans25Size * 1.2
                Layout.fillWidth: true
            }
        }
    }
}
