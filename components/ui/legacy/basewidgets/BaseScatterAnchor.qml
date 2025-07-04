import QtQuick
import "../basewidgets" as Widgets
import Qt5Compat.GraphicalEffects



Widgets.BasePanel {

    id: baseScatterAnchor

    doPress: true
    width: 80
    height: 80
    color: "transparent"
    transformOrigin: Item.Center


    property string label:""
    property real innerCirclePadding: 4

    enum Orientation{
        Top,
        Bottom,
        Left,
        Right
    }

    onPressed: (evtHandler, w) => {

               }


    Rectangle{
        id: anchorOuterCircle
        anchors.fill: parent
        anchors.centerIn: parent
        color: "#f21f3154"
        radius: 180
        antialiasing: true
    }

    Rectangle{

        id: anchorInnerCircle
        anchors.centerIn: parent
        width: baseScatterAnchor.width  - baseScatterAnchor.innerCirclePadding*2
        height: baseScatterAnchor.height - baseScatterAnchor.innerCirclePadding*2
        color:"transparent"
        radius: 180
        border.color: "white"
        border.width: 2

        Text {
            id: anchorInnerCircleLabel
            text: qsTr(baseScatterAnchor.label.toLowerCase())
            anchors.top: anchorInnerCircle.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            width: anchorInnerCircle.width
            font.capitalization: Font.Capitalize
            color: "white"
            smooth: true
            antialiasing: true


        }



    }

    Glow {
        id: anchorInnerCircleGlowEffect
        source: anchorInnerCircle
        anchors.fill: anchorInnerCircle
        color: "#5281c6f0"
        radius: 0
        smooth: true

    }


    SequentialAnimation {
        id: anchorInnerCircleGlowEffectAnim
        loops: Animation.Infinite
        alwaysRunToEnd: false
        running: true


        PropertyAnimation { target: anchorInnerCircleGlowEffect; property:"radius"; to: 8; easing.type: Easing.OutQuad; duration: 2000}
        PropertyAnimation { target: anchorInnerCircleGlowEffect; property:"radius"; to: 0; easing.type: Easing.InQuad; duration: 2000}

       }

    function dispose(orientation)
    {
        switch (orientation)
        {
            case BaseScatterAnchor.Orientation.Top:
            {
                baseScatterAnchor.rotation = 0
                anchorInnerCircleLabel.anchors.top = anchorInnerCircle.verticalCenter
                break
            }

            case BaseScatterAnchor.Orientation.Bottom:
            {
                baseScatterAnchor.rotation = 0
                anchorInnerCircleLabel.anchors.top = undefined
                anchorInnerCircleLabel.anchors.bottom = anchorInnerCircle.verticalCenter
                break
            }

            case BaseScatterAnchor.Orientation.Left:
            {
                baseScatterAnchor.rotation = 0
                baseScatterAnchor.rotation = -90
                anchorInnerCircleLabel.anchors.bottom = undefined
                anchorInnerCircleLabel.anchors.top = anchorInnerCircle.verticalCenter
                break
            }

            case BaseScatterAnchor.Orientation.Right:
            {
                baseScatterAnchor.rotation = 0
                baseScatterAnchor.rotation = 90
                anchorInnerCircleLabel.anchors.bottom = undefined
                anchorInnerCircleLabel.anchors.top = anchorInnerCircle.verticalCenter
                break
            }






        }
    }







}
