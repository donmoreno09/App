// import QtQuick
// import QtQuick.Controls
// import Qt5Compat.GraphicalEffects


// Item {
//     id: owntrackItem
//     width: 280
//     height: 37
//     property string key: ""
//     property string value: ""
//     property string placeholder: ""
//     property string subvalue: ""

//     property color keyColor: "#FFF0CB"
//     property color valueColor: "#ffffff"
//     property color subvalueColor:"#ffffff"

//     property int fontSize: 8

//     property string keyFontFamily: "RobotoMedium"
//     property string valueFontFamily: "RobotoLight"

//     property real keyWidth: owntrackItem.width / 2
//     property real keyCaps: Font.AllUppercase
//     property real valueCaps: Font.Capitalize
//     property real keySpacing: 0
//     property real valueSpacing: 2
//     property real spacing: 0

//     property alias image: img.source
//     property color dropShadowcolor: "#0000fc4a"
//     property int imageSize: 0
//     property alias inputMethodHints: textField.inputMethodHints
//     property alias inputMask: textField.inputMask
//     property alias inputValidator: textField.validator
//     property string inputDefaultValue: ""

//     signal textFieldAccepted(string val, bool val)


//     enum EditModeType{
//         ComboBox,
//         TextField,
//         NoEdit
//     }

//     property int editingModeType: OwnPositionItem.EditModeType.NoEdit
//     property var editingModeValues: []
//     property bool editMode: false


//     onEditModeChanged: {

//         if (editMode)
//         {
//             if (editingModeType === OwnPositionItem.EditModeType.TextField)
//                 setTextFieldText()
//         }



//     }

//     function setTextFieldText()
//     {
//         if (valueLabel.text.length > 0)
//         {
//             textField.text = valueLabel.text
//             if (!textField.acceptableInput)
//                 textField.text = inputDefaultValue
//         }


//     }

//     function saveChanges()
//     {

//         if(editMode && editingModeType === OwnPositionItem.EditModeType.TextField)
//         {
//             if(textField.acceptableInput)
//             {
//                 owntrackItem.value = textField.text.toLowerCase()
//                 textFieldAccepted(owntrackItem.value, textField.acceptableInput)
//             }

//         }


//     }


//     Item{
//         id:keyGroup
//         width: parent.width*.3
//         height: parent.height
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.left: parent.left

//         Text {
//             id: keyLabel
//             width: parent.width
//             height: parent.height
//             color: owntrackItem.keyColor
//             text: qsTr(owntrackItem.key)
//             anchors.verticalCenter: parent.verticalCenter
//             anchors.left: parent.left
//             font.pixelSize: owntrackItem.fontSize
//             horizontalAlignment: Text.AlignLeft
//             verticalAlignment: Text.AlignVCenter
//             wrapMode: Text.NoWrap
//             font.family: keyFontFamily
//             font.capitalization: owntrackItem.keyCaps
//             font.bold: true
//         }

//     }



//     Item{
//         id: valueGroup
//         width: parent.width*.4
//         height: parent.height
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.right: img.left
//         anchors.rightMargin: spacing

//         Text {
//             id: valueLabel
//             width: (subvalueLabel.visible) ? parent.width*.8 : parent.width
//             height: parent.height
//             visible: true
//             color: owntrackItem.valueColor
//             text: qsTr(owntrackItem.value)
//             anchors.verticalCenter: parent.verticalCenter
//             anchors.left: parent.left
//             font.pixelSize: owntrackItem.fontSize
//             horizontalAlignment: Text.AlignRight
//             verticalAlignment: Text.AlignVCenter
//             layer.enabled: true
//             layer.effect: DropShadow {
//                 id: dropShadow
//                 color: owntrackItem.dropShadowcolor
//                 radius: 6
//                 verticalOffset: 0
//                 horizontalOffset: 0
//                 samples: 20
//                 spread: 0.4
//             }
//             font.family:valueFontFamily
//             font.capitalization: owntrackItem.valueCaps
//         }


//         TextField {
//             id: textField
//             placeholderText: qsTr(placeholder)
//             width: valueLabel.width
//             height: parent.height
//             visible: false
//             color: valueColor
//             anchors.verticalCenter: parent.verticalCenter
//             anchors.left: parent.left
//             font.pixelSize: owntrackItem.fontSize
//             horizontalAlignment: Text.AlignRight
//             verticalAlignment: Text.AlignVCenter
//             placeholderTextColor: "#80ffffff"
//             font.family: valueFontFamily
//             font.capitalization: owntrackItem.valueCaps
//             background: Rectangle{
//                 anchors.fill: parent
//                 anchors.centerIn: parent
//                 color:"#4d000000"
//                 border.color: "transparent"

//             }
//         }



//         Text {
//             id: subvalueLabel
//             width: parent.width*.2
//             height: parent.height
//             color: owntrackItem.subvalueColor
//             text: qsTr(owntrackItem.subvalue)
//             anchors.verticalCenter: parent.verticalCenter
//             anchors.right: parent.right
//             font.pixelSize: owntrackItem.fontSize
//             horizontalAlignment: Text.AlignLeft
//             verticalAlignment: Text.AlignVCenter
//             anchors.leftMargin: valueSpacing
//             font.family:valueFontFamily
//             font.capitalization: owntrackItem.valueCaps
//             visible: (subvalue.length > 0) ? true : false

//         }


//     }

//     Image {
//         id: img
//         width: (!imageSize) ? parent.height : imageSize
//         height: (!imageSize) ? parent.height : imageSize
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.right: parent.right
//         source: ""
//         anchors.leftMargin: spacing
//         fillMode: Image.PreserveAspectFit
//         antialiasing: true
//         smooth: true
//     }

//     states: [
//         State {
//             name: "editTextfield"
//             when: owntrackItem.editMode && owntrackItem.editingModeType === OwnPositionItem.EditModeType.TextField

//             PropertyChanges {
//                 target: textField
//                 visible: true
//             }

//             PropertyChanges {
//                 target: valueLabel
//                 visible: false
//             }
//         }
//     ]

//     RotationAnimation {
//         id: iconRotAnimation
//         target: img
//         property: "rotation"
//         direction: RotationAnimation.Shortest
//         duration: 2000
//         easing.type: Easing.OutBounce


//         function startRotationAnimation(to)
//         {
//             iconRotAnimation.stop()
//             iconRotAnimation.from = img.rotation
//             iconRotAnimation.to = to
//             if (iconRotAnimation.from  !== iconRotAnimation.to) {
//                 iconRotAnimation.start()
//             }
//         }
//     }

//     function rotateIcon(angle)
//     {
//         iconRotAnimation.startRotationAnimation(angle)
//     }
// }
