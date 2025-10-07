import QtQuick
import QtQuick.Controls

Item {
    id: switchButton
    width: 200
    height: 24

    property alias label: label.text
    property alias image: image.source

    signal switched(bool checked)

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        source: ""
        anchors.left: parent.left
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: label
        height: parent.height
        anchors.left: image.right
        anchors.leftMargin: 4
        anchors.right: switchBtn.left
        anchors.verticalCenter: parent.verticalCenter
        color: "#cfdff3"
        text: qsTr("LABEL")
        font.pixelSize: 9
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.family: "RobotoMedium"
        font.capitalization: Font.AllUppercase
    }

    PanelSwitch {
        id: switchBtn
        width: 32
        height: parent.height
        anchors.verticalCenter: switchButton.verticalCenter
        anchors.right: switchButton.right
        checkable: true
        autoRepeat: false
        autoExclusive: false
        checked: false

        onToggled: {
            switchButton.switched(switchBtn.checked)
        }
    }
}
