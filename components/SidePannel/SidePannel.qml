import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import ShipArrivalController 1.0
import TrailersPredictionsController 1.0
import "ShipArrivalContent"
import "TrailersPredictionsContent"
import "../ui/"
import "WebComponent"

Rectangle {
    id: sidePanel
    width: 500
    height: parent.height
    color: Qt.lighter("#000f1f", 1.1)
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#000000" }
        GradientStop { position: 1.0; color: "#001122" }
    }

    property bool expanded: false
    property int currentTab: 0

    x: -width
    Behavior on x {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    ShipArrivalController {
        id: arrivalController
    }

    TrailersPredictionsController {
        id: trailerPredictions
    }

    SidePannelLip {
        id: handle
        visible: !sidePanel.expanded
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.right
        }
        onClicked: {
            sidePanel.expanded = true
            sidePanel.x = 0
        }
    }

    ColumnLayout {
        id: tabBar
        width: 80
        height: parent.height
        spacing: 20
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20

        Rectangle {
            height: 1
            color: "#444"
            width: parent.width
            Layout.topMargin: 10
        }

        Text {
            text: "Component"
            color: "#ccc"
            font.pixelSize: 14
            font.bold: true
        }

        // Tab Buttons
        Repeater {
            model: [
                { icon: "⛴️", label: "Ship Arrivals" },
                { icon: "📅", label: "Ship Arrivals D" },
                { icon: "⚙️", label: "Ship Arrivals DT" },
                { icon: "🧭", label: "Trailer Prediction" },
                { icon: "S" , label: "Level Selector" },
                { icon: "🖥️", label: "Ship Stowage" }
            ]
            delegate: Item {
                width: tabBar.width
                height: 70

                MouseArea {
                    anchors.fill: parent
                    onClicked: currentTab = index
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    width: parent.width

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: currentTab === index ? "white" : "transparent"
                        border.color: "white"
                        border.width: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: currentTab === index ? "#000" : "#fff"
                            font.pixelSize: 18
                        }
                    }

                    Text {
                        text: modelData.label
                        color: "white"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    Item {
        id: contentArea
        anchors {
            left: tabBar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 10
        }

        SidePannelArrContent {
            visible: currentTab === 0
            anchors.fill: parent
            controller: arrivalController
        }

        SidePannelCalendarContent {
            visible: currentTab === 1
            anchors.fill: parent
            width: parent.width
            controller: arrivalController
        }

        SidePannelCalendarTimeContent {
            visible: currentTab === 2
            anchors.fill: parent
            width: parent.width
            controller: arrivalController
        }

        TrailersPredictionsContent {
            visible: currentTab === 3
            anchors.fill: parent
            width: parent.width
            controller: trailerPredictions
        }

        LayersList {
            visible: currentTab === 4
            anchors.fill: parent
            anchors.margins: 2
            Component.onCompleted: {
                console.log("LayersList loaded with layerList:", LayerManager.layerList)
            }
        }

        SidePannelWebViewContent {
            visible: currentTab === 5
            anchors.fill: parent
            width: parent.width
        }

        Text {
            text: "✕"
            font.pixelSize: 16
            color: "#ffffff"
            visible: sidePanel.expanded
            anchors {
                top: parent.top
                right: parent.right
                margins: 10
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sidePanel.expanded = false
                    sidePanel.x = -sidePanel.width
                }
            }
        }
    }
}
