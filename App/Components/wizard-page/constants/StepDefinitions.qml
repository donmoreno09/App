import QtQuick 6.8

QtObject {
    readonly property var steps: ({
        MISSION_OVERVIEW: {
            index: 0,
            title: qsTr("Mission Overview"),
            component: "MissionOverview"
        },
        OPERATIONAL_AREA: {
            index: 1,
            title: qsTr("Operational Area"),
            component: "OperationalArea"
        }
    })

    readonly property var titles: [
        steps.MISSION_OVERVIEW.title,
        steps.OPERATIONAL_AREA.title
    ]

    readonly property int totalSteps: titles.length
}
