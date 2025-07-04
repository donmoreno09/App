import QtQuick
import QtQuick.Controls

ComboBox {
    id: comboBox
    width: 94
    height: 10
    currentIndex: 0
    displayText: currentText

    model: []

    delegate: ItemDelegate {
            width: comboBox.width
            contentItem: Rectangle{
                                    anchors.fill: parent
                                    anchors.centerIn: parent
                                    color: highlighted ? "07111D" : "#21518B"
                                    Text {
                                            anchors.fill: parent
                                            anchors.centerIn: parent
                                            text: (modelData) ? modelData: ""
                                            color: "#edf7fa"
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: 5
                                            font.family: "RobotoRegular"
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                }
            }
            highlighted: comboBox.highlightedIndex === index
        }
    indicator: Image {

        source: "qrc:///assets/icons/panels/track/comboBoxArrow.svg"
        anchors.rightMargin: parent.width / 23
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
    }

    background: Rectangle {
        color: "#21518B"
        border.color: "#edf7fa"
        border.width: 1
    }

    contentItem: Text {
        text: comboBox.displayText
        color: comboBox.pressed ? "#07111D" : "#edf7fa"
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 5
        font.family: "RobotoRegular"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }

    popup: Popup {
            y: comboBox.height + 2
            width: parent.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboBox.popup.visible ? comboBox.delegateModel : null
                currentIndex: comboBox.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }
            background: Rectangle {
                color: "#21518b"
                border.color: "#edf7fa"
            }
        }


}
