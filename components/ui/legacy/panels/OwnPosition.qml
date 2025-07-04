// import QtQuick
// import QtQuick.Controls

// import "../../basewidgets" as Widgets
// import qml.controllers.ownpositioncontroller 1.0


// Widgets.BaseScatter {



//     id: baseOwnPositionPanel
//     objectName: "baseOwnPositionPanel"
//     width: 250
//     height: baseOwnPositionPanelHeader.height + baseOwnPositionPanelbodyGNSS.height + baseOwnPositionPanelbodyCOG.height + baseOwnPositionButtonBar.height + baseOwnPositionPanel.margins*6
//     color: backgroundColor
//     opacity: 1.0
//     visible: true
//     minimizable: true
//     doTranslation: true
//     doScale: false
//     doRotation: false
//     doPress: false
//     clip: true


//     property real margins:4
//     property bool shipPovActive:false


//     signal ownPovActive(bool val)



//     property var defaultGNSS: [
//         {"key": "latitude", "value":""},
//         {"key": "longitude", "value":""},
//        // {"key": "Speed (kts)", "value":""},
//     ]

//     property var defaultCOG: [
//         {"key": "COG Speed (kts)", "value":""},
//         {"key": "COG Speed (kph)", "value":""},
//         {"key": "True Heading", "value":""},
//         {"key": "Magn. Heading", "value":""}

//     ]


//     property var defaultIntertialData: [
//         {"key": "Roll", "value":""},
//         {"key": "Pitch", "value":""},
//     ]


//     property color backgroundColor: "#f21f3154"
//     property color headerColor: "#f1101f3b"
//     property color borderColor: "#f1def3ff"
//     property color titleColor: "#f1def3ff"
//     property int borderWidth: 1
//     property string title: "Own Position Data"
//     property var gnssData
//     property var cogData
//     property var inertialData
//     property var radarStatus:({})
//     name: "Own Data"

//     Component.onCompleted: {
//         initDefault()
//     }

//     onShipPovActiveChanged: {
//         ownPovActive(baseOwnPositionPanel.shipPovActive)
//     }

//     function initDefault()
//     {
//         if (gnssItemModel.count <= 0)
//             for (let i in defaultGNSS)
//                 gnssItemModel.append(defaultGNSS[i])

//         if (cogItemModel.count <= 0)
//             for (let j in defaultCOG)
//                 cogItemModel.append(defaultCOG[j])
//        /*
//          * TO DO APPEND INTERTIAL DEFAULT DATA
//          */

//     }

//     Connections {
//         target: OwnPositionController
//         function onNewRadarStatus (data){

//            if(radarStatus[data.radar_id]=== undefined)
//            {
//                radarStatus[data.radar_id]=data
//                updateRadarStatus(data.radar_id)
//            }

//             if(data.time>radarStatus[data.radar_id].time)
//             {
//                radarStatus[data.radar_id]=data
//                updateRadarStatus(data.radar_id)

//             }


//         }






//         function onNewGNSSPosition (data){



//             if(gnssData===undefined)
//             {

//                 gnssData=data
//                 updateDataGNSS()
//             }
//             if(data.time>gnssData.time)
//             {

//                 //console.log("*********->UPDATING GNSS DATA")
//                 gnssData=data
//                 updateDataGNSS()

//             }

//         }

//         function onNewInertialData(data)
//         {

//             if(inertialData===undefined)
//             {
//                 inertialData=data
//                 updateDataInertial()
//             }

//             if(data.time>inertialData.time)
//             {
//                 inertialData=data
//                 updateDataInertial()
//             }
//         }

//         function onNewCourseOverGround (data){

//             //console.log("*****",data)

//             if(cogData===undefined)
//             {

//                 cogData=data
//                 updateDataCOG()
//             }
//             if(data.time>cogData.time)
//             {

//                 //console.log("*********->UPDATING COG DATA")
//                 cogData=data

//                 updateDataCOG()

//             }

//         }



//     }


//     Rectangle{

//         id: baseOwnPositionPanelbodyGNSS

//         width: parent.width
//         height: 65
//         anchors.top: baseOwnPositionPanelHeader.bottom
//         color: "transparent"

//         ListModel {
//             id: gnssItemModel

//         }

//         ScrollView
//         {
//             width: parent.width
//             height: parent.height

//             ListView {

//                 pressDelay: 1000
//                 orientation: ListView.Vertical
//                 flickableDirection: Flickable.VerticalFlick
//                 spacing: 4

//                 model: gnssItemModel
//                 delegate: Rectangle {

//                     width: baseOwnPositionPanelbodyGNSS.width
//                     height: 30
//                     color: "transparent"

//                     Text{

//                         id: keyItemModel
//                         text: qsTr(key.toLowerCase())
//                         width: parent.width*.5
//                         height: parent.height
//                         anchors.left: parent.left
//                         anchors.leftMargin: 6
//                         horizontalAlignment: Text.AlignLeft
//                         verticalAlignment: Text.AlignVCenter
//                         font.capitalization: Font.Capitalize
//                         font.bold: true
//                         font.pointSize: 10
//                         color: titleColor
//                         smooth: true
//                         antialiasing: true


