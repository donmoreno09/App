import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Playground 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0

PanelTemplate {
    property QtObject track: SelectedTrackState.selectedItem

    function formatValue(label, value) {
        switch (label) {
        case "Latitude":
            return value ? value.latitude.toFixed(6) : "-"
        case "Longitude":
            return value ? value.longitude.toFixed(6) : "-"
        case "Speed":
            return value ? value + " km/h" : "-"
        case "Heading":
            return value ? value + "°" : "-"
        case "Timestamp":
            return formatTimestamp(value)
        default:
            return value || "-"
        }
    }

    function formatTimestamp(value) {
        if (!value)
            return "-"

        // Gestisce sia stringhe ISO (es. "2025-10-10T14:32:00Z") che epoch (es. 1696948320000)
        const d = new Date(value)
        const pad = n => (n < 10 ? "0" + n : n)

        const day = pad(d.getDate())
        const month = pad(d.getMonth() + 1)
        const year = d.getFullYear()
        const hours = pad(d.getHours())
        const minutes = pad(d.getMinutes())

        return `${day}/${month}/${year} ${hours}:${minutes}`
    }

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

                    Label {
                        text: track.cog
                    }

                    // Repeater {
                    //     model: [
                    //         { label: "Name", role: TrackModel.CodeRole },
                    //         { label: "Latitude", role: TrackModel.PosRole },
                    //         { label: "Longitude", role: TrackModel.PosRole },
                    //         { label: "Timestamp", role: TrackModel.TimeRole },
                    //         { label: "Heading", role: TrackModel.CogRole },
                    //         { label: "Speed", role: TrackModel.VelRole }
                    //     ]

                    //     delegate: ColumnLayout {
                    //         Layout.fillWidth: true
                    //         spacing: Theme.spacing.s1

                    //         Label {
                    //             text: modelData.label.toUpperCase()
                    //             font.bold: true
                    //         }

                    //         Label {
                    //             text: {
                    //                 if (!SelectedTrackState.model)
                    //                     return "-"
                    //                 const v = SelectedTrackState.model.getRoleData(
                    //                             SelectedTrackState.index,
                    //                             modelData.role)
                    //                 return formatValue(modelData.label, v)
                    //             }
                    //         }
                    //     }
                    // }
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

                        onClicked: function () {
                            console.log("[TrackPanel] center clicked!")
                            var position = SelectedTrackState.model.getRoleData(SelectedTrackState.index, TrackModel.PosRole)
                            MapController.setMapCenter(position)
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
