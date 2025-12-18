import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

GroupBox {
    id: root
    title: `${TranslationManager.revision}` && qsTr("Summary")
    Layout.fillWidth: true
    Layout.maximumWidth: parent.width

    required property var controller

    readonly property bool hasVehicleData: controller.totalVehicleEntries > 0 || controller.totalVehicleExits > 0
    readonly property bool hasPedestrianData: controller.totalPedestrianEntries > 0 || controller.totalPedestrianExits > 0
    readonly property bool hasAnyData: hasVehicleData || hasPedestrianData

    visible: hasAnyData

    contentItem: ScrollView {
        clip: true

        GridLayout {
            width: parent.parent.width
            columns: 3
            rowSpacing: Theme.spacing.s3
            columnSpacing: Theme.spacing.s4

            Text {
                text: ""
                color: Theme.colors.textMuted
            }
            Text {
                text: `${TranslationManager.revision}` && qsTr("Entries")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.success
                horizontalAlignment: Text.AlignCenter
            }
            Text {
                text: `${TranslationManager.revision}` && qsTr("Exits")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.warning
                horizontalAlignment: Text.AlignCenter
            }

            Text {
                visible: root.hasVehicleData
                text: `${TranslationManager.revision}` && qsTr("Vehicles")
                color: Theme.colors.textMuted
            }
            Text {
                visible: root.hasVehicleData
                text: controller.totalVehicleEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }
            Text {
                visible: root.hasVehicleData
                text: controller.totalVehicleExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }

            Text {
                visible: root.hasPedestrianData
                text: `${TranslationManager.revision}` && qsTr("Pedestrians")
                color: Theme.colors.textMuted
            }
            Text {
                visible: root.hasPedestrianData
                text: controller.totalPedestrianEntries
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }
            Text {
                visible: root.hasPedestrianData
                text: controller.totalPedestrianExits
                color: Theme.colors.white
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightSemibold
            }

            // Divider
            UI.HorizontalDivider {
                visible: root.hasVehicleData && root.hasPedestrianData
                Layout.columnSpan: 3
                Layout.fillWidth: true
                color: Theme.colors.whiteA10
            }

            // Total row
            Text {
                visible: root.hasVehicleData && root.hasPedestrianData
                text: `${TranslationManager.revision}` && qsTr("Total")
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text
            }
            Text {
                visible: root.hasVehicleData && root.hasPedestrianData
                text: controller.totalEntries
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.success
            }
            Text {
                visible: root.hasVehicleData && root.hasPedestrianData
                text: controller.totalExits
                horizontalAlignment: Text.AlignCenter
                font.weight: Theme.typography.weightBold
                color: Theme.colors.warning
            }
        }
    }
}
