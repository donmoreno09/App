import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

CheckBox {
    id: root

    property string size: "md"

    readonly property var _sizeConfig: ({
        "sm": { indicator: 12, fontSize: Theme.typography.bodySans15Size},
        "md": { indicator: 14, fontSize: Theme.typography.bodySans25Size},
        "lg": { indicator: 16, fontSize: Theme.typography.bodySans50Size}
    })

    readonly property var _size: _sizeConfig[size] || _sizeConfig["md"]

    spacing: _size.spacing

    indicator: Rectangle {
        implicitWidth:  root._size.indicator
        implicitHeight: root._size.indicator
        anchors.verticalCenter: parent.verticalCenter
        radius:         Theme.radius.sm
        color:          root.checked ? Theme.colors.accent500 : Theme.colors.transparent
        border.color:   root.checked ? Theme.colors.accent500 : Theme.colors.text
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
        leftPadding:    root.indicator.implicitWidth + Theme.spacing.s1
        text:           root.text
        color:          Theme.colors.text
        font.family:    Theme.typography.familySans
        font.pointSize: root._size.fontSize
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
