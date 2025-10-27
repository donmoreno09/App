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
    property bool showVehicles: true
    property bool showPedestrians: true

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

                    // Helper function for header text
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
                required property int row
                required property int column

                // All properties from model
                required property string gateName
                required property string transitId
                required property string transitStartDate
                required property string transitEndDate
                required property string transitStatus
                required property string laneTypeId
                required property string laneStatusId
                required property string laneName
                required property string transitDirection

                // Transit Info
                required property string color
                required property string macroClass
                required property string microClass
                required property string make
                required property string model
                required property string country
                required property string kemler
                required property bool hasTransitInfo

                // Permission
                required property string auth
                required property string authMessage
                required property string permissionType
                required property string vehiclePlate
                required property string peopleFullname
                required property string companyFullname
                required property bool hasPermission

                implicitWidth: 100
                implicitHeight: Theme.spacing.s10
                color: row % 2 === 0 ? Theme.colors.transparent : Theme.colors.surfaceVariant

                // Filter based on lane type
                visible: {
                    if (laneTypeId === "VEHICLE" && !root.showVehicles) return false
                    if (laneTypeId === "WALK" && !root.showPedestrians) return false
                    return true
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s1

                    text: {
                        switch(column) {
                            case 0: return gateName || "-"
                            case 1: return transitId || "-"
                            case 2: return transitStartDate || "-"
                            case 3: return transitEndDate || "-"
                            case 4: return transitStatus || "-"
                            case 5: return laneTypeId || "-"
                            case 6: return laneStatusId || "-"
                            case 7: return laneName || "-"
                            case 8: return transitDirection || "-"

                            // Transit Info (show only for VEHICLE)
                            case 9: return hasTransitInfo ? (color || "-") : "-"
                            case 10: return hasTransitInfo ? (macroClass || "-") : "-"
                            case 11: return hasTransitInfo ? (microClass || "-") : "-"
                            case 12: return hasTransitInfo ? (make || "-") : "-"
                            case 13: return hasTransitInfo ? (model || "-") : "-"
                            case 14: return hasTransitInfo ? (country || "-") : "-"
                            case 15: return hasTransitInfo ? (kemler || "-") : "-"

                            // Permission
                            case 16: return hasPermission ? (auth || "-") : "-"
                            case 17: return hasPermission ? (authMessage || "-") : "-"
                            case 18: return hasPermission ? (permissionType || "-") : "-"
                            case 19: return hasPermission ? (vehiclePlate || "-") : "-"
                            case 20: return hasPermission ? (peopleFullname || "-") : "-"
                            case 21: return hasPermission ? (companyFullname || "-") : "-"

                            default: return "-"
                        }
                    }

                    color: {
                        // Direction column with colors
                        if (column === 8) {
                            return transitDirection === "IN" ? Theme.colors.success : Theme.colors.warning
                        }
                        // Status column with colors
                        if (column === 4) {
                            return transitStatus === "Autorizzato" ? Theme.colors.success : Theme.colors.error
                        }
                        // Auth column with colors
                        if (column === 16) {
                            return auth === "ACCEPT" ? Theme.colors.success : Theme.colors.error
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

                TableView.onPooled: {
                    // Cleanup when pooled
                }

                TableView.onReused: {
                    // Reset state when reused
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
