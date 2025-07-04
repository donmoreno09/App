// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts

// import "../../../qtds" as QTDSComponents
// import "../../panels/commons" as PanelCommons
// import "../../../basewidgets" as Widgets
// import "../../commons" as UiWidgets
// import "../../../js/regexExpressions.js" as RegExp

// import qml.controllers.ownpositioncontroller 1.0
// import qml.models.ownposition.gnss 1.0

// Item {
//     id: ownship
//     width: 265
//     height: 195

//     property string unknownString: "unk"
//     property var gnssData

//     state: "baseMode"

//     Component.onCompleted: {

//         clearData()

//     }

//     Connections{
//         target: OwnPositionController

//         function onNewGNSSPosition (data){
//             if (data.isManual())
//                 return

//             if(gnssData===undefined)
//             {
//                 gnssData=data
//                 clearData()
//             }

//             if(data.time>gnssData.time)
//             {
//                 gnssData=data
//                 updateData()

//             }

//         }


//     }

//     QTDSComponents.RectangleItem {
//         id: rectangle
//         radius: 0
//         anchors.fill: parent
//         anchors.centerIn: parent
//         fillColor: "#173060"
//         strokeWidth: -1
//         adjustBorderRadius: true

//         QTDSComponents.GroupItem {
//             id: group
//             anchors.top: parent.top
//             anchors.horizontalCenter: parent.horizontalCenter
//             anchors.topMargin: ownship.height / 13
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

//                             ownship.state = (modeBtn.state === "on") ? ownship.state = "manualMode" : "normalMode"
//                             if(ownship.state === "manualMode")
//                                 {
//                                     OwnPositionController.enableManualGNSSPosition(true)
//                                     sendChanges()
//                                 }


//                             else if (ownship.state === "normalMode")
//                                 {
//                                     OwnPositionController.enableManualGNSSPosition(false)
//                                     updateData()
//                                 }


//                 }
//             }


//             Text {
//                 id: titlesection
//                 height: parent.height
//                 wrapMode: Text.WordWrap
//                 anchors.horizontalCenter: parent.horizontalCenter
//                 color: "#edf7fa"
//                 text: qsTr("OWNSHIP")
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
//             anchors.top: group.bottom
//             anchors.topMargin: parent.height / 6
//             anchors.horizontalCenter: rectangle.horizontalCenter
//             anchors.verticalCenter: rectangle.verticalCenter
//             rowSpacing: ownship.height / 19

//             rows: 2
//             columns: 1

//             PanelCommons.PanelListItem {
//                 id: lat
//                 Layout.preferredWidth: rectangle.width*.92
//                 Layout.preferredHeight: rectangle.height *.2
//                 Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
//                 keyColor: "#fff0cb"
//                 keyTxt: "Lat"
//                 placeholder: "lat"
//                 fontSize: 20
//                 editingModeType: PanelCommons.PanelListItem.EditModeType.TextField
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 //inputValidator: DoubleValidator{notation:DoubleValidator.StandardNotation; decimals: 4}
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                          if(accepted)
//                                             lat.valueTxt = parseFloat(txt).toFixed(4)

//                                      }
//             }

//             PanelCommons.PanelListItem {
//                 id: lon

//                 Layout.preferredWidth: rectangle.width*.92
//                 Layout.preferredHeight: rectangle.height *.2
//                 Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
//                 keyColor: "#fff0cb"
//                 keyTxt: "Lon"
//                 placeholder: "lon"
//                 fontSize: 20
//                 editingModeType: PanelCommons.PanelListItem.EditModeType.TextField
//                 inputMethodHints: Qt.ImhFormattedNumbersOnly
//                 //inputValidator: DoubleValidator{notation:DoubleValidator.StandardNotation; decimals: 4}
//                 inputValidator: RegularExpressionValidator{regularExpression: RegExp.floatAndInt}
//                 inputDefaultValue: "0.0"
//                 onTextFieldAccepted: (txt, accepted) => {

//                                          if(accepted)
//                                             lon.valueTxt = parseFloat(txt).toFixed(4)

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
//         ownship.state = (checked) ? "editMode" : "manualMode"
//     }

//     function saveChanges(){
//         lat.saveChanges()
//         lon.saveChanges()

//         sendChanges()
//         ownship.state = "manualMode"

//     }

//     function sendChanges()
//     {

//         if(lat.valueTxt !== unknownString)
//             gnssPositionModel.setLatitude(parseFloat(lat.valueTxt))
//         if(lon.valueTxt !== unknownString)
//             gnssPositionModel.setLongitude(parseFloat(lon.valueTxt))

//         OwnPositionController.newManualGNSSPosition(gnssPositionModel)

//     }

//     function updateData()
//     {

//         if(ownship.state !== "manualMode" && ownship.state !== "editMode")
//         {
//             if(ownship.gnssData!== undefined && ownship.gnssData.hasOwnProperty("longitude") && ownship.gnssData.longitude !== undefined && ownship.gnssData.longitude !== null)
//                 lon.valueTxt = ownship.gnssData.longitude.toFixed(4).toString()
//             else{
//                 lon.valueTxt = unknownString
//             }

//             if(ownship.gnssData!== undefined && ownship.gnssData.hasOwnProperty("latitude") && ownship.gnssData.latitude !== undefined && ownship.gnssData.latitude !== null)
//                 lat.valueTxt = ownship.gnssData.latitude.toFixed(4).toString()
//             else{
//                 lat.valueTxt = unknownString
//             }
//         }

//     }

//     function clearData()
//     {
//         if(ownship.state !== "manualMode" && ownship.state !== "editMode")
//         {
//             lon.valueTxt=unknownString
//             lat.valueTxt=unknownString
//         }


//     }

//     states: [
//         State {
//             name: "editMode"

//             PropertyChanges {
//                 target: lat
//                 editMode: true
//             }

//             PropertyChanges {
//                 target: lon
//                 editMode: true
//             }

//         },

//         State {
//             name: "baseMode"

//             PropertyChanges {
//                 target: lat
//                 editMode: false
//             }

//             PropertyChanges {
//                 target: lon
//                 editMode: false
//             }


//         },


//         State {
//             name: "manualMode"
//             extend: "baseMode"

//         }
//     ]



//     GnssPosition{
//         id: gnssPositionModel
//     }

// }
