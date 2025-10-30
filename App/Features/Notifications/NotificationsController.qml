pragma Singleton

import QtQuick 6.8
import App 1.0

QtObject {
    id: root

    // Direct access to the singleton C++ model
    readonly property var model: TruckNotificationModel

    // Convenience computed properties for badge counts
    readonly property int totalCount: model ? model.rowCount() : 0
    readonly property int urgentCount: model ? model.countByState("BLOCKED") : 0
    readonly property int warningCount: model ? model.countByState("WARNING") : 0
    readonly property int infoCount: model ? model.countByState("ACTIVE") : 0

    // Actions
    function removeNotification(id) {
        if (model) {
            model.removeNotification(id)
        }
    }

    function clearAll() {
        if (model) {
            model.clearAll()
        }
    }
}
