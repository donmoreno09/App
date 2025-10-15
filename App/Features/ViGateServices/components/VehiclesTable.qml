import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

GroupBox {
    id: root
    title: qsTr("Vehicles")
    Layout.fillWidth: true

    required property var model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s2
        spacing: Theme.spacing.s2

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: Theme.spacing.s8
            color: Theme.colors.surface
            radius: Theme.radius.sm

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s2
                spacing: 0

                Text {
                    width: 160
                    text: qsTr("Start Date")
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    width: 120
                    text: qsTr("Plate")
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    width: parent.width - 280 // remaining space
                    text: qsTr("Direction")
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // TableView
        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            clip: true

            model: root.model

            columnSpacing: 0
            rowSpacing: Theme.spacing.s0_5

            // Column widths
            columnWidthProvider: function(column) {
                switch(column) {
                    case 0: return 160  // Start Date
                    case 1: return 120  // Plate
                    case 2: return tableView.width - 280  // Direction (fill remaining)
                    default: return 100
                }
            }

            rowHeightProvider: function(row) {
                return Theme.spacing.s8
            }

            delegate: Rectangle {
                required property int row
                required property int column
                required property var model

                implicitWidth: tableView.columnWidthProvider(column)
                implicitHeight: Theme.spacing.s8

                color: row % 2 === 0 ? Theme.colors.surface : Theme.colors.transparent
                radius: Theme.radius.xs

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.s2
                    verticalAlignment: Text.AlignVCenter

                    text: {
                        switch(column) {
                            case 0: return model.startDate || "-"
                            case 1: return model.plate || "-"
                            case 2: return model.direction || "-"
                            default: return ""
                        }
                    }

                    font.family: Theme.typography.familySans
                    color: column === 2
                        ? (model.direction === "IN" ? Theme.colors.success : Theme.colors.warning)
                        : Theme.colors.text
                    font.weight: column === 2
                        ? Theme.typography.weightMedium
                        : Theme.typography.weightRegular
                    elide: Text.ElideRight
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
