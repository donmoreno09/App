import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Item {
    id: root

    required property var columns
    required property int index

    // Required properties from model - Basic
    required property string gateName
    required property string transitId
    required property string transitStartDate
    required property string transitEndDate
    required property string transitStatus
    required property string laneTypeId
    required property string laneStatusId
    required property string laneName
    required property string transitDirection

    // Transit Info properties
    required property string colors
    required property string macroClass
    required property string microClass
    required property string make
    required property string models
    required property string country
    required property string kemler
    required property bool hasTransitInfo

    // Permission properties - ALL FIELDS
    required property string uidCode
    required property string auth
    required property string authCode
    required property string authMessage
    required property int permissionId
    required property string permissionType
    required property string ownerType
    required property int vehicleId
    required property string vehiclePlate
    required property int peopleId
    required property string peopleFullname
    required property string peopleBirthdayDate
    required property string peopleBirthdayPlace
    required property int companyId
    required property string companyFullname
    required property string companyCity
    required property string companyType
    required property bool hasPermission

    width: contentRow.implicitWidth
    height: Theme.spacing.s10

    Rectangle {
        anchors.fill: parent
        color: index % 2 === 0 ? Theme.colors.transparent : Theme.colors.surface
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.columns

            delegate: Text {
                required property var modelData

                text: getCellText(modelData)
                color: getCellColor(modelData)
                font.family: Theme.typography.familySans
                font.weight: getCellFontWeight(modelData)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.preferredWidth: modelData.width
                Layout.preferredHeight: Theme.spacing.s10
                leftPadding: Theme.spacing.s2
                rightPadding: Theme.spacing.s2
            }
        }
    }

    // Helper function to get cell text
    function getCellText(column) {
        // Check conditional display
        if (column.conditional === "hasTransitInfo" && !hasTransitInfo) {
            return "-"
        }
        if (column.conditional === "hasPermission" && !hasPermission) {
            return "-"
        }

        // Get the value from the property
        const value = root[column.role]

        // Handle numeric fields (IDs) - show them even if 0
        if (column.role === "permissionId" ||
            column.role === "vehicleId" ||
            column.role === "peopleId" ||
            column.role === "companyId") {
            return value !== undefined ? value.toString() : "-"
        }

        // Handle string fields
        return value || "-"
    }

    // Helper function to get cell color
    function getCellColor(column) {
        const value = root[column.role]

        switch(column.key) {
            case "status":
                return value === "Autorizzato" ? Theme.colors.success : Theme.colors.error
            case "direction":
                return value === "IN" ? Theme.colors.success : Theme.colors.warning
            case "auth":
                return value === "ALLOW" ? Theme.colors.success : Theme.colors.error
            default:
                return Theme.colors.text
        }
    }

    // Helper function to get font weight
    function getCellFontWeight(column) {
        switch(column.key) {
            case "status":
            case "direction":
            case "auth":
                return Theme.typography.weightMedium
            default:
                return Theme.typography.weightLight
        }
    }
}
