import QtQuick
import QtQuick.Controls
import QtQuick.Shapes



Button {

    id: shapeButton

    checkable: false
    autoExclusive: false

    contentItem: Loader{id:contentLoader

                        onLoaded: {
                            shapeButton.containmentMask = contentLoader.item
                            shapeCompleted()

                        }
    }


    property var shapeParams
    property string shapeSrc

    signal shapeCompleted

    padding: 0
    background: Rectangle {
            border.color: shapeButton.down || shapeButton.hovered ? "transparent" : "transparent"
            color: shapeButton.down || shapeButton.hovered ? "transparent" : "transparent"

        }

    Component.onCompleted: {

        contentLoader.setSource(shapeSrc, shapeParams)
    }


    onToggled: {

    }



    onPressed: {
    }

    onReleased: {
    }

    onClicked: {
    }

    onCheckedChanged: {
    }



}