//                     }

//                     Text{

//                         id: valItemModel
//                         text: qsTr(value.toLowerCase())
//                         width: parent.width*.5
//                         height: parent.height
//                         anchors.left: keyItemModel.right
//                         anchors.leftMargin: 2
//                         horizontalAlignment: Text.AlignLeft
//                         verticalAlignment: Text.AlignVCenter
//                         font.capitalization: Font.Capitalize
//                         font.pointSize: 8
//                         color: titleColor
//                         opacity: 0.8
//                         smooth: true
//                         antialiasing: true


//                     }


//                 }
//             }

//         }

//     }

//     Rectangle{
//         id: baseOwnPositionPanelbodyCOG

//         width: parent.width
//         height: 150
//         anchors.top: baseOwnPositionPanelbodyGNSS.bottom
//        // anchors.topMargin: 10
//         color: "transparent"

//         ListModel {
//             id: cogItemModel

//         }

//         ScrollView
//         {
//             width: parent.width
//             height: parent.height

//             ListView {

//                 pressDelay: 1000
//                 orientation: ListView.Vertical
//                 flickableDirection: Flickable.VerticalFlick
//                 spacing: 4

//                 model: cogItemModel
//                 delegate: Rectangle {

//                     width: baseOwnPositionPanelbodyCOG.width
//                     height: 30
//                     color: "transparent"

//                     Text{

//                         id: keyModel
//                         text: qsTr(key.toLowerCase())
//                         width: parent.width*.5
//                         height: parent.height
//                         anchors.left: parent.left
//                         anchors.leftMargin: 6
//                         horizontalAlignment: Text.AlignLeft
//                         verticalAlignment: Text.AlignVCenter
//                         font.capitalization: Font.Capitalize
//                         font.bold: true
//                         font.pointSize: 10
//                         color: titleColor
//                         smooth: true
//                         antialiasing: true


//                     }

//                     Text{

//                         id: valModel
//                         text: qsTr(value.toLowerCase())
//                         width: parent.width*.5
//                         height: parent.height
//                         anchors.left: keyModel.right
//                         anchors.leftMargin: 2
//                         horizontalAlignment: Text.AlignLeft
//                         verticalAlignment: Text.AlignVCenter
//                         font.capitalization: Font.Capitalize
//                         font.pointSize: 8
//                         color: titleColor
//                         opacity: 0.8
//                         smooth: true
//                         antialiasing: true


//                     }


//                 }
//             }

//         }
// }

//     Rectangle{
//         id: baseOwnPositionButtonBar
//         width: parent.width
//         height: 40
//         anchors.top: baseOwnPositionPanelbodyCOG.bottom
//         color: "transparent"
//         anchors.leftMargin: baseOwnPositionPanel.margins
//         anchors.rightMargin: baseOwnPositionPanel.margins
//         anchors.topMargin: baseOwnPositionPanel.margins
//         anchors.bottomMargin: 10 //baseOwnPositionPanel.margins


//         Button{
//             id: ownPovButton
//             text: "follow"
//             anchors.centerIn: parent
//             anchors.fill: parent
//             flat:true
//             checkable: true
//             visible: ((gnssData && cogData) || checked) ? true : false
//             contentItem:
//                 Rectangle{
//                             color: headerColor
//                             Text {
//                                 anchors.centerIn: parent
//                                 anchors.fill: parent
//                                 text: ownPovButton.text
//                                 horizontalAlignment: Text.AlignHCenter
//                                 verticalAlignment: Text.AlignVCenter
//                                 font.capitalization: Font.Capitalize
//                                 font.bold: true
//                                 font.pointSize: 8
//                                 color: (ownPovButton.down || ownPovButton.hovered || ownPovButton.checked) ? "#80E0FF": titleColor
//                                 smooth: true
//                                 antialiasing: true
//                             }
//                 }

//             background: Rectangle {
//                     border.color: ownPovButton.down || ownPovButton.hovered ? "transparent" : "transparent"
//                     color: ownPovButton.down || ownPovButton.hovered ? "transparent" : "transparent"

//                 }

//             onToggled: {
//                 baseOwnPositionPanel.shipPovActive = checked

//                 if(checked)
//                 {
//                     ownPovButton.text="Unfollow"

//                 }else

//                 {
//                      ownPovButton.text="Follow"
//                 }

//                 OwnPositionController.ownPovEnable(checked)


//             }



//         }


//     }

//     Rectangle{
//         id: baseOwnPositionPanelHeader
//         width: parent.width
//         height: 40
//         anchors.top: parent.top
//         color: "transparent"

//         Rectangle{

//             id: headerTitle
//             color: headerColor
//             anchors.centerIn: parent
//             anchors.fill: parent
//             anchors.leftMargin: baseOwnPositionPanel.margins
//             anchors.rightMargin: baseOwnPositionPanel.margins
//             anchors.topMargin: baseOwnPositionPanel.margins
//             anchors.bottomMargin: baseOwnPositionPanel.margins


//             Text{

