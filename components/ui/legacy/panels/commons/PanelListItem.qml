import QtQuick
import QtQuick.Controls

Item {
    id: panelListItem
    width: 280
    height: 26
    property string keyTxt: ""
    property string valueTxt: ""
    property string subvalueTxt: ""
    property string placeholder: ""
    property color keyColor:"#cfdff3"
    property color valueColor:"#ffffff"
    property color subvalueColor:"#ffffff"

    property real valueSpacing: 2
    property real spacing: 0

    property int fontSize: 8
    property string keyFontFamily: "RobotoMedium"
    property string valueFontFamily: "RobotoLight"

    //property real keyWidth: panelListItem.width * 0.5
    property real keyTxtFormat: Font.AllUppercase
    property real valueTxtFormat: Font.Capitalize
    property real subvalueTxtFormat: Font.Capitalize

    property alias inputMethodHints: textField.inputMethodHints
    property alias inputMask: textField.inputMask
    property alias inputValidator: textField.validator
    property string inputDefaultValue: ""

    signal textFieldAccepted(string val, bool val)

    Component.onCompleted: {
    }

    Text {
        id: keyLabel
        width: parent.width*.5
        height: parent.height
        color: panelListItem.keyColor
        text: qsTr(panelListItem.keyTxt)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        font.pixelSize: fontSize
        verticalAlignment: Text.AlignVCenter
        font.family: keyFontFamily
        font.capitalization: keyTxtFormat
        font.bold: true

    }

    Item{
        width: parent.width*.5
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: keyLabel.right
        anchors.leftMargin: spacing

        Text {
            id: valueLabel
            width: (subvalueLabel.visible) ? parent.width*.6 : parent.width
            height: parent.height
            color: panelListItem.valueColor
            text: qsTr(panelListItem.valueTxt)
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            font.pixelSize: fontSize
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font.capitalization: valueTxtFormat
            font.family: valueFontFamily

        }

        Text {
            id: subvalueLabel
            width: parent.width*.4
            height: parent.height
            color: panelListItem.subvalueColor
            text: qsTr(panelListItem.subvalueTxt)
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: valueLabel.right
            anchors.leftMargin: valueSpacing
            font.pixelSize: fontSize
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.capitalization: subvalueTxtFormat
            font.family: valueFontFamily
            visible: (subvalueTxt.length > 0) ? true : false
        }
    }

    TextField {
        id: textField
        placeholderText: qsTr(placeholder)
        width: valueLabel.width
        height: parent.height
        visible: false
        color: valueColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: keyLabel.right
        font.pixelSize: fontSize
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        placeholderTextColor: "#80ffffff"
        font.family: valueFontFamily
        font.capitalization: Font.Capitalize
        background: Rectangle {
            anchors.fill: parent
            anchors.centerIn: parent
            color:"#4d000000"
            border.color: "transparent"
        }
    }


    function setComboBoxCurrentItem()
    {
        if (combobox.model.length > 0 && valueLabel.text.length > 0){
            let displayTextIndex = combobox.model.indexOf(valueLabel.text.toUpperCase())
            if(displayTextIndex !==-1)
                combobox.currentIndex = displayTextIndex
        }
    }


    function setTextFieldText()
    {
        if (valueLabel.text.length > 0)
        {
            textField.text = valueLabel.text
            if (!textField.acceptableInput)
                textField.text = inputDefaultValue
        }
    }
}
