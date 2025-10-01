import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0
import App.Features.SidePanel 1.0
import App.Features.TruckArrival 1.0
import App.Features.Language 1.0

PanelTemplate {
    id: root
    title.text: (TranslationManager.revision, qsTr("Truck Arrivals"))

    // OLD DESIGN COLORS
    readonly property color buttonColor: "#1565C0"
    readonly property color buttonHoverColor: Qt.darker(buttonColor, 1.2)
    readonly property color disabledColor: "#1D2B4A"

    TruckArrivalModel { id: arrivalsModel }
    TruckArrivalController {
        id: controller
        model: arrivalsModel
    }

    content: ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Loading indicator - EXACTLY like old code
        BusyIndicator {
            Layout.alignment: Qt.AlignCenter
            running: controller.isLoading
            visible: controller.isLoading
            Layout.fillHeight: true
        }

        // Content - only visible when NOT loading
        ColumnLayout {
            visible: !controller.isLoading
            spacing: 20
            Layout.fillWidth: true

            // Title - EXACTLY like old code
            Text {
                text: (TranslationManager.revision, qsTr("Truck Arrivals"))
                font.pixelSize: 20
                font.bold: true
                font.family: Theme.typography.familySans
                color: Theme.colors.text
                Layout.alignment: Qt.AlignHCenter
            }

            // Divider - EXACTLY like old code
            Rectangle {
                height: 1
                color: Theme.colors.secondary500
                Layout.fillWidth: true
            }

            // Stat Cards - using REFACTORED component
            ArrivalStatsCard {
                icon: "⏱️"
                title: (TranslationManager.revision, qsTr("Next Hour"))
                value: controller.currentHourCount +
                       (controller.currentHourCount === 1 ?
                        (TranslationManager.revision, qsTr(" truck")) :
                        (TranslationManager.revision, qsTr(" trucks")))
                isLoading: controller.isLoading
            }

            ArrivalStatsCard {
                icon: "📅"
                title: (TranslationManager.revision, qsTr("Today"))
                value: controller.todayCount +
                       (controller.todayCount === 1 ?
                        (TranslationManager.revision, qsTr(" truck")) :
                        (TranslationManager.revision, qsTr(" trucks")))
                isLoading: controller.isLoading
            }

            // Spacer - EXACTLY like old code
            Item {
                Layout.fillHeight: true
            }

            // Button - EXACTLY like old code with custom MouseArea
            Button {
                id: fetchButton
                text: (TranslationManager.revision, qsTr("Fetch Arrivals"))
                enabled: !controller.isLoading
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                background: Rectangle {
                    id: buttonBg
                    radius: Theme.radius.md
                    color: fetchButton.enabled ? root.buttonColor : root.disabledColor
                    border.color: Theme.colors.secondary500
                    border.width: Theme.borders.b1
                    opacity: fetchButton.enabled ? 0.95 : 0.6

                    // OLD STYLE: Manual hover effect with MouseArea
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onPressed: {
                            if (fetchButton.enabled) {
                                buttonBg.color = root.buttonHoverColor
                            }
                        }

                        onReleased: {
                            if (fetchButton.enabled) {
                                buttonBg.color = root.buttonColor
                            }
                        }

                        onEntered: {
                            if (fetchButton.enabled) {
                                buttonBg.opacity = 1.0
                            }
                        }

                        onExited: {
                            if (fetchButton.enabled) {
                                buttonBg.opacity = 0.95
                                buttonBg.color = root.buttonColor
                            }
                        }

                        onClicked: {
                            if (fetchButton.enabled) {
                                controller.fetchAllBasicData()
                            }
                        }
                    }
                }

                contentItem: Text {
                    text: fetchButton.text
                    font.pixelSize: Theme.typography.fontSize175
                    font.family: Theme.typography.familySans
                    color: Theme.colors.white500
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Component.onCompleted: controller.fetchAllBasicData()
}
