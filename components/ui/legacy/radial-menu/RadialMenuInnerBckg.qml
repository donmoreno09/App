import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

import "../basewidgets" as Widgets


Widgets.BaseArcShapeWidget {
    id: radialMenuInnerBckg
    anchors.centerIn: parent

    doPress: true

    property real padding: 4
    property real paddingImgRight: 10
    property real paddingImgLeft: 10
    property real paddingImgBottom: 10
    property real paddingImgTop: 10

    property url logoSrc: ""
    property url navSrc: ""
    property bool navTextVisible: false
    property url imageSrc: ""
    property bool imageGlowPulse: false
    property bool imageGlowPulseRunning: false

    property string backParentId: ""
    property string backParentName: ""

    property string fontFamily: "RobotoMedium"

    signal backButtonClicked(string nodeid)


    width: parent.width - parent.arcWidth*2 - parent.padding*2 - padding*2
    height: parent.height - parent.arcWidth*2 - parent.padding*2 - padding*2

    arcWidth: width/2
    strokeWidth: 0
    strokeColor: "transparent"
    fillColor: "#f21f3154"
    antialiasing: true
    outlineArc: true
    begin: 0
    end: 360

    onLongPressed: function (evtHandler, w) {
        handleGlowPulse();
    }

    onNavSrcChanged: function () {
        if (navSrc.toString().length > 0)
            state = "navigation"
        else
            state = "default"
    }



    Loader {
        id: radialMenuInnerBckgImageLoader
        anchors.fill: parent
    }

    Component {
        id: rmiBckgLogoComponent

        Item{
            Image {
                id: rmiBckgLogoImage
                source: imageSrc
                anchors.centerIn: parent
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                anchors.leftMargin: paddingImgLeft
                anchors.rightMargin: paddingImgRight
                anchors.topMargin: paddingImgTop
                anchors.bottomMargin: paddingImgBottom
                smooth: true
                visible: false
                mipmap: true
                antialiasing: true
                //        scale: 0.8 // do not use with animation, gfx glich and lagging (Why?)
            }


            Button {
                id: rmiBckgLogoLabel
                width: parent.width
                anchors.top: rmiBckgLogoImage.bottom
                visible: true
                smooth: true
                flat: true
                antialiasing: true
                contentItem: Text {
                    id:rmiBckgLogoLabelText
                    text: backParentName
                    horizontalAlignment : Text.AlignHCenter
                    font.weight: Font.Bold
                    font.pointSize: 14
                    font.capitalization: Font.AllUppercase
                    color: rmiBckgLogoLabel.down ? "#95c7ed" : "white"
                    smooth: true
                    antialiasing: true
                    font.family: radialMenuInnerBckg.fontFamily
                }

                background: Rectangle {
                    border.color: rmiBckgLogoLabel.down ? "transparent" : "transparent"
                    color: rmiBckgLogoLabel.down ? "transparent" : "transparent"
                }

                onClicked: radialMenuInnerBckg.handleBackBtnClicked()
            }


            Glow {
                id: rmiBckgLogoImageGlowEffect
                source: rmiBckgLogoImage
                anchors.fill: rmiBckgLogoImage
                color: "#5281c6f0"
                radius: 0
                scale: rmiBckgLogoImage.scale

            }

            Glow {
                id: rmiBckgLogoLabelGlowEffect
                source: rmiBckgLogoLabel
                anchors.fill: rmiBckgLogoLabel
                color: "#5281c6f0"
                radius: 0
                scale: rmiBckgLogoLabel.scale
                visible: navTextVisible

            }

            ParallelAnimation{

                running: radialMenuInnerBckg.imageGlowPulse && radialMenuInnerBckg.imageGlowPulseRunning
                alwaysRunToEnd: true

                SequentialAnimation{
                    id: rmiBckgLogoLabelGlowEffectAnim
                    loops: Animation.Infinite
                    alwaysRunToEnd: true

                    PropertyAnimation { target: rmiBckgLogoLabelGlowEffect; property:"radius"; to: 8; easing.type: Easing.OutQuad; duration: 2000}
                    PropertyAnimation { target: rmiBckgLogoLabelGlowEffect; property:"radius"; to: 0; easing.type: Easing.InQuad; duration: 2000}

                }
                SequentialAnimation {
                    id: rmiBckgLogoImageGlowEffectAnim
                    loops: Animation.Infinite
                    alwaysRunToEnd: true

                    PropertyAnimation { target: rmiBckgLogoImageGlowEffect; property:"radius"; to: 8; easing.type: Easing.OutQuad; duration: 2000}
                    PropertyAnimation { target: rmiBckgLogoImageGlowEffect; property:"radius"; to: 0; easing.type: Easing.InQuad; duration: 2000}
                }
            }
        }
    }

    states: [
        State {
            name: "default"
            PropertyChanges { target: radialMenuInnerBckg; imageSrc: radialMenuInnerBckg.logoSrc }
            PropertyChanges { target: radialMenuInnerBckg; paddingImgLeft: 10 ; paddingImgRight: 10; paddingImgTop: 10 ;paddingImgBottom: 10}
            PropertyChanges { target: radialMenuInnerBckg; navTextVisible: false }
        },
        State {
            name: "navigation"
            PropertyChanges { target: radialMenuInnerBckg; imageSrc: radialMenuInnerBckg.navSrc}
            PropertyChanges { target: radialMenuInnerBckg; paddingImgLeft: 70 ; paddingImgRight: 70; paddingImgTop: 30 ;paddingImgBottom: 70}
            PropertyChanges { target: radialMenuInnerBckg; navTextVisible: true }
        }
    ]


    Component.onCompleted: {
        radialMenuInnerBckg.state = "default"

        if (radialMenuInnerBckg.imageSrc)
            radialMenuInnerBckgImageLoader.sourceComponent = rmiBckgLogoComponent
    }

    function handleGlowPulse()
    {
        if(imageSrc && imageGlowPulse)
        {
            if (imageGlowPulseRunning)
                imageGlowPulseRunning = false
            else
                imageGlowPulseRunning = true
        }

    }

    function setBackParent(nodeId, nodeName, isRoot=false)
    {
        radialMenuInnerBckg.backParentId = nodeId
        radialMenuInnerBckg.backParentName = nodeName

        radialMenuInnerBckg.navSrc= Qt.resolvedUrl((isRoot)? "" : "../assets/" + backParentName.toLowerCase() + ".svg")
    }

    function handleBackBtnClicked()
    {
        backButtonClicked(radialMenuInnerBckg.backParentId)

    }
}

