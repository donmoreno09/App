import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import ShipArrivalController 1.0
import TrailersPredictionsController 1.0
import "ShipArrivalContent"
import "TrailersPredictionsContent"
import "../ui/"
import "WebComponent"
import raise.singleton.language 1.0

Rectangle {
    id: sidePanel
    width: 500
    height: parent.height
    color: "#f21f3154"
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#f21f3154" }
        GradientStop { position: 1.0; color: "#0F1F35" }
    }

    property bool expanded: false
    property int currentTab: 0

    // Automatic retranslation properties
    property string componentLabel: qsTr("Component")
    property string truckArrivalsLabel: qsTr("Truck Arrivals")
    property string truckArrivalsDLabel: qsTr("Truck Arrivals D")
    property string truckArrivalsDTLabel: qsTr("Truck Arrivals DT")
    property string trailerPredictionLabel: qsTr("Trailer Prediction")
    property string levelSelectorLabel: qsTr("Level Selector")
    property string shipStowageLabel: qsTr("Ship Stowage")

    // Auto-retranslate when language changes
    function retranslateUi() {
        componentLabel = qsTr("Component")
        truckArrivalsLabel = qsTr("Truck Arrivals")
        truckArrivalsDLabel = qsTr("Truck Arrivals D")
        truckArrivalsDTLabel = qsTr("Truck Arrivals DT")
        trailerPredictionLabel = qsTr("Trailer Prediction")
        levelSelectorLabel = qsTr("Level Selector")
        shipStowageLabel = qsTr("Ship Stowage")
    }

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
            text: sidePanel.componentLabel
            color: "#ccc"
            font.pixelSize: 14
            font.bold: true
        }

        // Tab Buttons
        Repeater {
            model: [
                { icon: "🚚️", label: sidePanel.truckArrivalsLabel },
                { icon: "📅", label: sidePanel.truckArrivalsDLabel },
                { icon: "⚙️", label: sidePanel.truckArrivalsDTLabel },
                { icon: "🧭", label: sidePanel.trailerPredictionLabel },
                { icon: "S" , label: sidePanel.levelSelectorLabel },
                { icon: "🖥️", label: sidePanel.shipStowageLabel }
            ]
            delegate: Item {
                width: tabBar.width
                height: 70

                MouseArea {
                    id: tabMouseArea
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
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
                        color: {
                            if (currentTab === index) return "#FFFFFF"
                            if (tabMouseArea.containsMouse) return "#404040"
                            return "transparent"
                        }
                        border.color: currentTab === index ? "#FFFFFF" : "#666666"
                        border.width: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: {
                                if (currentTab === index) return "#000000"
                                if (tabMouseArea.containsMouse) return "#FFFFFF"
                                return "#CCCCCC"
                            }
                            font.pixelSize: 18
                        }
                    }

                    Text {
                        text: modelData.label
                        color: currentTab === index ? "#FFFFFF" : "#CCCCCC"
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
            visible: currentTab === 0 && arrivalController
            anchors.fill: parent
            controller: arrivalController
        }

        SidePannelCalendarContent {
            visible: currentTab === 1 && arrivalController
            anchors.fill: parent
            width: parent.width
            controller: arrivalController
        }

        SidePannelCalendarTimeContent {
            visible: currentTab === 2 && arrivalController
            anchors.fill: parent
            width: parent.width
            controller: arrivalController
        }

        TrailersPredictionsContent {
            visible: currentTab === 3 && trailerPredictions
            anchors.fill: parent
            width: parent.width
            controller: trailerPredictions
        }

        LayersList {
            visible: currentTab === 4
            anchors.fill: parent
            anchors.margins: 2

            onRequestSidepanelOpen: {
                sidePanel.expanded = true
                sidePanel.x = 0
                currentTab = 4
            }

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

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            sidePanel.retranslateUi()
        }

        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
