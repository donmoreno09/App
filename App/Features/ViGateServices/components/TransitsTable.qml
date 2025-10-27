import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

GroupBox {
    id: root
    title: qsTr("Transits")
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property var model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s2
        spacing: Theme.spacing.s2

        // Header Row
        Rectangle {
            Layout.fillWidth: true
            height: Theme.spacing.s10
            color: Theme.colors.surface
            radius: Theme.radius.sm
            z: 2

            Flickable {
                id: headerFlickable
                anchors.fill: parent
                contentWidth: headerRow.width
                clip: true

                // Sync with TableView horizontal scrolling
                Binding {
                    target: tableView
                    property: "contentX"
                    value: headerFlickable.contentX
                    when: tableView
                }

                Row {
                    id: headerRow
                    height: parent.height
                    spacing: 0

                    component HeaderText: Text {
                        required property string headerText
                        required property real headerWidth

                        text: headerText
                        font.family: Theme.typography.familySans
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.text
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        width: headerWidth
                        height: Theme.spacing.s10
                        leftPadding: Theme.spacing.s2
                        rightPadding: Theme.spacing.s2
                    }

                    HeaderText { headerText: qsTr("Gate Name"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Transit ID"); headerWidth: 200 }
                    HeaderText { headerText: qsTr("Start Date"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("End Date"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Status"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Lane Type"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Lane Status"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Lane Name"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Direction"); headerWidth: 100 }

                    // Transit Info columns (for VEHICLE)
                    HeaderText { headerText: qsTr("Color"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Macro Class"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Micro Class"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Make"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Model"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Country"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Kemler"); headerWidth: 80 }

                    // Permission columns
                    HeaderText { headerText: qsTr("Auth"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Auth Message"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Permission Type"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Vehicle Plate"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Person Name"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Company"); headerWidth: 200 }
                }
            }
        }

        // TableView with all columns
        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            reuseItems: true
            model: root.model

            columnWidthProvider: function(column) {
                const widths = [
                    120,  // Gate Name
                    200,  // Transit ID
                    150,  // Start Date
                    150,  // End Date
                    120,  // Status
                    100,  // Lane Type
                    100,  // Lane Status
                    120,  // Lane Name
                    100,  // Direction
                    80,   // Color
                    100,  // Macro Class
                    100,  // Micro Class
                    100,  // Make
                    100,  // Model
                    80,   // Country
                    80,   // Kemler
                    80,   // Auth
                    150,  // Auth Message
                    120,  // Permission Type
                    120,  // Vehicle Plate
                    150,  // Person Name
                    200   // Company
                ];
                return widths[column] || 100;
            }

            rowHeightProvider: function(row) {
                return Theme.spacing.s10
            }

            delegate: Rectangle {
                id: cellDelegate

                required property int row
                required property int column
                required property var model

                implicitWidth: 100
                implicitHeight: Theme.spacing.s10
                color: row % 2 === 0 ? Theme.colors.transparent : Theme.colors.surfaceVariant

                Component.onCompleted: {
                    if (row === 0 && column === 0) {
                        console.log("=== FIRST CELL DEBUG ===")
                        console.log("Model type:", typeof model)
                        console.log("Model is valid:", model !== null && model !== undefined)
                        if (model) {
                            console.log("Model properties:", Object.keys(model))
                            console.log("gateName:", model.gateName)
                            console.log("transitId:", model.transitId)
                            console.log("laneTypeId:", model.laneTypeId)
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s1

                    text: {
                        if (!model) return "-"

                        switch(column) {
                            case 0: return model.gateName || "-"
                            case 1: return model.transitId || "-"
                            case 2: return model.transitStartDate || "-"
                            case 3: return model.transitEndDate || "-"
                            case 4: return model.transitStatus || "-"
                            case 5: return model.laneTypeId || "-"
                            case 6: return model.laneStatusId || "-"
                            case 7: return model.laneName || "-"
                            case 8: return model.transitDirection || "-"

                            // Transit Info (show only for VEHICLE)
                            case 9: return model.hasTransitInfo ? (model.color || "-") : "-"
                            case 10: return model.hasTransitInfo ? (model.macroClass || "-") : "-"
                            case 11: return model.hasTransitInfo ? (model.microClass || "-") : "-"
                            case 12: return model.hasTransitInfo ? (model.make || "-") : "-"
                            case 13: return model.hasTransitInfo ? (model.model || "-") : "-"
                            case 14: return model.hasTransitInfo ? (model.country || "-") : "-"
                            case 15: return model.hasTransitInfo ? (model.kemler || "-") : "-"

                            // Permission
                            case 16: return model.hasPermission ? (model.auth || "-") : "-"
                            case 17: return model.hasPermission ? (model.authMessage || "-") : "-"
                            case 18: return model.hasPermission ? (model.permissionType || "-") : "-"
                            case 19: return model.hasPermission ? (model.vehiclePlate || "-") : "-"
                            case 20: return model.hasPermission ? (model.peopleFullname || "-") : "-"
                            case 21: return model.hasPermission ? (model.companyFullname || "-") : "-"

                            default: return "-"
                        }
                    }

                    color: {
                        if (!model) return Theme.colors.text

                        // Direction column with colors
                        if (column === 8) {
                            return model.transitDirection === "IN" ? Theme.colors.success : Theme.colors.warning
                        }
                        // Status column with colors
                        if (column === 4) {
                            return model.transitStatus === "Autorizzato" ? Theme.colors.success : Theme.colors.error
                        }
                        // Auth column with colors
                        if (column === 16) {
                            return model.auth === "ACCEPT" ? Theme.colors.success : Theme.colors.error
                        }
                        return Theme.colors.text
                    }

                    font.family: Theme.typography.familySans
                    font.weight: (column === 8 || column === 4) ? Theme.typography.weightMedium : Theme.typography.weightRegular
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    leftPadding: Theme.spacing.s2
                    rightPadding: Theme.spacing.s2
                }
            }

            ScrollBar.vertical: ScrollBar {
                width: 12
            }

            ScrollBar.horizontal: ScrollBar {
                height: 12
            }
        }
    }
}
