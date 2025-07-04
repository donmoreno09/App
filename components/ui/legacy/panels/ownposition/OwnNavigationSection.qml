// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import "../../../qtds" as QTDSComponents
// import "../../panels/commons" as PanelCommons
// import "../../../basewidgets" as Widgets
// import "../../commons" as UiWidgets

// import "../../../js/regexExpressions.js" as RegExp


// import qml.controllers.ownpositioncontroller 1.0
// import qml.models.ownposition.cog 1.0
// import qml.models.ownposition.inertial 1.0

// Item {
//     id: navigation
//     width: 1015
//     height: 195

//     property string unknownString: "unk"
//     property var inertialData
//     property var cogData

//     state: "baseMode"

//     Component.onCompleted: {
//         clearCOGData()
//         clearInertialData()
//     }

//     Connections{
//         target: OwnPositionController

//         function onNewInertialData(data)
//         {

//             if(data.isManual())
//                 return

//             if(inertialData===undefined)
//             {
//                 inertialData=data
//                 clearInertialData()
//             }

//             if(data.time>inertialData.time)
//             {
//                 inertialData=data
//                 updateInertialData()
//             }
//         }


//         function onNewCourseOverGround (data){

//             if(data.isManual())
//                 return

//             if(cogData===undefined)
//             {
//                 cogData=data
//                 clearCOGData()
//             }
//             if(data.time>cogData.time)
//             {

//                 cogData=data
//                 updateCOGData()

//             }

//         }



//     }

//     QTDSComponents.RectangleItem {
//         id: rectangle
//         radius: 0
//         anchors.fill: parent
//         anchors.centerIn: parent
//         fillColor: "#0f1f3e"
//         strokeWidth: -1
//         adjustBorderRadius: true

//         QTDSComponents.GroupItem {
//             id: group
//             anchors.top: parent.top
//             anchors.horizontalCenter: parent.horizontalCenter
//             anchors.topMargin: navigation.height / 13
//             width: parent.width
//             height: parent.height*.15

//             UiWidgets.SwitchButton {
//                 id: modeBtn
//                 width: Screen.width*.03
//                 height: titlesection.height
//                 anchors.right: titlesection.left
//                 anchors.rightMargin: 10
//                 switchButtonColorOn: "#d22e84dc"
//                 switchButtonColorOff: "#d22e84dc"
//                 switchBorderColorOff: "#d22e84dc"
//                 switchBorderColorOn: "#d22e84dc"
//                 labelOffFontPointSize: 8
//                 labelOnFontPointSize: 8
//                 labelOff: "aut"
//                 labelOn: "man"
//                 switchBorderWidth: 1
//                 onSwitched: (checked, state) => {

//                             navigation.state = (modeBtn.state === "on") ? navigation.state = "manualMode" : "normalMode"
//                             if(navigation.state === "manualMode")
//                                 {
//                                     console.log("manual enable")
//                                     OwnPositionController.enableManualCOG(true)
//                                     OwnPositionController.enableManualInertial(true)
//                                     sendCogChanges()
//                                     sendInertialChanges()
//                                 }

//                             else if (navigation.state === "normalMode")
//                                 {
//                                     console.log("normal disable")
//                                     OwnPositionController.enableManualCOG(false)
//                                     OwnPositionController.enableManualInertial(false)
//                                     updateCOGData()
//                                     updateInertialData()
//                                 }


//                 }
//             }

//             Text {
//                 id: titlesection
//                 height: parent.height
//                 wrapMode: Text.WordWrap
//                 anchors.horizontalCenter: parent.horizontalCenter
//                 color: "#edf7fa"
//                 text: qsTr("NAVIGATION")
//                 font.pointSize: 14
//                 horizontalAlignment: Text.AlignHCenter
//                 verticalAlignment: Text.AlignVCenter
//                 font.family: "RobotoMedium"
//             }

//             Widgets.BaseButton {
//                 id: edit
//                 height: titlesection.height
//                 width: titlesection.height
//                 anchors.verticalCenter: titlesection.verticalCenter
//                 anchors.left: titlesection.right
//                 image: "qrc:///assets/icons/panels/track/edit.svg"
//                 anchors.leftMargin: 10
//                 backgroundColor: "transparent"
//                 backgroundColorDown: "transparent"
//                 borderColor: "transparent"
//                 borderColorDown: "transparent"
//                 visible: (modeBtn.state === "on") ? true : false
//                 checkable: true

//                 onToggled: {
//                     handleEditBtnClicked(edit.checked)
//                 }
//             }

//             Widgets.BaseButton {
//                 id: save
//                 height: titlesection.height
//                 width: titlesection.height
//                 anchors.verticalCenter: titlesection.verticalCenter
//                 anchors.left: edit.right
//                 image: "qrc:///assets/icons/panels/track/save.svg"
//                 anchors.leftMargin: 4
//                 backgroundColor: "transparent"
//                 backgroundColorDown: "transparent"
//                 borderColor: "transparent"
//                 borderColorDown: "transparent"
//                 visible: edit.checked === true


