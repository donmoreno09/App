import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapTools 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

import "qrc:/App/Components/floating-window/windowRoutes.js" as WinRoutes


PanelTemplate {
    id: root
    title.text: (TranslationManager.revision, qsTr("Crane"))

    ScrollView {
        id: scrollView
        anchors.fill: parent
        Layout.minimumHeight: 200
        anchors.margins: Theme.spacing.s6

        clip: true

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Theme.spacing.s4

            Label {
                text: (TranslationManager.revision, qsTr("General Info")).toUpperCase()
                font.family: Theme.typography.familySans
                font.bold: true
                font.pixelSize: Theme.typography.fontSize200
                Layout.leftMargin: Theme.spacing.s2
            }

            Rectangle {
                Layout.topMargin: Theme.spacing.s1
                Layout.leftMargin: Theme.spacing.s2
                width: 400
                color: Theme.colors.glass
                border.width: 2
                border.color: Theme.colors.glassBorder
                radius: 4

                ColumnLayout {
                    id: infoColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4
                    spacing: Theme.spacing.s2

                    Repeater {
                        model: [
                            { label: (TranslationManager.revision, qsTr("Name")),      value: "SC-07" },
                            { label: (TranslationManager.revision, qsTr("Status")),    value: (TranslationManager.revision, qsTr("On mission")) },
                            { label: (TranslationManager.revision, qsTr("Mode")),      value: (TranslationManager.revision, qsTr("Auto-assisted")) },
                            { label: (TranslationManager.revision, qsTr("Position")),  value: "44.41127, 8.93277  (B7/B7-14)" },
                            { label: (TranslationManager.revision, qsTr("Task")),      value: (TranslationManager.revision, qsTr("Relocation  B7-14 → C3-07")) },
                            { label: (TranslationManager.revision, qsTr("ETA")),       value: "10:22:45" },
                            { label: (TranslationManager.revision, qsTr("Load")),      value: "MSCU 123456 7  (45G1) • 28.7 t" },
                            { label: (TranslationManager.revision, qsTr("Twistlock")), value: (TranslationManager.revision, qsTr("Locked")) },
                            { label: (TranslationManager.revision, qsTr("Speed")),     value: "15.1 km/h" },
                            { label: (TranslationManager.revision, qsTr("Heading")),   value: "132°" },
                            { label: (TranslationManager.revision, qsTr("Fuel")),      value: "64% • ~3h" },
                            { label: (TranslationManager.revision, qsTr("Alarms")),    value: (TranslationManager.revision, qsTr("1 active (Maintenance 48h)")) },
                            { label: (TranslationManager.revision, qsTr("Timestamp")), value: "2025-10-24 10:18:32" }
                        ]

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacing.s1

                            Label {
                                text: modelData.label.toUpperCase()
                                font.bold: true
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize175
                            }

                            Label {
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize150
                                font.weight: Theme.typography.weightMedium
                                text: {
                                    return modelData.value
                                }
                            }
                        }
                    }
                }
                height: infoColumn.implicitHeight + Theme.spacing.s8 * 2
            }
        }
    }

    footer: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        UI.HorizontalDivider {
            color: Theme.colors.whiteA10
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            color: "transparent"


            RowLayout {
                anchors.fill: parent

                UI.HorizontalSpacer {}

                UI.Button {
                    id: openTelemetryButton
                    variant: UI.ButtonStyles.Primary
                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                    icon.width: 16
                    icon.height: 16
                    text: (TranslationManager.revision, qsTr("Telemetry"))

                    onClicked: function () {
                        const window = UI.WindowRouter.open(WinRoutes.GOLIATHCSV, Window.window, {
                            x: 120, y: 90, width: 1200, height: 740,
                            title: "Telemetry Viewer",
                            csvSource: "qrc:/App/assets/resources/Export_MH3_Goliath.csv"
                        })
                        if (!window) {
                            console.warn("[MOCPoiPanel] I can't open floating window");
                        } else {
                            SidePanelController.close(true)
                        }
                    }
                }

                UI.HorizontalSpacer {}

                UI.Button {
                    id: openVideoButton
                    variant: UI.ButtonStyles.Primary
                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                    icon.width: 16
                    icon.height: 16
                    text: (TranslationManager.revision, qsTr("Video"))

                    onClicked: function () {
                        const window = UI.WindowRouter.open(WinRoutes.GOLIATH, Window.window, {
                            x: 120, y: 90,  width: 1200, height: 740,
                            videoTitle: "Video View",
                            source: "qrc:/App/assets/resources/Monitoraggio Goliath 2.mp4"
                        })
                        if (!window) {
                            console.warn("[MOCPoiPanel] I can't open floating window");
                        } else {
                            SidePanelController.close(true)
                        }
                    }
                }

                UI.HorizontalSpacer {}

                UI.Button {
                    id: openLoadsButton
                    variant: UI.ButtonStyles.Primary
                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                    icon.width: 16
                    icon.height: 16
                    text: (TranslationManager.revision, qsTr("Lifted Loads"))

                    onClicked: function () {
                        const window = UI.WindowRouter.open(WinRoutes.GOLIATHLIFTEDLOADS, Window.window, {
                            x: 120, y: 90,  width: 1200, height: 740,
                            title: "Lifted Loads View",
                            source: "qrc:/App/assets/resources/Goliath_Lifted_Loads.jpg"
                        })
                        if (!window) {
                            console.warn("[MOCPoiPanel] I can't open floating window");
                        } else {
                            SidePanelController.close(true)
                        }
                    }
                }

                UI.HorizontalSpacer {}

                Component.onCompleted: {
                    const minW = Math.max(openTelemetryButton.implicitWidth,
                                          openVideoButton.implicitWidth,
                                          openLoadsButton.implicitWidth)
                    openTelemetryButton.Layout.minimumWidth = minW
                    openLoadsButton.Layout.minimumWidth = minW
                    openVideoButton.Layout.minimumWidth = minW
                }

            }
        }
    }
}


