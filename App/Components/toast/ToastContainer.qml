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

    readonly property int maxVisibleToasts: 3
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

                onCloseRequested: {
                    _removeToast(index)
                }

                onClicked: {
                    // Open notifications panel
                    SidePanelController.open(Routes.Notification)

                    // Auto-expand the accordion for this notification
                    // We'll need to expose a method in NotificationsPanel for this
                    // For now, just open the panel

                    _removeToast(index)
                }

                // Exit animation
                Component.onDestruction: {
                    _processQueue()
                }
            }
        }
    }

    // Listen to TruckNotificationModel
    Connections {
        target: TruckNotificationModel

        function onRowsInserted(parent, first, last) {
            for (let i = first; i <= last; i++) {
                const notification = TruckNotificationModel.getEditableNotification(i)
                if (!notification) continue

                const title = notification.title

                // Access properties directly, not via value()
                _addToast({
                    toastTitle: qsTr("New Notification"),
                    toastMessage: qsTr("From ") + notification.operationCode,
                    toastType: "truck",
                    toastId: notification.id
                })
            }
        }
    }

    // Listen to AlertZoneNotificationModel
    Connections {
        target: AlertZoneNotificationModel

        function onRowsInserted(parent, first, last) {
            for (let i = first; i <= last; i++) {
                const notification = AlertZoneNotificationModel.getEditableNotification(i)
                if (!notification) continue

                // Access properties directly, not via value()
                const title = notification.title

                _addToast({
                    toastTitle: qsTr("New Notification"),
                    toastMessage: qsTr("From ") + (notification.id),
                    toastType: "alertzone",
                    toastId: notification.id
                })
            }
        }
    }

    // Internal functions
    function _addToast(toastData) {
        if (toastsModel.count < maxVisibleToasts) {
            // Add directly to visible toasts (insert at top = index 0)
            toastsModel.insert(0, toastData)
        } else {
            // Queue it
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
