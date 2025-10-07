import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


Switch {
    id: control


    property string image:""
    property color imageColor: "#ffffff"
    property color imageColorOn: "#ffffff"

    property int labelHAlignment: Text.AlignLeft
    property int labelVAlignment: Text.AlignVCenter
    property string label:""
    property color labelColor: "#ffffff"
    property color labelColorOn: "#ffffff"
    property real labelFontPointSize: 18
    property bool labelFontBold: false
    property string labelOff: ""
    property color labelOffColor: "#ffffff"
    property real labelOffFontPointSize: 18
    property string labelOn: ""
    property color labelOnColor: "#ffffff"
    property real labelOnFontPointSize: 18

    property string fontFamily: "RobotoMedium"

    property color backgroundColor: "transparent"

    property real layoutVSpacing: 4
    property real layoutHSpacing: 0

    property real imagePadding: 4

    property real switchBorderWidth: 2
    property color switchBorderColorOff: "#d2dcf1f7"
    property color switchBorderColorOn: "#d2dcf1f7"

    property color switchBackgroundColorOff: "transparent"
    property color switchBackgroundColorOn: "transparent"

    property color switchButtonColorOff: "#d2dcf1f7"
    property color switchButtonColorOffDown: "#52718b"

    property color switchButtonColorOn: "#d2dcf1f7"
    property color switchButtonColorOnDown: "#52718b"
    property real switchButtonBorderWidth: 0




    property bool circular: false
    property real switchRadius: 4
    property real switchButtonRadius: 4

    property real imageWidth
    property real labelWidth
    property real switchHandleWidth

    property real imageHeight
    property real labelHeight
    property real switchHandleHeight

    property int imagePos: -1
    property int labelPos: -1
    property int switchHandlePos: -1

    property real _switchIconW: (!imageWidth)? mainItem.width*.2 : imageWidth
    property real _switchLabelW: (!labelWidth)? mainItem.width*.4 : labelWidth
    property real _switchHandleW: (!switchHandleWidth) ? mainItem.width*.4 : switchHandleWidth

    property real _switchIconH: height
    property real _switchLabelH: height
    property real _switchHandleH: height

    property var childrenArray: []

    contentItem: mainItem

    indicator: switchHandle

    padding: 0

    signal switched(bool checked, string state)


    onToggled: {
        switched(checked, state)
    }


    Component.onCompleted: {

        initPositions()
        initSizes()


        if(circular)
        {
            console.log(_switchHandleH, switchHandle.height)
            if (switchHandle.width === switchHandle.height*2)
            {
                return
            }


            else if(switchHandle.width > switchHandle.height*2)
            {
                _switchHandleW =  switchHandle.height*2
                console.log(_switchHandleW)
            }
            else if(switchHandle.width < switchHandle.height*2)
            {
                _switchHandleH = switchHandle.width*.5
            }

            //_switchHandleH = switchHandle.width*.5
            //switchHandle.height =  switchHandle.width*.5
            //switchHandle.radius = switchHandle.height*.5
        }


    }

    function initSizes()
    {
        if(labelWidth)
            _switchLabelW = labelWidth
        if(imageWidth)
            _switchIconW =imageWidth
        if(switchHandleWidth)
            _switchHandleW =switchHandleWidth

        if(labelHeight || imageHeight || switchHandleHeight)
        {
            if(labelHeight)
                _switchLabelH = labelHeight
            if(imageHeight)
                _switchIconH =imageHeight
            if(switchHandleHeight && !circular)
                _switchHandleH =switchHandleHeight

        }

/*
        if(circular)
        {

                if(!switchHandleWidth)
                {
                    console.log("#############")
                    _switchHandleH = switchHandle.width*.5
                    //control.height =switchHandle.width*.5
                }
                else
                {
                    console.log("*************")
                    _switchHandleW =switchHandleWidth
                    _switchHandleH = switchHandleWidth*.5
                    //control.height =_switchHandleH
                    console.log(_switchHandleW, _switchHandleH,control.height, switchHandle.width, switchHandle.height)
                    console.log("*************")
                }



        }

        console.log("****",_switchHandleW, _switchHandleH,control.height, switchHandle.width, switchHandle.height)

*/

    }

    function initPositions()
    {
        if(imagePos <= 0 && labelPos <= 0  && switchHandlePos <= 0)
            return

        if(imagePos > gridLayout.children.length || labelPos > gridLayout.children.length  || switchHandlePos > gridLayout.children.length)
        {
            console.log("[SwitchButton] element position > layout.children.length")
            return
        }


        if (imagePos !== -1 && switchIcon.visible)
            repos(switchIcon, imagePos - 1)

        if (labelPos !== -1 && switchLabel.visible)
            repos(switchLabel, labelPos - 1)

        if (switchHandlePos !== -1 && switchHandle.visible)
            repos(switchHandle, switchHandlePos - 1)



    }

    function findChildIndex(el)
    {
        const rule = (element) => element === el

        return gridLayout.children.findIndex(rule)
    }

    function repos(el, pos)
    {
        childrenArray = []
        for (let j in gridLayout.children)
            childrenArray.push(gridLayout.children[j])

        let i = findChildIndex(el)
        childrenArray.splice(i, 1);
        childrenArray.splice(pos, 0, el);
        gridLayout.children = []
        gridLayout.children = childrenArray
    }

    Rectangle {
        id: mainItem
        color: control.backgroundColor
        anchors.fill: parent
        anchors.centerIn: parent

        GridLayout {
            id: gridLayout
            width:parent.width
            //height: parent.height
            anchors.centerIn: parent
            rows: 1
            columns: 3
            columnSpacing: control.layoutHSpacing

            Item {
                id: switchIcon
                Layout.preferredWidth: _switchIconW
                Layout.preferredHeight: _switchIconH
                Layout.fillWidth: (!control.imageWidth) ? true : false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: image.length > 0


                Image {
                    id: switchIconImage
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: (switchLabel.visible) ? control.imagePadding : 0
                    source: image
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    antialiasing: true
                    visible: false

                }

                ColorOverlay {
                    id: switchIconOverlay
                    anchors.fill: switchIconImage
                    source: switchIconImage
                    color: (control.state === "off") ? control.imageColor : control.imageColorOn
                    visible: true
                }
            }

            Text {
                id: switchLabel
                Layout.preferredWidth: _switchLabelW
                Layout.preferredHeight: _switchLabelH
                Layout.fillWidth: (!control.labelWidth) ? true : false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: (control.state === "off") ? control.labelColor : control.labelColorOn
                text: control.label
                font.pixelSize: control.labelFontPointSize
                horizontalAlignment: control.labelHAlignment
                verticalAlignment: control.labelVAlignment
                font.bold: control.labelFontBold
                font.capitalization: Font.AllUppercase
                font.family: control.fontFamily
                elide: Text.ElideRight
                visible: label.length > 0
                smooth: true
            }


            Rectangle {
                id: switchHandle
                Layout.preferredWidth: _switchHandleW
                Layout.preferredHeight: _switchHandleH
                Layout.fillWidth: (control.label.length <= 0 && control.image.length <= 0 && !control.circular) ? true : false//(!control.switchHandleWidth && !circular) ? true : false //(!control.switchHandleWidth && !circular) ? true : false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: control.switchBackgroundColorOff
                radius: (!control.circular) ? control.switchRadius : switchHandle.height*.5
                border.color: control.switchBorderColorOff
                border.width: control.switchBorderWidth

                onHeightChanged: {

                }

                onWidthChanged: {

                    if(circular)
                    {
                        if (switchHandle.width === switchHandle.height*2)
                            return



                        else if(switchHandle.width > switchHandle.height*2)
                            _switchHandleW =  switchHandle.height*2

                        else if(switchHandle.width < switchHandle.height*2)
                            _switchHandleH = switchHandle.width*.5

                    }

                }
                Rectangle {
                    id: rectangle
                    width: parent.width * .5
                    color: control.switchButtonColorOff
                    radius: (!control.circular) ? control.switchButtonRadius : switchHandle.height*.5
                    border.width: control.switchButtonBorderWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    onWidthChanged: {

                    }
                    onHeightChanged: {

                    }
                }

                Text {
                    id: text1
                    width: parent.width * .5
                    color: control.labelOffColor
                    text: control.labelOff
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    font.pointSize: control.labelOffFontPointSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: control.fontFamily
                    font.capitalization: Font.AllUppercase
                }

                Text {
                    id: text2
                    width: parent.width * .5
                    color: control.labelOnColor
                    text: control.labelOn
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    font.pointSize: control.labelOnFontPointSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: control.fontFamily
                    font.capitalization: Font.AllUppercase
                    anchors.verticalCenterOffset: 0
                }
            }
        }
    }
    states: [

        State {
            name: "off"
            when: !control.checked && !control.down

            PropertyChanges {
                target: rectangle
                x: 0
                color: control.switchButtonColorOff
            }

            PropertyChanges {
                target: switchHandle
                color: control.switchBackgroundColorOff
                border.color: switchBorderColorOff
            }
        },
        State {
            name: "on"
            when: control.checked && !control.down

            PropertyChanges {
                target: rectangle
                x: parent.width - width
                color: control.switchButtonColorOn
            }

            PropertyChanges {
                target: switchHandle
                color: control.switchBackgroundColorOn
                border.color: switchBorderColorOn
            }
        },

        State {
            name: "off_down"
            when: !control.checked && control.down

            PropertyChanges {
                target: rectangle
                x: 0
                color: control.switchButtonColorOffDown
            }


            PropertyChanges {
                target: switchHandle
                color: control.switchBackgroundColorOff
                border.color: switchBorderColorOff
            }

        },
        State {
            name: "on_down"
            when: control.checked && control.down

            PropertyChanges {
                target: rectangle
                x: parent.width - width
                color: control.switchButtonColorOnDown
            }


            PropertyChanges {
                target: switchHandle
                color: control.switchBackgroundColorOn
                border.color: switchBorderColorOn
            }

        }



    ]
}
