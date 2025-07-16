import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


import "../basewidgets" as Widgets

Widgets.BaseShapeButton {
    id: radialMenuArcButton

    property string fontFamily: "RobotoRegular"
    anchors.centerIn: parent
    anchors.fill: parent

    enum ButtonState {
        Default,
        Selected,
        None
    }

    enum ButtonStateNotify {
        Active,
        Inactive,
        Waiting,
        None
    }

    property color fillColor
    property color strokeColor
    property real strokeWidth
    property real begin
    property real end
    property real arcWidth
    property bool shapeAntialiasing

    shapeParams: {
        "containsMode": Shape.FillContains,
        "outlineArc": true,
        "fillColor": fillColor,
        "strokeColor": strokeColor,
        "strokeWidth": strokeWidth,
        "begin": begin,
        "end": end,
        "antialiasing": shapeAntialiasing,
        "arcWidth": arcWidth
    }

    shapeSrc: Qt.resolvedUrl("../basewidgets/BaseArcShape.qml")

    property string nodeId: ""
    property string name: ""
    property string displayName: ""

    property real customPadding: 0
    property real angle: ((begin + end)/2) * (Math.PI / 180) - 1.57
    property real r: 0
    property real innerRad: r - arcWidth - customPadding
    property real finalRad: r - (arcWidth / 2) - customPadding

    anchors.margins: customPadding
    property int btnStateNotify: RadialMenuArcButton.ButtonStateNotify.None

    Component.onCompleted: {
        console.log(" Component.onCompleted RArcButton repos")
        //btnStateNotify = RadialMenuArcButton.ButtonStateNotify.Active
    }

    onShapeCompleted: {
        radialMenuArcButtonRect.repos()
    }

    onBtnStateNotifyChanged: function () {
        console.log("onBtnStateNotifyChanged", btnStateNotify)
    }

    onClicked: {}
    onPressed: {}
    onReleased: {}
    onToggled: {}
    onCheckedChanged: {}

    Rectangle {
        id: radialMenuArcButtonRect
        color: "transparent"

        Component.onCompleted: {
            repos()
        }

        ColumnLayout{
            id: radialMenuArcButtonLayout
            anchors.centerIn: parent
            spacing: 2

            Rectangle{
                color: "transparent"

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: radialMenuArcButtonIcon.width
                Layout.preferredHeight: radialMenuArcButtonIcon.height

                Image {
                    id: radialMenuArcButtonIcon
                    source: Qt.resolvedUrl("../assets/" + name.toLowerCase() + ".svg")
                    smooth: true
                    antialiasing: true
                    mipmap: true
                }

                Glow {
                    id: radialMenuArcButtonIconGlowEffect
                    source: radialMenuArcButtonIcon
                    anchors.fill: radialMenuArcButtonIcon
                    color: "white"
                    radius: 0
                    scale: radialMenuArcButtonIcon.scale
                    visible: true
                }

                ColorOverlay {
                    id: radialMenuArcButtonIconOverlay
                    anchors.fill: radialMenuArcButtonIcon
                    source: radialMenuArcButtonIcon
                    color: "white"
                }
            }


            Rectangle{
                color: "transparent"

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: radialMenuArcButtonLabel.width
                Layout.preferredHeight: radialMenuArcButtonLabel.height

                Text {
                    id: radialMenuArcButtonLabel
                    text: qsTr(displayName.toLowerCase())
                    horizontalAlignment: Text.AlignHCenter
                    width: radialMenuArcButton.width*0.3
                    font.capitalization: Font.Capitalize
                    color: "white"
                    font.family: radialMenuArcButton.fontFamily
                    font.pointSize: 12

                    onContentWidthChanged: {
                            var availableWidth = parent.width;

                            if (contentWidth > availableWidth && font.pointSize > 8) {
                                font.pointSize = font.pointSize - 1;
                            }
                        }
                }

                Glow {
                    id: radialMenuArcButtonLabelGlowEffect
                    source: radialMenuArcButtonLabel
                    anchors.fill: radialMenuArcButtonLabel
                    color: "white"
                    radius: 0
                    //scale: radialMenuArcButtonLabel.scale
                    visible: false
                }
            }
        }

        function repos()
        {
            width = radialMenuArcButtonLayout.width + radialMenuArcButton.customPadding*2
            height = radialMenuArcButtonLayout.height + radialMenuArcButton.customPadding*2
            x = (parent.finalRad) * Math.cos(parent.angle) + parent.r - width/2 - radialMenuArcButton.customPadding
            y = (parent.finalRad) * Math.sin(parent.angle) + parent.r - height/2 - radialMenuArcButton.customPadding
        }
    }

    SequentialAnimation {
        id: pulseAnim
        running: radialMenuArcButton.btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Waiting
        loops: Animation.Infinite
        alwaysRunToEnd: false

        PropertyAnimation { target: radialMenuArcButtonRect; property:"opacity"; to: 0.3; easing.type: Easing.OutQuad; duration: 2000}
        PropertyAnimation { target: radialMenuArcButtonRect; property:"opacity"; to: 1; easing.type: Easing.InQuad; duration: 2000}
    }

    states: [
        State {
            name: "activeDefault"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Active && !checked
            extend: "default"
            PropertyChanges { target: radialMenuArcButtonLabel; color: "#00fa9a" }
            PropertyChanges { target: radialMenuArcButtonIconOverlay; color: "#00fa9a" }
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
        },

        State {
            name: "activeSelected"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Active && checked
            extend: "selected"
            PropertyChanges { target: radialMenuArcButtonIconGlowEffect; radius:8; color:"#8000fa9a"}
            PropertyChanges { target: radialMenuArcButtonLabelGlowEffect; radius:8; color:"#8000fa9a"}
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
        },

        State {
            name: "inactiveDefault"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Inactive && !checked
            extend: "default"
            PropertyChanges { target: radialMenuArcButtonLabel; color: "#ff0000" }
            PropertyChanges { target: radialMenuArcButtonIconOverlay; color: "#ff0000" }
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
        },

        State {
            name: "inactiveSelected"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Inactive && checked
            extend: "selected"
            PropertyChanges { target: radialMenuArcButtonIconGlowEffect; color:"#80ff0000"}
            PropertyChanges { target: radialMenuArcButtonLabelGlowEffect; color:"#80ff0000"}
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
        },

        State {
            name: "waitingDefault"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Waiting && !checked
            extend: "default"
            PropertyChanges { target: radialMenuArcButtonLabel; color: "#ffa500" }
            PropertyChanges { target: radialMenuArcButtonIconOverlay; color: "#ffa500" }
        },

        State {
            name: "waitingSelected"
            when: btnStateNotify === RadialMenuArcButton.ButtonStateNotify.Waiting && checked
            extend: "selected"
            PropertyChanges { target: radialMenuArcButtonIconGlowEffect; color:"#80ffa500"}
            PropertyChanges { target: radialMenuArcButtonLabelGlowEffect; color:"#80ffa500"}
        },

        State {
            name: "default"
            when: !checked && !pressed
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
            PropertyChanges { target: radialMenuArcButtonIconOverlay; color: "white" }
            PropertyChanges { target: radialMenuArcButtonLabel; color: "white"; font.bold: false }
            PropertyChanges { target: radialMenuArcButtonIconGlowEffect; visible: false}
            PropertyChanges { target: radialMenuArcButtonLabelGlowEffect; visible: false}
        },

        State {
            name: "disabled"
            when: !enabled
            extend: "default"
            PropertyChanges { target: radialMenuArcButtonRect; opacity:0.2 }
        },

        State {
            name: "selected"
            when: checked || pressed
            extend: "default"
            PropertyChanges { target: radialMenuArcButtonRect; opacity:1.0 }
            PropertyChanges { target: radialMenuArcButtonLabel; font.bold: true }
            PropertyChanges { target: radialMenuArcButtonIconGlowEffect; visible: true; radius:8; color:"#5281c6f0"}
            PropertyChanges { target: radialMenuArcButtonLabelGlowEffect; visible: true; radius:8; color:"#5281c6f0"}
        }
    ]
}
