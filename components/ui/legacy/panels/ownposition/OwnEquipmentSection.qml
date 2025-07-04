
// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts

// import "../../../qtds" as QTDSComponents
// import "../../../uiwidgets/panels/commons" as PanelCommons
// import "../../../basewidgets" as Widgets
// import qml.eradar.definitions.status 1.0
// import qml.controllers.ownpositioncontroller 1.0


// Item {
//     id: equipment
//     width: 640
//     height: 195

//     property string unknownString: "unk"
//     property var radarStatus:({})


//     Component.onCompleted: {
//         clearRadarStatus()
//     }

//     Connections {
//         target: OwnPositionController

//         function onNewRadarStatus(data){
//            if(radarStatus[data.radar_id]=== undefined)
//            {
//                radarStatus[data.radar_id]=data
//                clearRadarStatus(data.radar_id)
//            }

//             if(data.time>radarStatus[data.radar_id].time)
//             {
//                radarStatus[data.radar_id]=data
//                updateRadarStatus(data.radar_id)

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
//             anchors.topMargin: equipment.height / 13
//             width: parent.width
//             height: parent.height*.15

//             Text {
//                 id: titlesection
//                 height: parent.height
//                 wrapMode: Text.WordWrap
//                 color: "#edf7fa"
//                 text: qsTr("EQUIPMENT")
//                 font.pointSize: 14
//                 anchors.horizontalCenter: parent.horizontalCenter
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
//                 anchors.leftMargin: 15
//                 backgroundColor: "transparent"
//                 backgroundColorDown: "transparent"
//                 borderColor: "transparent"
//                 borderColorDown: "transparent"

//             }



//         }

//         GridLayout {
//             id: gridLayout
//             anchors.top: group.bottom
//             anchors.topMargin: parent.height / 6
//             anchors.horizontalCenter: rectangle.horizontalCenter
//             anchors.verticalCenter: rectangle.verticalCenter
//             rowSpacing: equipment.height / 19
//             columnSpacing: equipment.width / 101
//             flow: GridLayout.TopToBottom
//             rows: 2
//             columns: 2

//             OwnPositionItem {
//                 id: radar1
//                 height: 37
//                 Layout.preferredWidth: rectangle.width *.48 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 imageSize: 25
//                 value: ""//"Operating"
//                 //dropShadowcolor: "#8000fc4a"
//                 valueColor: "#edf7fa"
//                 fontSize: 20
//                 key: "RADAR #1"
//                 image: "qrc:///assets/icons/panels/track/info.svg"
//             }

//             OwnPositionItem {
//                 id: radar2
//                 Layout.preferredWidth: rectangle.width *.48 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 imageSize: 25
//                 value: ""//"Operating"
//                 //dropShadowcolor: "#8000fc4a"
//                 valueColor: "#edf7fa"
//                 fontSize: 20
//                 key: "RADAR #2"
//                 image: "qrc:///assets/icons/panels/track/info.svg"
//             }

//             OwnPositionItem {
//                 id: weapon1
//                 imageSize: 25
//                 Layout.preferredWidth: rectangle.width *.48 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 value: ""//"Operating"
//                 //dropShadowcolor: "#8000fc4a"
//                 valueColor: "#edf7fa"
//                 fontSize: 20
//                 key: "WEAPON #1"
//                 image: "qrc:///assets/icons/panels/track/info.svg"
//             }

//             OwnPositionItem {
//                 id: weapon2
//                 imageSize: 25
//                 Layout.preferredWidth: rectangle.width *.48 - gridLayout.columnSpacing
//                 Layout.preferredHeight: rectangle.height *.2
//                 value: ""//"Operating"
//                 //dropShadowcolor: "#8000fc4a"
//                 valueColor: "#edf7fa"
//                 fontSize: 20
//                 key: "WEAPON #2"
//                 image: "qrc:///assets/icons/panels/track/info.svg"

//             }
//         }
//     }


//     function updateRadarStatus(id)
//     {

//         radar1.value=EGlobalSystemStatus.getStringFromValue((radarStatus[id].global_system_status));//(radarStatus[id].global_system_status)
//         radar1.key=id
//     }

//     function clearRadarStatus()
//     {
//         radar1.value = unknownString
//         radar2.value = unknownString
//         weapon1.value = unknownString
//         weapon2.value = unknownString
//     }


// }