//                 id: headerTitleLabel
//                 text: qsTr(title.toLowerCase())
//                 anchors.fill: parent
//                 anchors.centerIn: parent
//                 anchors.leftMargin: 6
//                 horizontalAlignment: Text.AlignLeft
//                 verticalAlignment: Text.AlignVCenter
//                 font.capitalization: Font.AllUppercase
//                 font.bold: true
//                 font.pointSize: 12
//                 font.letterSpacing: 2
//                 color: titleColor
//                 smooth: true
//                 antialiasing: true

//             }

//         }


//     }



//     function updateDataGNSS()
//     {


//         gnssItemModel.clear()

//         var keys = Object.keys(baseOwnPositionPanel.gnssData)

//         for (var i = 0; i < keys.length; i++) {
//             let val = baseOwnPositionPanel.gnssData[keys[i]]
//             let listModelVal = baseOwnPositionPanel.parseValueGNSS(keys[i], val)

//         if(listModelVal)
//             gnssItemModel.append(listModelVal)


//         }

//     }



//     function updateRadarStatus(id)
//     {

//         console.log("STATOOOOO",radarStatus[id].global_system_status)
//         /*

//           TO DO


//           */
//     }

//     function updateDataInertial()
//     {


//     /*
//       TO DO


//         gnssItemModel.clear()

//         var keys = Object.keys(baseOwnPositionPanel.gnssData)

//         for (var i = 0; i < keys.length; i++) {
//             let val = baseOwnPositionPanel.gnssData[keys[i]]
//             let listModelVal = baseOwnPositionPanel.parseValueGNSS(keys[i], val)

//         if(listModelVal)
//             gnssItemModel.append(listModelVal)


//         }*/

//     }

//     function parseValueGNSS(key, value)
//     {

//         let res = []
//         switch (key)
//         {/*
//             case "time":
//             {
//                 let k = "timestamp"
//                 let date = new Date(value);

//                 let v = date.toLocaleString({ "day": "2-digit", "month": "2-digit", "year": "numeric",
//                                           "hour": "2-digit", "minute": "2-digit", "second": "2-digit"});

//                 res.push({"key": k, "value": v})

//                 break
//             }

//             */

//             case "latitude":
//             {
//                 let k="latitude"
//                 let v= value.toFixed(4).toString()
//                 res.push({"key": k, "value": v})
//                 break
//             }

//             case "longitude":
//             {
//                 let k="longitude"
//                 let v= value.toFixed(4).toString()
//                 res.push({"key": k, "value": v})
//                 break
//             }
// /*
//             case "speedKnots":
//             {
//                 let k="Speed (kts)"
//                 let v= value.toFixed(2)
//                 res.push({"key": k, "value": v})
//                 break
//             }


//             case "altitude":
//             {
//                 let k="altitude"
//                 let v= value.toFixed(4).toString()
//                 res.push({"key": k, "value": v})
//                 break
//             }

//             case "direction":
//             {
//                 let k="direction"
//                 res.push({"key": k, "value": value})
//                 break
//             }


//             case "courseHeading":
//             {
//                 let k="Course"
//                 let v= value.toFixed(2).toString()
//                 res.push({"key": k, "value": v})
//                 break
//             }

//             case "numberOfSatellites":
//             {
//                 let k="Number of Sats"
//                 res.push({"key": k, "value": value.toString()})
//                 break
//             }

//             case "fixType":
//             {
//                 let k="Fix Type"
//                 res.push({"key": k, "value": value})
//                 break
//             }

//             case "HDOP":
//             {
//                 let k="HDOP"
//                 let v= value.toFixed(2)
//                 res.push({"key": k, "value": v})
//                 break
//             }

// */

//         }


//         if (res.length > 0)
//             return res

//         return null


//     }



//     function updateDataCOG()
//     {


//         cogItemModel.clear()

//         var keys = Object.keys(baseOwnPositionPanel.cogData)

//         for (var i = 0; i < keys.length; i++) {
//             let val = baseOwnPositionPanel.cogData[keys[i]]
//             let listModelVal = baseOwnPositionPanel.parseValueCOG(keys[i], val)

//         if(listModelVal)
//             cogItemModel.append(listModelVal)


//         }

//     }

//     function parseValueCOG(key, value)
//     {

//         let res = []
//         switch (key)
//         {
//             //Switchabili knots e kph
//             case "knots":
//             {

//                 //console.log("***** KNOTS ",value)
//                 let k="COG Speed (kts)"
//                 let v= value.toFixed(4)
//                 res.push({"key": k, "value": v})
//                 break
//             }

//             case "kph":
//             {

//                 //console.log("***** KPH ",value)
//                 let k="COG Speed (kph)"
//                 let v= value.toFixed(4)
//                 res.push({"key": k, "value": v})
//                 break
//             }



//             case "trueHeading":
//             {
//                 let k="True Heading"
//                 let v= value.toFixed(4)
//                 res.push({"key": k, "value": v})
//                 break
//             }

//             case "magneticHeading":
//             {
//                 let k="Magn. Heading"
//                 let v= value.toFixed(4)
//                 res.push({"key": k, "value": v})
//                 break
//             }




//         }


//         if (res.length > 0)
//             return res

//         return null


//     }

// }
