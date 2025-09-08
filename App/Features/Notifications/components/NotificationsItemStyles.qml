pragma Singleton

import QtQuick 6.8

import App.Themes 1.0

QtObject {
    enum Variant { Info, Warning, Urgent }

    property NotificationsItemStyle _info: NotificationsItemStyle {
        background: "#0D27F2"
        backgroundHover: Qt.darker(background, 1.1)
        backgroundPressed: Qt.darker(background, 1.2)
        backgroundDisabled: "#0F1115"
        backgroundActive: Qt.darker(background, 1.1)
        textColor: "#FFFFFF"
        textColorDisabled: "#A3A9B5"
    }

    property NotificationsItemStyle _warning: NotificationsItemStyle {
        background: "#FFCF26"
        backgroundHover: Qt.darker(background, 1.1)
        backgroundPressed: Qt.darker(background, 1.2)
        backgroundDisabled: "#0F1115"
        backgroundActive: Qt.darker(background, 1.1)
        textColor: "#000000"
        textColorDisabled: "#A3A9B5"
    }

    property NotificationsItemStyle _urgent: NotificationsItemStyle {
        background: "#E33A3A"
        backgroundHover: Qt.darker(background, 1.1)
        backgroundPressed: Qt.darker(background, 1.2)
        backgroundDisabled: "#0F1115"
        backgroundActive: Qt.darker(background, 1.1)
        textColor: "#FFFFFF"
        textColorDisabled: "#A3A9B5"
    }

    function fromVariant(variant) : NotificationsItemStyle {
        switch (variant) {
        case NotificationsItemStyles.Info: return _info
        case NotificationsItemStyles.Warning: return _warning
        case NotificationsItemStyles.Urgent: return _urgent
        default: {
            console.warn("Invalid NotificationsItemStyle: ", variant)
            return _info
        }
        }
    }
}
