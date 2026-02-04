import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Notifications 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

Item {
    id: container
    anchors.fill: parent

    property Item mapReference: null

    readonly property int maxVisibleToasts: 3
    readonly property int maxQueuedToasts: 3
    readonly property int debounceMs: 500
    readonly property int aggregationThreshold: 3

    property var toastQueue: []

    // Debounce buffers for collecting notifications
    property var _pendingAlertZone: []
    property var _pendingTruck: []

    // ListModel declared separately so we can manipulate it
    ListModel {
        id: toastsModel
    }

    // Debounce timer - fires after collecting notifications
    Timer {
        id: debounceTimer
        interval: container.debounceMs
        repeat: false
        onTriggered: _flushPendingNotifications()
    }

    // Stack positioning (bottom-right)
    Column {
        id: toastStack
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s4
        spacing: Theme.spacing.s3

        Repeater {
            model: toastsModel

            delegate: UI.ToastNotification {
                title: model.toastTitle
                message: model.toastMessage
                notificationType: model.toastType
                notificationId: model.toastId

                mapSource: container.mapReference

                onCloseRequested: {
                    _removeToast(index)
                }

                onClicked: {
                    SidePanelController.open(Routes.Notification)
                    _removeToast(index)
                }

                Component.onDestruction: {
                    _processQueue()
                }
            }
        }
    }

    Connections {
        target: TruckNotificationModel

        function onRowsInserted(parent, first, last) {
            if (!TruckNotificationModel.initialLoadComplete) return

            // Collect notifications into pending buffer
            for (let i = first; i <= last; i++) {
                const notification = TruckNotificationModel.getEditableNotification(i)
                if (!notification) continue

                container._pendingTruck.push({
                    operationCode: notification.operationCode ?? "",
                    id: notification.id ?? ""
                })
            }

            // Restart debounce timer
            debounceTimer.restart()
        }
    }

    Connections {
        target: AlertZoneNotificationModel

        function onRowsInserted(parent, first, last) {
            if (!AlertZoneNotificationModel.initialLoadComplete) return

            // Collect notifications into pending buffer
            for (let i = first; i <= last; i++) {
                const notification = AlertZoneNotificationModel.getEditableNotification(i)
                if (!notification) continue

                container._pendingAlertZone.push({
                    trackingId: notification.trackData?.trackingId ?? "",
                    label: notification.alertZone?.label ?? "",
                    id: notification.id ?? ""
                })
            }

            // Restart debounce timer
            debounceTimer.restart()
        }
    }

    // Process all pending notifications after debounce window closes
    function _flushPendingNotifications() {
        const alertZoneCount = _pendingAlertZone.length
        const truckCount = _pendingTruck.length
        const totalCount = alertZoneCount + truckCount

        // No pending notifications
        if (totalCount === 0) return

        // Decide display strategy based on counts
        if (totalCount <= aggregationThreshold) {
            // Show individual toasts (up to 3 total)
            _showIndividualToasts()
        } else {
            // Show aggregated toasts by type
            _showAggregatedToasts(alertZoneCount, truckCount)
        }

        // Clear pending buffers
        _pendingAlertZone = []
        _pendingTruck = []
    }

    // Show individual toasts for small batches
    function _showIndividualToasts() {
        // Show AlertZone toasts first (higher priority)
        for (let i = 0; i < _pendingAlertZone.length; i++) {
            let notif = _pendingAlertZone[i]
            _addToast({
                toastTitle: `${TranslationManager.revision}` && qsTr("Alert Zone Intrusion"),
                toastMessage: `${TranslationManager.revision}` && qsTr("From %1").arg(notif.trackingId),
                toastType: "alertzone",
                toastId: notif.id
            })
        }

        // Then Truck toasts
        for (let j = 0; j < _pendingTruck.length; j++) {
            let notif = _pendingTruck[j]
            _addToast({
                toastTitle: `${TranslationManager.revision}` && qsTr("Truck Notification"),
                toastMessage: `${TranslationManager.revision}` && qsTr("From %1").arg(notif.operationCode),
                toastType: "truck",
                toastId: notif.id
            })
        }
    }

    // Show aggregated toasts for large batches
    function _showAggregatedToasts(alertZoneCount, truckCount) {
        // Aggregated AlertZone toast
        if (alertZoneCount > 0) {
            if (alertZoneCount === 1) {
                // Single notification - show details
                const notif = _pendingAlertZone[0]
                _addToast({
                    toastTitle: `${TranslationManager.revision}` && qsTr("Alert Zone Intrusion"),
                    toastMessage: notif.label || notif.trackingId,
                    toastType: "alertzone",
                    toastId: notif.id
                })
            } else {
                // Multiple - aggregate
                _addToast({
                    toastTitle: `${TranslationManager.revision}` && qsTr("Alert Zone Intrusions"),
                    toastMessage: `${TranslationManager.revision}` && qsTr("%1 new intrusions detected ").arg(alertZoneCount),
                    toastType: "alertzone",
                    toastId: "aggregate-alertzone"
                })
            }
        }

        // Aggregated Truck toast
        if (truckCount > 0) {
            if (truckCount === 1) {
                // Single notification - show details
                const notif = _pendingTruck[0]
                _addToast({
                    toastTitle: `${TranslationManager.revision}` && qsTr("Truck Notification"),
                    toastMessage: `${TranslationManager.revision}` && qsTr("From %1").arg(notif.operationCode),
                    toastType: "truck",
                    toastId: notif.id
                })
            } else {
                // Multiple - aggregate
                _addToast({
                    toastTitle: `${TranslationManager.revision}` && qsTr("Truck Notifications"),
                    toastMessage: `${TranslationManager.revision}` && qsTr("%1 new notifications ").arg(truckCount),
                    toastType: "truck",
                    toastId: "aggregate-truck"
                })
            }
        }
    }

    function _addToast(toastData) {
        if (toastsModel.count < maxVisibleToasts) {
            toastsModel.insert(0, toastData)
        } else {
            if (toastQueue.length >= maxQueuedToasts) {
                toastQueue.shift()
            }
            toastQueue.push(toastData)
        }
    }

    function _removeToast(index) {
        if (index >= 0 && index < toastsModel.count) {
            toastsModel.remove(index)
        }
    }

    function _processQueue() {
        if (toastQueue.length > 0 && toastsModel.count < maxVisibleToasts) {
            const nextToast = toastQueue.shift()
            toastsModel.insert(0, nextToast)
        }
    }
}
