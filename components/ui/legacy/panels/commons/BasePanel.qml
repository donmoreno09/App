import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Shapes 1.0

import "../../../qtds" as QTDSComponents
import "../../basewidgets" as Widgets

Widgets.BaseScatter {
    id: root
    width: 330
    height: 380
    color: "#00ffffff"
    border.width: 0
    clip: true

    doRotation: false
    doScale: false

    property var headerSection: header
    property var bodySection: body
    property var footerSection: footer
    property var closeButton: closeBtn

    property string headerTitleText: "title"
    property color headerGradientColorStart: "#113969"
    property color headerGradientColorEnd: "#99103766"
    property color headerTitleColor: "#cfdff3"

    property color bodyGradientColorStart: "#21518b"
    property color bodyGradientColorEnd: "#9921518b"

    property color footerGradientColorStart: "#063062"
    property color footerGradientColorEnd: "#99063062"

    property string baseFont: "RobotoMedium"

    property int topLeftBevelRadius: 14
    property int bottomRightBevelRadius: 46

    QTDSComponents.RectangleItem {
        id: trackPanel
        anchors.fill: parent
        anchors.centerIn: parent
        fillColor: "#0021518b"
        radius: 0
        topLeftRadius: 0
        bottomRightBevel: false
        topLeftBevel: false
        clip: true
        strokeWidth: 0
        strokeColor: "#00ff0000"

        QTDSComponents.RectangleItem {
            id: header
            width: parent.width
            height: parent.height / 10
            radius: 0
            anchors.top: parent.top
            gradient: LinearGradient {
                GradientStop {
                    position: 0
                    color: headerGradientColorStart
                }

                GradientStop {
                    position: 1
                    color: headerGradientColorEnd
                }
                y1: 0
                x2: 300
                x1: 0
                y2: 350
            }
            strokeColor: "#00ff0000"
            topLeftRadius: root.topLeftBevelRadius
            topLeftBevel: true
            strokeWidth: 0
            anchors.topMargin: 0

            Text {
                id: headerTitle
                color: headerTitleColor
                text: qsTr(headerTitleText)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.styleName: "Regular"
                scale: 1
                font.pointSize: 11
                font.bold: false
                font.family: baseFont
                anchors.leftMargin: parent.width / 25
            }

            Widgets.BaseButton {
                id: closeBtn
                width: header.height
                height: header.height
                anchors.verticalCenter: header.verticalCenter
                anchors.right: header.right
                anchors.rightMargin: 0
                image: "qrc:///assets/icons/panels/close.svg"
                backgroundColor: "transparent"
                backgroundColorDown: "#3b000000"
            }
        }

        QTDSComponents.RectangleItem {
            id: body
            width: parent.width
            radius: 0
            anchors.top: header.bottom
            anchors.bottom: footer.top
            gradient: LinearGradient {
                GradientStop {
                    position: 0
                    color: bodyGradientColorStart
                }

                GradientStop {
                    position: 1
                    color: bodyGradientColorEnd
                }
                y1: 0
                x2: 300
                x1: 0
                y2: 350
            }
            strokeColor: "#00ff0000"
            strokeWidth: 0
            anchors.bottomMargin: 0
            anchors.topMargin: 0
        }

        QTDSComponents.RectangleItem {
            id: footer
            width: parent.width
            height: parent.height / 6.8
            radius: 0
            anchors.bottom: parent.bottom
            gradient: LinearGradient {
                GradientStop {
                    id: gradientStop
                    position: 0
                    color: footerGradientColorStart
                }

                GradientStop {
                    position: 1
                    color: footerGradientColorEnd
                }
                y1: 0
                x2: 300
                x1: 0
                y2: 350
            }
            strokeColor: "#00ff0000"
            bottomRightRadius: root.bottomRightBevelRadius
            bottomRightBevel: true
            strokeWidth: -1
            anchors.bottomMargin: 0
        }
    }
}
