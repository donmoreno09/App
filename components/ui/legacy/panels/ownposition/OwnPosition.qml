// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts

// import "../../../basewidgets" as Widgets

// import qml.controllers.ownpositioncontroller 1.0


// Item {
//     id: root
//     width: parent.width
//     height: parent.height *.18
//     anchors.top: parent.top

//     property bool shipPovActive:false
//     signal ownPovActive(bool val)

//     Component.onCompleted: {
//     }

//     onShipPovActiveChanged: {
//         ownPovActive(root.shipPovActive)
//     }


//     RowLayout {
//         id: rowLayout
//         anchors.fill: parent
//         spacing: 0


//         OwnShipSection {
//             id: ownShipSection
//             Layout.preferredWidth: root.width *.14
//             Layout.preferredHeight: root.height

//         }

//         OwnNavigationSection {
//             id: navigationSection
//             Layout.preferredWidth: root.width *.53
//             Layout.preferredHeight: root.height


//         }

//         OwnEquipmentSection {
//             id: equipmentSection
//             Layout.preferredWidth: root.width *.33
//             Layout.preferredHeight: root.height


//         }

//     }

//     Widgets.BaseButton{

//         id: followButton
//         width: parent.width *.05
//         height: parent.height *.2
//         anchors.horizontalCenter: root.horizontalCenter
//         anchors.top: root.bottom
//         anchors.topMargin: parent.height *.05
//         text: "follow"
//         backgroundColor: "#121e47"
//         backgroundColorDown: "#123155"
//         labelColor: "#edf7fa"
//         labelColorDown: "#ffffff"
//         labelBoldDown: true
//         borderRadius: 2
//         font.pointSize: 14
//         checkable: true
//         visible: true//((ownShipSection.gnssData && navigationSection.cogData) || checked) ? true : false


//         onToggled: {
//             root.shipPovActive = checked

//             if(checked)
//             {
//                 followButton.text="Unfollow"

//             }else

//             {
//                  followButton.text="Follow"
//             }

//             OwnPositionController.ownPovEnable(checked)


//         }

//     }
// }
