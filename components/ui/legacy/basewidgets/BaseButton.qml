import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../../qtds" as QTDSComponents


Button {
    id: control

    property string image: ""
    property int labelHAlignment: Text.AlignHCenter
    property int labelVAlignment: Text.AlignVCenter
    property color backgroundColor: "#121e47"
    property color backgroundColorDown: "#123155"
    property color labelColor: "#edf7fa"
    property color labelColorDown: "#edf7fa"
    property bool labelBoldDown: false
    property color imageColor: "white"
    property color imageColorDown: "white"
    property color borderColor: "transparent"
    property color borderColorDown: "transparent"
    property real  borderWidth: 0
    property real borderRadius: 0
    property int orientation: BaseButton.LayoutOrientation.Vertical
    property int direction: BaseButton.LayoutDirection.TopToBottom
    property real layoutHSpacing: mainItem.width/50
    property real layoutVSpacing: mainItem.height/50
    property real imagePadding: (orientation === BaseButton.LayoutOrientation.Vertical) ? buttonIcon.width*.1 : buttonIcon.height*.1



    text: ""
    flat: true

    width: 60
    height: 60
    font.pointSize: 9
    font.family: "RobotoMedium"
    font.bold: false

    contentItem: mainItem
    background: Rectangle {
                    color: control.down ? "transparent" : "transparent"
                }

    padding: 0


    enum LayoutOrientation{
        Vertical,
        Horizontal
    }

    enum LayoutDirection{
        TopToBottom,
        BottomToTop,
        LeftToRight,
        RightToLeft
    }





    Component.onCompleted: {


        if(control.text.length <= 0 || control.text === undefined)
            imagePadding = 0

        initDirection()


    }

    function swapItems(el1, el2){



        let posA = gridLayout.children[findChildIndex(el1)]
        let posB = gridLayout.children[findChildIndex(el2)]

        gridLayout.children = []

        gridLayout.children.push(posB)
        gridLayout.children.push(posA)


    }

    function findChildIndex(el)
    {
        const rule = (element) => element === el

        return gridLayout.children.findIndex(rule)
    }


    function initDirection()
    {
        switch (orientation) {
          case BaseButton.LayoutOrientation.Vertical:
            {
              if(direction === BaseButton.LayoutDirection.TopToBottom || direction === BaseButton.LayoutDirection.BottomToTop)
              {
                  if(direction === BaseButton.LayoutDirection.BottomToTop)
                      swapItems(buttonIcon, buttonLabel)

                  break
              }

              else
              {
                  console.log("[BaseButton] Error: Button ",text," LayoutOrientation.Vertical allows LayoutDirection.TopToBottom or LayoutDirection.BottomToTop only." )
                  break
              }

            }


          case BaseButton.LayoutOrientation.Horizontal:
            {
              if(direction === BaseButton.LayoutDirection.LeftToRight || direction === BaseButton.LayoutDirection.RightToLeft)
              {
                  if(direction === BaseButton.LayoutDirection.RightToLeft)
                      swapItems(buttonIcon, buttonLabel)
                  break
              }

              else
              {
                  console.log("[BaseButton] Error: Button ",text," LayoutOrientation.Horizontal allows LayoutDirection.RightToLeft or LayoutDirection.LeftToRight only." )
                  break
              }

            }

        }

    }


    states: [
        State {
            name: "normal"
            when: !control.down

            PropertyChanges {
                target: mainItem
                fillColor: control.backgroundColor
                strokeColor: control.borderColor
            }

            PropertyChanges {
                target: buttonIconOverlay
                color: control.imageColor

            }

            PropertyChanges {
                target: buttonLabel
                color: control.labelColor
                font.bold:control.font.bold


            }




        },
        State {
            name: "down"
            when: control.down

            PropertyChanges {
                target: mainItem
                fillColor: control.backgroundColorDown
                strokeColor: control.borderColorDown
            }

            PropertyChanges {
                target: buttonIconOverlay
                color: control.imageColorDown

            }

            PropertyChanges {
                target: buttonLabel
                color: control.labelColorDown
                font.bold: control.labelBoldDown

            }
        }
    ]
    QTDSComponents.RectangleItem {
        id: mainItem
        anchors.centerIn: parent
        fillColor: control.backgroundColor
        bevel: false
        strokeWidth: control.borderWidth
        strokeColor: control.borderColor
        opacity: enabled ? 1 : 0.3
        radius: control.borderRadius
        smooth: true
        antialiasing: true

        GridLayout {
            id: gridLayout
            anchors.fill: parent
            anchors.centerIn: parent
            rows: (orientation === BaseButton.LayoutOrientation.Vertical) ? 2 : 1
            columns: (orientation === BaseButton.LayoutOrientation.Vertical) ? 1 : 2
            flow: GridLayout.TopToBottom
            rowSpacing:  (orientation === BaseButton.LayoutOrientation.Vertical) ? layoutVSpacing : 0
            columnSpacing: (orientation === BaseButton.LayoutOrientation.Vertical) ? 0 : layoutHSpacing


            Item {
                id: buttonIcon
                Layout.preferredWidth: (orientation === BaseButton.LayoutOrientation.Vertical) ? mainItem.width: mainItem.width - buttonLabel.width - gridLayout.columnSpacing
                Layout.preferredHeight: (orientation === BaseButton.LayoutOrientation.Vertical) ? mainItem.height - buttonLabel.height - gridLayout.rowSpacing: mainItem.height
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: image.length > 0
                Image {
                    id: buttonIconImage
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: control.imagePadding
                    visible: false
                    source: image
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    antialiasing: true
                }

                ColorOverlay {
                    id: buttonIconOverlay
                    anchors.fill: buttonIconImage
                    source: buttonIconImage
                    color: (!control.down) ? imageColor : imageColorDown
                    visible: true
                }
            }

            Text {
                id: buttonLabel
                Layout.preferredWidth: (orientation === BaseButton.LayoutOrientation.Vertical) ? mainItem.width :  mainItem.width*.7
                Layout.preferredHeight: (orientation === BaseButton.LayoutOrientation.Vertical) ? mainItem.height * .3 : mainItem.height
                color: control.labelColor
                text: control.text
                font.pixelSize: control.font.pointSize
                horizontalAlignment: labelHAlignment
                verticalAlignment: labelVAlignment
                font.bold: control.font.bold
                Layout.bottomMargin: 0
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.capitalization: Font.AllUppercase
                font.family: control.font.family
                elide: Text.ElideRight
                visible: text.length > 0
                smooth: true
            }
        }
    }



}
