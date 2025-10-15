import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

GroupBox {
    title: qsTr("Summary")
    Layout.fillWidth: true

    required property var controller

    GridLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s3
        columns: 2
        rowSpacing: Theme.spacing.s2
        columnSpacing: Theme.spacing.s4

        // Total Entries
        Text {
            text: qsTr("Total Entries")
            font.family: Theme.typography.familySans
            color: Theme.colors.textMuted
        }
        Text {
            text: controller.totalEntries
            font.family: Theme.typography.familySans
            font.weight: Theme.typography.weightSemibold
            color: Theme.colors.text
        }

        // Total Exits
        Text {
            text: qsTr("Total Exits")
            font.family: Theme.typography.familySans
            color: Theme.colors.textMuted
        }
        Text {
            text: controller.totalExits
            font.family: Theme.typography.familySans
            font.weight: Theme.typography.weightSemibold
            color: Theme.colors.text
        }

        // Vehicle Entries
        Text {
            text: qsTr("Vehicle Entries")
            font.family: Theme.typography.familySans
            color: Theme.colors.textMuted
        }
        Text {
            text: controller.totalVehicleEntries
            font.family: Theme.typography.familySans
            font.weight: Theme.typography.weightSemibold
            color: Theme.colors.text
        }

        // Vehicle Exits
        Text {
            text: qsTr("Vehicle Exits")
            font.family: Theme.typography.familySans
            color: Theme.colors.textMuted
        }
        Text {
            text: controller.totalVehicleExits
            font.family: Theme.typography.familySans
            font.weight: Theme.typography.weightSemibold
            color: Theme.colors.text
        }

        // Pedestrian Entries
        Text {
            text: qsTr("Pedestrian Entries")
            font.family: Theme.typography.familySans
            color: Theme.colors.textMuted
                    }
                    Text {
                        text: controller.totalPedestrianEntries
                        font.family: Theme.typography.familySans
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.text
                    }

                    // Pedestrian Exits
                    Text {
                        text: qsTr("Pedestrian Exits")
                        font.family: Theme.typography.familySans
                        color: Theme.colors.textMuted
                    }
                    Text {
                        text: controller.totalPedestrianExits
                        font.family: Theme.typography.familySans
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.text
                    }
                }
            }
