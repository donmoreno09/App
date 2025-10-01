import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.TruckArrival 1.0

import "components" as Local

PanelTemplate {
    id: root

    title.text: (TranslationManager.revision, qsTr("Ship Arrivals"))

    // Create controller
    TruckArrivalController {
        id: controller
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.s6
            anchors.margins: Theme.spacing.s4

            // Loading indicator
            BusyIndicator {
                Layout.alignment: Qt.AlignCenter
                running: controller.isLoading
                visible: controller.isLoading
            }

            // Error message
            Rectangle {
                visible: controller.lastError !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: errorText.implicitHeight + Theme.spacing.s4 * 2
                color: Theme.colors.error100
                radius: Theme.radius.md
                border.width: Theme.borders.b1
                border.color: Theme.colors.error500

                Text {
                    id: errorText
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4
                    text: controller.lastError
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize150
                    color: Theme.colors.error700
                    wrapMode: Text.WordWrap
                }
            }

            // Section 1: Basic Stats
            ColumnLayout {
                visible: !controller.isLoading
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Quick Overview"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Local.ArrivalStatsCard {
                    Layout.fillWidth: true
                    icon: "⏱️"
                    title: (TranslationManager.revision, qsTr("Next Hour"))
                    value: controller.currentHourCount +
                           (controller.currentHourCount === 1 ?
                            (TranslationManager.revision, qsTr(" truck")) :
                            (TranslationManager.revision, qsTr(" trucks")))
                    loading: controller.isLoading
                }

                Local.ArrivalStatsCard {
                    Layout.fillWidth: true
                    icon: "📅"
                    title: (TranslationManager.revision, qsTr("Today"))
                    value: controller.todayCount +
                           (controller.todayCount === 1 ?
                            (TranslationManager.revision, qsTr(" truck")) :
                            (TranslationManager.revision, qsTr(" trucks")))
                    loading: controller.isLoading
                }

                UI.Button {
                    Layout.fillWidth: true
                    text: (TranslationManager.revision, qsTr("Refresh"))
                    variant: UI.ButtonStyles.Primary
                    enabled: !controller.isLoading
                    onClicked: controller.fetchAllBasicData()
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Section 2: Date Range Query
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("Date Range Query"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Local.DateRangeSelector {
                    id: dateRangeSelector
                    Layout.fillWidth: true

                    onRangeChanged: function(start, end) {
                        controller.fetchDateRangeCount(start, end)
                    }
                }

                Local.ArrivalStatsCard {
                    Layout.fillWidth: true
                    visible: controller.dateRangeCount >= 0
                    icon: "🚚"
                    title: (TranslationManager.revision, qsTr("Arrivals in Range"))
                    value: controller.dateRangeCount +
                           (controller.dateRangeCount === 1 ?
                            (TranslationManager.revision, qsTr(" truck")) :
                            (TranslationManager.revision, qsTr(" trucks")))
                    loading: controller.isLoading
                }
            }

            UI.HorizontalDivider { Layout.fillWidth: true }

            // Section 3: DateTime Range Query
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.s4

                Text {
                    text: (TranslationManager.revision, qsTr("DateTime Range Query"))
                    font.family: Theme.typography.familySans
                    font.pixelSize: Theme.typography.fontSize200
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.accent500
                }

                Local.DateTimeRangeSelector {
                    id: dateTimeRangeSelector
                    Layout.fillWidth: true

                    onRangeChanged: function(start, end) {
                        controller.fetchDateTimeRangeCount(start, end)
                    }
                }

                Local.ArrivalStatsCard {
                    Layout.fillWidth: true
                    visible: controller.dateTimeRangeCount >= 0
                    icon: "🚚"
                    title: (TranslationManager.revision, qsTr("Arrivals in Range"))
                    value: controller.dateTimeRangeCount +
                           (controller.dateTimeRangeCount === 1 ?
                            (TranslationManager.revision, qsTr(" truck")) :
                            (TranslationManager.revision, qsTr(" trucks")))
                    loading: controller.isLoading
                }
            }

            // Spacer
            Item { Layout.preferredHeight: Theme.spacing.s6 }
        }
    }

    // Initialize on first show
    Component.onCompleted: {
        controller.fetchAllBasicData()
    }
}
