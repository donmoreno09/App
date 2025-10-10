import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0


PanelTemplate {
    title.text: "Track Details"

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
                text: "GENERAL INFO"
                font.bold: true
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
                        model: ListModel {
                            ListElement {
                                label: "Name"
                                value: "Orange TIR pin"
                            }
                            ListElement {
                                label: "Latitude"
                                value: "47.7654321"
                            }
                            ListElement {
                                label: "Longitude"
                                value: "13.7654321"
                            }
                            ListElement {
                                label: "Timestamp"
                                value: "29/09/2025 11:40"
                            }
                            ListElement {
                                label: "Heading"
                                value: "0%"
                            }
                            ListElement {
                                label: "Speed"
                                value: "92 Km/h"
                            }
                        }

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacing.s1

                            Label {
                                text: label.toUpperCase()
                                font.bold: true
                            }

                            Label {
                                text: value
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
            Layout.preferredHeight: 88
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s16
                anchors.rightMargin: Theme.spacing.s16
                spacing: 0

                // Center View Functionality
                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    UI.Button {
                        id: centerTrackIcon
                        variant: UI.ButtonStyles.Ghost
                        icon.source: "qrc:/App/assets/icons/world.svg"
                        icon.width: 16
                        icon.height: 16

                        onClicked: function() {
                            console.log("[TrackPanel] center clicked!")
                            MapController.setMapCenter()
                            var idx = SelectedTrackState.model.index(SelectedTrackState.index, 0)
                            console.log(SelectedTrackState.model.data(idx, SelectedTrackState.model.CodeRole))
                        }
                    }

                    Text {
                        id: centerTrackText
                        text: "Center View"
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightRegular
                    }
                }

                // Track History Functionality
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    UI.Toggle {
                        id: toggle
                    }

                    Text {
                        text: "Track History"
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightRegular
                    }
                }
            }
        }
    }
}
