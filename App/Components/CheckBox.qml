import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

CheckBox {
    id: root

    property string size: "md"

    readonly property var _sizeConfig: ({
        "sm": { indicator: 14, fontSize: Theme.typography.bodySans15Size, spacing: Theme.spacing.s1 },
        "md": { indicator: 16, fontSize: Theme.typography.bodySans25Size, spacing: Theme.spacing.s2 },
        "lg": { indicator: 20, fontSize: Theme.typography.bodySans50Size, spacing: Theme.spacing.s3 }
    })

    readonly property var _size: _sizeConfig[size] || _sizeConfig["md"]

    spacing: _size.spacing

    indicator: Rectangle {
        implicitWidth:  root._size.indicator
        implicitHeight: root._size.indicator
        anchors.verticalCenter: parent.verticalCenter
        radius:         Theme.radius.xs
        color:          root.checked ? Theme.colors.accent500 : Theme.colors.transparent
        border.color:   root.checked
                        ? Theme.colors.accent
                        : root.enabled ? Qt.rgba(1, 1, 1, 0.45) : Theme.colors.textMuted
        border.width:   Theme.borders.b1

        Behavior on color       { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            visible:        root.checked
            text:           "\u2713"
            color:          Theme.colors.text
            font.family:    Theme.typography.familySans
            font.pixelSize: Math.round(root._size.indicator * 0.65)
            font.weight:    Theme.typography.weightMedium
        }
    }

    contentItem: Text {
        leftPadding:    root.indicator.implicitWidth + root.spacing
        text:           root.text
        color:          root.enabled ? Theme.colors.text : Theme.colors.textMuted
        font.family:    Theme.typography.familySans
        font.pointSize: root._size.fontSize
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
