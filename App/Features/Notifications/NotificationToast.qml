import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Notifications 1.0
import App.Features.SidePanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

Item {
    id: container
    anchors.fill: parent

    property Item mapReference: null

    readonly property int maxVisibleToasts: 3
    readonly property int maxQueuedToasts: 3
    property var toastQueue: []

    // ListModel declared separately so we can manipulate it
    ListModel {
        id: toastsModel
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

            if (!TruckNotificationModel.initialLoadComplete) { return }

            const batchSize = last - first + 1
            const startIndex = batchSize > maxVisibleToasts ? last - maxVisibleToasts + 1 : first

            for (let i = startIndex; i <= last; i++) {
                const notification = TruckNotificationModel.getEditableNotification(i)
                if (!notification) continue

                _addToast({
                    toastTitle: qsTr("New Notification"),
                    toastMessage: qsTr("From ") + notification.operationCode,
                    toastType: "truck",
                    toastId: notification.id
                })
            }
        }
    }

    Connections {
        target: AlertZoneNotificationModel

        function onRowsInserted(parent, first, last) {

            if (!AlertZoneNotificationModel.initialLoadComplete) { return }

            const batchSize = last - first + 1
            const startIndex = batchSize > maxVisibleToasts ? last - maxVisibleToasts + 1 : first

            for (let i = startIndex; i <= last; i++) {
                const notification = AlertZoneNotificationModel.getEditableNotification(i)
                if (!notification) continue

                _addToast({
                    toastTitle: qsTr("New Notification"),
                    toastMessage: qsTr("From ") + (notification.trackData?.trackingId ?? ""),
                    toastType: "alertzone",
                    toastId: notification.id
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
