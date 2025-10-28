pragma Singleton
import QtQuick 6.8


QtObject {
    id: root

    // Column definitions - single source of truth
    readonly property var columns: [
        {
            key: "gateName",
            header: qsTr("Gate Name"),
            width: 120,
            role: "gateName"
        },
        {
            key: "transitId",
            header: qsTr("Transit ID"),
            width: 200,
            role: "transitId"
        },
        {
            key: "startDate",
            header: qsTr("Start Date"),
            width: 150,
            role: "transitStartDate"
        },
        {
            key: "endDate",
            header: qsTr("End Date"),
            width: 150,
            role: "transitEndDate"
        },
        {
            key: "status",
            header: qsTr("Status"),
            width: 120,
            role: "transitStatus"
        },
        {
            key: "laneType",
            header: qsTr("Lane Type"),
            width: 100,
            role: "laneTypeId"
        },
        {
            key: "laneStatus",
            header: qsTr("Lane Status"),
            width: 100,
            role: "laneStatusId"
        },
        {
            key: "laneName",
            header: qsTr("Lane Name"),
            width: 120,
            role: "laneName"
        },
        {
            key: "direction",
            header: qsTr("Direction"),
            width: 100,
            role: "transitDirection"
        },
        {
            key: "color",
            header: qsTr("Color"),
            width: 80,
            role: "colors",
            conditional: "hasTransitInfo"
        },
        {
            key: "macroClass",
            header: qsTr("Macro Class"),
            width: 100,
            role: "macroClass",
            conditional: "hasTransitInfo"
        },
        {
            key: "microClass",
            header: qsTr("Micro Class"),
            width: 100,
            role: "microClass",
            conditional: "hasTransitInfo"
        },
        {
            key: "make",
            header: qsTr("Make"),
            width: 100,
            role: "make",
            conditional: "hasTransitInfo"
        },
        {
            key: "model",
            header: qsTr("Model"),
            width: 100,
            role: "models",
            conditional: "hasTransitInfo"
        },
        {
            key: "country",
            header: qsTr("Country"),
            width: 80,
            role: "country",
            conditional: "hasTransitInfo"
        },
        {
            key: "kemler",
            header: qsTr("Kemler"),
            width: 80,
            role: "kemler",
            conditional: "hasTransitInfo"
        },
        {
            key: "auth",
            header: qsTr("Auth"),
            width: 80,
            role: "auth",
            conditional: "hasPermission"
        },
        {
            key: "authMessage",
            header: qsTr("Auth Message"),
            width: 150,
            role: "authMessage",
            conditional: "hasPermission"
        },
        {
            key: "permissionType",
            header: qsTr("Permission Type"),
            width: 120,
            role: "permissionType",
            conditional: "hasPermission"
        },
        {
            key: "vehiclePlate",
            header: qsTr("Vehicle Plate"),
            width: 120,
            role: "vehiclePlate",
            conditional: "hasPermission"
        },
        {
            key: "personName",
            header: qsTr("Person Name"),
            width: 150,
            role: "peopleFullname",
            conditional: "hasPermission"
        },
        {
            key: "company",
            header: qsTr("Company"),
            width: 200,
            role: "companyFullname",
            conditional: "hasPermission"
        }
    ]

    // Total width calculation
    readonly property real totalWidth: {
        let sum = 0
        for (let i = 0; i < columns.length; i++) {
            sum += columns[i].width
        }
        return sum
    }

    // Get column by key
    function getColumn(key) {
        for (let i = 0; i < columns.length; i++) {
            if (columns[i].key === key) {
                return columns[i]
            }
        }
        return null
    }

    // Get column width by key
    function getWidth(key) {
        const col = getColumn(key)
        return col ? col.width : 0
    }
}