//                 onClicked: {

//                     handleSaveBtnClicked()

//                 }
//             }





//         }

//         GridLayout {
//             id: gridLayout
//             rowSpacing: navigation.height / 19
//             columnSpacing: navigation.width / 101
//             anchors.top: group.bottom
//             anchors.topMargin: parent.height / 6
//             anchors.horizontalCenter: rectangle.horizontalCenter
//             anchors.verticalCenter: rectangle.verticalCenter
//             flow: GridLayout.TopToBottom
//             rows: 2
//             columns: 3


//             OwnPositionItem {
//                 id: shipPitch
//                 Layout.preferredWidth: rectangle.width *.3 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 key: "Ship Pitch"
//                 subvalue: "°"
//                 fontSize: 20
//                 image: "qrc:///assets/icons/ownposition/shipPitch.svg"
//                 editingModeType: OwnPositionItem.EditModeType.TextField
//                 placeholder: "pitch"
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                         if(accepted)
//                                             shipPitch.value = parseFloat(txt).toFixed(2)

//                                      }

//             }

//             OwnPositionItem {
//                 id: shipRoll
//                 Layout.preferredWidth: rectangle.width *.3 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 key: "Ship Roll"
//                 subvalue: "°"
//                 fontSize: 20
//                 image: "qrc:///assets/icons/ownposition/shipRoll.svg"
//                 editingModeType: OwnPositionItem.EditModeType.TextField
//                 placeholder: "roll"
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                         if(accepted)
//                                             shipRoll.value = parseFloat(txt).toFixed(2)

//                                      }
//             }

//             OwnPositionItem {
//                 id: tHeading
//                 Layout.preferredWidth: rectangle.width *.4 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 imageSize: 48
//                 key: "True Heading"
//                 subvalue: "°"
//                 fontSize: 20
//                 image: "qrc:///assets/icons/ownposition/theading.svg"
//                 keyWidth: 192
//                 editingModeType: OwnPositionItem.EditModeType.TextField
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                         if(accepted)
//                                          {
//                                              tHeading.value  = parseFloat(txt).toFixed(2)
//                                              course.valueTxt = getCourse(parseFloat(txt))
//                                          }

//                                      }

//             }

//             OwnPositionItem {
//                 id: mHeading
//                 Layout.preferredWidth: rectangle.width *.4 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 imageSize: 48
//                 key: "Magnetic Heading"
//                 subvalue: "°"
//                 fontSize: 20
//                 image: "qrc:///assets/icons/ownposition/mheading.svg"
//                 keyWidth: 192
//                 editingModeType: OwnPositionItem.EditModeType.NoEdit
//             }

//             PanelCommons.PanelListItem {
//                 id: course
//                 Layout.preferredWidth: rectangle.width *.3 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 fontSize: 20
//                 keyColor: "#fff0cb"
//                 keyTxt: "Course"
//                 subvalueTxt: "°"
//                 placeholder: "course"
//                 /*
//                 editingModeType: OwnPositionItem.EditModeType.TextField
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.int3Digit}
//                 inputDefaultValue: "000"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                         if(accepted)
//                                             course.valueTxt = txt
//                                      }
//                                      */
//             }

//             PanelCommons.PanelListItem {
//                 id: speed
//                 Layout.preferredWidth: rectangle.width *.3 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 fontSize: 20
//                 keyTxt: "Speed"
//                 keyColor: "#fff0cb"
//                 placeholder: "speed"
//                 subvalueTxt: "kts"
//                 editingModeType: OwnPositionItem.EditModeType.TextField
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                         if(accepted)
//                                             speed.valueTxt = parseFloat(txt).toFixed(2)

//                                      }
//             }


//         }
//     }

//     function handleSaveBtnClicked()
//     {
//         saveChanges()
//         edit.toggle()
//     }

//     function handleEditBtnClicked(checked)
//     {
//         navigation.state = (checked) ? "editMode" : "manualMode"
// }

//     function saveChanges(){
//         shipRoll.saveChanges()
//         shipRoll.rotateIcon(parseFloat(shipRoll.value))
//         shipPitch.saveChanges()
//         shipPitch.rotateIcon(parseFloat(shipPitch.value))
//         tHeading.saveChanges()
//         tHeading.rotateIcon(parseFloat(tHeading.value))
//         mHeading.saveChanges()
//         speed.saveChanges()

//         sendCogChanges()
//         sendInertialChanges()

//         navigation.state = "manualMode"

//     }

//     function sendCogChanges()
//     {
//         if(speed.valueTxt !== unknownString)
//             cogDataModel.setSpeedKnots(parseFloat(speed.valueTxt))
//         if(tHeading.value !== unknownString)
//             cogDataModel.setTrueHeading(parseFloat(tHeading.value))
//         OwnPositionController.newManualCOG(cogDataModel)
//     }

