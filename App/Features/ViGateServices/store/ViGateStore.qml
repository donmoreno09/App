pragma Singleton
import QtQuick 6.8

QtObject {
    readonly property int totalEntries: 42
    readonly property int totalExits: 39
    readonly property int totalVehicleEntries: 20
    readonly property int totalVehicleExits: 18
    readonly property int totalPedestrianEntries: 22
    readonly property int totalPedestrianExits: 21

    readonly property var vehicles: [
        { startDate: "2025-09-06T00:01:30Z", plate: "EF162WW", direction: "IN"  },
        { startDate: "2025-09-06T01:00:00Z", plate: "AB123CD", direction: "OUT" },
        { startDate: "2025-09-06T05:22:48Z", plate: "ZY987ZX", direction: "IN"  }
    ]

    readonly property var pedestrians: [
        { startDate: "2025-09-06T00:02:00Z", direction: "IN"  },
        { startDate: "2025-09-06T01:30:00Z", direction: "OUT" },
        { startDate: "2025-09-06T15:10:11Z", direction: "IN"  }
    ]
}
