import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import ShipArrivalController 1.0
import ".."
import raise.singleton.language 1.0

ColumnLayout {
    id: root
    spacing: 20
    anchors.fill: parent

    property color backgroundColor: "#1e2f40"
    property color highlightColor: "#4CAF50"
    property color textColor: "white"
    property color borderColor: "#444"
    property color disabledColor: "#1D2B4A"

    required property ShipArrivalController controller

    // Automatic retranslation properties
    property string truckArrivalsTitle: qsTr("Truck Arrivals")
    property string nextHourTitle: qsTr("Next Hour")
    property string todayTitle: qsTr("Today")
    property string fetchArrivalsText: qsTr("Fetch Arrivals")
    property string truckSingular: qsTr(" truck")
    property string truckPlural: qsTr(" trucks")

    // Auto-retranslate when language changes
    function retranslateUi() {
        truckArrivalsTitle = qsTr("Truck Arrivals")
        nextHourTitle = qsTr("Next Hour")
        todayTitle = qsTr("Today")
        fetchArrivalsText = qsTr("Fetch Arrivals")
        truckSingular = qsTr(" truck")
        truckPlural = qsTr(" trucks")
    }

    onVisibleChanged: {
        if (visible && !controller.isLoading) {
            controller.fetchAllArrivalData()
        }
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        running: controller.isLoading
        visible: controller.isLoading
        Layout.fillHeight: true
    }

    ColumnLayout {
        visible: !controller.isLoading
        spacing: 20
        Layout.fillWidth: true

        Text {
            text: root.truckArrivalsTitle
            font.pixelSize: 20
            font.bold: true
            font.family: "Arial"
            color: textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            height: 1
            color: borderColor
            Layout.fillWidth: true
        }

        SidePannelStatCard {
            icon: "⏱️"
            title: root.nextHourTitle
            value: controller.currentHourArrivalCount +
                   (controller.currentHourArrivalCount === 1 ? root.truckSingular : root.truckPlural)
        }

        SidePannelStatCard {
            icon: "📅"
            title: root.todayTitle
            value: controller.todayArrivalCount +
                   (controller.todayArrivalCount === 1 ? root.truckSingular : root.truckPlural)
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            text: root.fetchArrivalsText
            enabled: !controller.isLoading
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            background: Rectangle {
                radius: 8
                color: enabled ? "#1565C0" : disabledColor
                border.color: borderColor
                border.width: 1
                opacity: enabled ? 0.95 : 0.6

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onPressed: parent.color = Qt.darker("#1565C0", 1.2)
                    onReleased: parent.color = "#1565C0"
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.95
                }
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: controller.fetchAllArrivalData()
        }
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            root.retranslateUi()
        }

        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