//     function sendInertialChanges()
//     {
//         if(shipPitch.value !== unknownString)
//             inertialDataModel.setPitch(parseFloat(shipPitch.value))
//         if(shipRoll.value !== unknownString)
//             inertialDataModel.setRoll(parseFloat(shipRoll.value))

//         OwnPositionController.newManualInertial(inertialDataModel)

//     }

//     function updateInertialData()
//     {
//         if(navigation.state !== "manualMode" && navigation.state !== "editMode")
//         {
//             if(navigation.inertialData !== undefined && navigation.inertialData.hasOwnProperty("roll") && navigation.inertialData.roll !== undefined && navigation.inertialData.roll !== null)
//             {
//                 shipRoll.value = navigation.inertialData.roll.toFixed(2).toString()
//                 shipRoll.rotateIcon(navigation.inertialData.roll)
//             }
//             else{
//                 shipRoll.value = unknownString
//                 shipRoll.rotateIcon(0)
//             }


//             if(navigation.inertialData !== undefined && navigation.inertialData.hasOwnProperty("pitch") && navigation.inertialData.pitch !== undefined && navigation.inertialData.pitch !== null)
//             {
//                 shipPitch.value = navigation.inertialData.pitch.toFixed(2).toString()
//                 shipPitch.rotateIcon(navigation.inertialData.pitch)
//             }
//             else{
//                 shipPitch.value = unknownString
//                 shipPitch.rotateIcon(0)
//             }
//         }



//     }


//     function updateCOGData()
//     {
//         if(navigation.state !== "manualMode" && navigation.state !== "editMode")
//         {
//             if(navigation.cogData !== undefined && navigation.cogData.hasOwnProperty("trueHeading") && navigation.cogData.trueHeading !== undefined && navigation.cogData.trueHeading !== null)
//             {
//                 tHeading.value  = navigation.cogData.trueHeading.toFixed(2).toString()
//                 tHeading.rotateIcon(navigation.cogData.trueHeading)
//                 course.valueTxt = getCourse(navigation.cogData.trueHeading)

//             }
//             else{
//                 tHeading.value = unknownString
//                 course.valueTxt = unknownString
//                 tHeading.rotateIcon(0)

//             }

//             if(navigation.cogData !== undefined && navigation.cogData.hasOwnProperty("magneticHeading") && navigation.cogData.magneticHeading !== undefined && navigation.cogData.magneticHeading !== null)
//             {
//                 mHeading.value = navigation.cogData.magneticHeading.toFixed(2).toString()
//                 mHeading.rotateIcon(navigation.cogData.magneticHeading)
//             }
//             else{
//                 mHeading.value = unknownString
//                 mHeading.rotateIcon(0)

//             }


//             if(navigation.cogData !== undefined &&  navigation.cogData.hasOwnProperty("knots") && navigation.cogData.knots !== undefined && navigation.cogData.knots !== null)
//                 speed.valueTxt = navigation.cogData.knots.toFixed(2).toString()
//             else
//                 speed.valueTxt = unknownString


//         }



//     }


//     function clearInertialData()
//     {
//         if(navigation.state !== "manualMode" && navigation.state !== "editMode")
//         {
//             shipRoll.value=unknownString
//             shipPitch.value=unknownString
//         }


//     }

//     function clearCOGData()
//     {
//         if(navigation.state !== "manualMode" && navigation.state !== "editMode")
//         {
//             tHeading.value=unknownString
//             mHeading.value=unknownString
//             speed.valueTxt=unknownString
//             course.valueTxt=unknownString
//         }


//     }

//     function getCourse(theading)
//     {
//         let truncated = Math.trunc(theading)
//         let padded = String(truncated).padStart(3, '0')

//         return padded
//     }


//     states: [
//         State {
//             name: "editMode"

//             PropertyChanges {
//                 target: shipPitch
//                 editMode: true
//             }

//             PropertyChanges {
//                 target: shipRoll
//                 editMode: true
//             }

//             PropertyChanges {
//                 target: tHeading
//                 editMode: true
//             }

//             PropertyChanges {
//                 target: speed
//                 editMode: true
//             }

//         },

//         State {
//             name: "baseMode"

//             PropertyChanges {
//                 target: shipPitch
//                 editMode: false
//             }

//             PropertyChanges {
//                 target: shipRoll
//                 editMode: false
//             }

//             PropertyChanges {
//                 target: tHeading
//                 editMode: false
//             }

//             PropertyChanges {
//                 target: speed
//                 editMode: false
//             }

//         },

//         State {
//             name: "manualMode"
//             extend: "baseMode"

//         }
//     ]


//     CogData{
//         id:cogDataModel
//     }

//     InertialData{
//         id:inertialDataModel
//     }




// }
