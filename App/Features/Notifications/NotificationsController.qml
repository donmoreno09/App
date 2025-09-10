pragma Singleton

import QtQuick 6.8

import "internals"

QtObject {
    readonly property NotificationsChannel info: NotificationsChannel { }
    readonly property NotificationsChannel warning: NotificationsChannel { }
    readonly property NotificationsChannel urgent: NotificationsChannel { }
}
