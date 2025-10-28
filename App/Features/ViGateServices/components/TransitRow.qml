import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

Item {
    id: root

    required property var columns
    required property int index

    // Required properties from model
    required property string gateName
    required property string transitId
    required property string transitStartDate
    required property string transitEndDate
    required property string transitStatus
    required property string laneTypeId
    required property string laneStatusId
    required property string laneName
    required property string transitDirection
    required property string colors
    required property string macroClass
    required property string microClass
    required property string make
    required property string models
    required property string country
    required property string kemler
    required property bool hasTransitInfo
    required property string auth
    required property string authMessage
    required property string permissionType
    required property string vehiclePlate
    required property string peopleFullname
    required property string companyFullname
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
                return value === "ACCEPT" ? Theme.colors.success : Theme.colors.error
            default:
                return Theme.colors.text
        }
    }

    // Helper function to get font weight
    function getCellFontWeight(column) {
        switch(column.key) {
            case "status":
            case "direction":
                return Theme.typography.weightMedium
            default:
                return Theme.typography.weightLight
        }
    }
}
