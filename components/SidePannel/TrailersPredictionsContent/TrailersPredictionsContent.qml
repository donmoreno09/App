import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import TrailersPredictionsController 1.0
import raise.singleton.language 1.0
import ".."

Item {
    id: root
    anchors.fill: parent

    // Styling properties
    property color backgroundColor: "#1e2f40"
    property color highlightColor: "#4CAF50"
    property color textColor: "white"
    property color borderColor: "#444"
    property color inputBackground: "#2c3e50"
    property color buttonColor: "#1565C0"

    required property TrailersPredictionsController controller

    // Automatic retranslation properties
    property string waitingTimePredictionTitle: qsTr("Waiting Time Prediction")
    property string trailerIdLabel: qsTr("Trailer ID:")
    property string enterIdPlaceholder: qsTr("Enter ID")
    property string calculatePredictionText: qsTr("Calculate Prediction")
    property string estimatedTimeTitle: qsTr("Estimated Time")
    property string readyText: qsTr("Ready")
    property string minuteText: qsTr(" min")
    property string hourText: qsTr(" hour")
    property string hoursText: qsTr(" hours")
    property string immediateAccessText: qsTr("Immediate access to the bay")
    property string shortWaitText: qsTr("Short wait - entry soon")
    property string moderateWaitText: qsTr("In queue - moderate wait")
    property string extendedWaitText: qsTr("Extended wait - consider alternatives")
    property string noDataAvailableText: qsTr("No data available")

    // Auto-retranslate when language changes
    function retranslateUi() {
        waitingTimePredictionTitle = qsTr("Waiting Time Prediction")
        trailerIdLabel = qsTr("Trailer ID:")
        enterIdPlaceholder = qsTr("Enter ID")
        calculatePredictionText = qsTr("Calculate Prediction")
        estimatedTimeTitle = qsTr("Estimated Time")
        readyText = qsTr("Ready")
        minuteText = qsTr(" min")
        hourText = qsTr(" hour")
        hoursText = qsTr(" hours")
        immediateAccessText = qsTr("Immediate access to the bay")
        shortWaitText = qsTr("Short wait - entry soon")
        moderateWaitText = qsTr("In queue - moderate wait")
        extendedWaitText = qsTr("Extended wait - consider alternatives")
        noDataAvailableText = qsTr("No data available")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Header
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: root.waitingTimePredictionTitle
                font {
                    pixelSize: 18
                    bold: true
                    family: "Arial"
                }
                color: textColor
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                height: 1
                color: borderColor
                Layout.fillWidth: true
            }
        }

        // Input Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.trailerIdLabel
                color: textColor
                font.pixelSize: 14
            }

            TextField {
                id: trailerIdInput
                Layout.fillWidth: true
                placeholderText: root.enterIdPlaceholder
                placeholderTextColor: "#444444"
                inputMethodHints: Qt.ImhDigitsOnly
                color: textColor
                font.pixelSize: 16
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    radius: 4
                    color: "#2a2a2a"
                    border.color: trailerIdInput.activeFocus ? highlightColor : borderColor
                    border.width: 1
                }

                validator: IntValidator { bottom: 1 }
            }
        }

        // Button
        Button {
            id: fetchButton
            text: root.calculatePredictionText
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.topMargin: 5
            enabled: trailerIdInput.text && !controller.isLoading

            background: Rectangle {
                radius: 6
                color: enabled ? buttonColor : Qt.darker(buttonColor, 1.5)
                border.color: borderColor
                border.width: 1
            }

            contentItem: Text {
                text: fetchButton.text
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }


            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.inputMethod.commit()
                    controller.fetchPredictionByTrailerId(parseInt(trailerIdInput.text))
                }
            }
        }

        // Loading Indicator
        BusyIndicator {
            Layout.alignment: Qt.AlignCenter
            running: controller.isLoading
            visible: controller.isLoading
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            Layout.topMargin: 10
        }

        // Results Section
        ColumnLayout {
            visible: !controller.isLoading && controller.prediction !== -1
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10

            SidePannelStatCard {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                icon: "⏱️"
                title: root.estimatedTimeTitle
                value: formatMinutes(controller.prediction)
            }

            Text {
                text: getStatusText(controller.prediction)
                color: textColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                leftPadding: 15
                rightPadding: 15
            }
        }

        // Error Message
        Text {
            visible: controller.prediction === -1 && !controller.isLoading && trailerIdInput.text
            text: root.noDataAvailableText
            color: "#F44336"
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 13
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }
    }

    function formatMinutes(minutes) {
        if (minutes === 0) return root.readyText
        if (minutes < 60) return minutes + root.minuteText

        const hours = Math.floor(minutes / 60)
        const mins = minutes % 60
        return mins === 0 ? hours + (hours > 1 ? root.hoursText : root.hourText)
                         : hours + "h " + mins + "min"
    }

    function getStatusText(minutes) {
        if (minutes === 0) return root.immediateAccessText
        if (minutes < 30) return root.shortWaitText
        if (minutes < 120) return root.moderateWaitText
        return root.extendedWaitText
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
