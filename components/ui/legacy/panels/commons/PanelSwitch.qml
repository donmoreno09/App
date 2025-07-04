import QtQuick
import QtQuick.Controls

Switch {
    id: control

    implicitWidth: backgroundItem.implicitWidth
    implicitHeight: backgroundItem.implicitHeight

    readonly property int baseSize: 12

    background: backgroundItem
    Rectangle {
        id: backgroundItem
        color: "#00000000"
        implicitWidth: control.baseSize * 10.0
        implicitHeight: control.baseSize * 5.0
    }

    leftPadding: 4

    indicator: switchHandle
    Rectangle {
        id: switchHandle
        implicitWidth: control.baseSize * 4.8
        implicitHeight: control.baseSize * 2.6
        x: control.leftPadding
        width: 24
        height: 12
        color: "#00ed1c24"
        anchors.verticalCenter: parent.verticalCenter
        radius: control.baseSize * 1.3
        border.width: 0

        Rectangle {
            id: rectangle
            width: 12
            height: 12

            radius: control.baseSize * 1.3
            border.width: 0
            color: "#edf7fa"
        }
    }
    states: [
        State {
            name: "off"
            when: !control.checked && !control.down

            PropertyChanges {
                target: rectangle
                color: "#edf7fa"
            }

            PropertyChanges {
                target: switchHandle
                color: "#ed1c24"
                border.color: "#aeaeae"
            }
        },
        State {
            name: "on"
            when: control.checked && !control.down

            PropertyChanges {
                target: switchHandle
                color: "#68f25c"
                border.color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle
                x: parent.width - width
            }
        },
        State {
            name: "off_down"
            when: !control.checked && control.down

            PropertyChanges {
                target: rectangle
                color: "#edf7fa"
            }

            PropertyChanges {
                target: switchHandle
                color: "#ed1c24"
                border.color: "#047eff"
            }
        },
        State {
            name: "on_down"
            when: control.checked && control.down

            PropertyChanges {
                target: rectangle
                x: parent.width - width
                color: "#e9e9e9"
            }

            PropertyChanges {
                target: switchHandle
                color: "#68f25c"
                border.color: "#ffffff"
            }
        }
    ]
}
