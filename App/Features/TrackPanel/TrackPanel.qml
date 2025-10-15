import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import QtPositioning 6.8

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
            if (!value)
                return "-"

            const isTir = track.sourceName && track.sourceName.toLowerCase() === "tir"
            const speed = isTir ? value : value.speedKnots
            const unit = isTir ? "km/h" : "kn"

            return `${speed.toFixed(1)} ${unit}`
        case "Heading":
            return value ? value + "°" : "0°"
        case "Timestamp":
            return formatTimestamp(value)
        default:
            return value || "-"
        }
    }


    function formatTimestamp(value) {
        // If the input value is null, undefined, or 0 → return a placeholder
        if (!value)
            return "-"

        // Detect whether the timestamp is in seconds (10 digits) or milliseconds (13 digits)
        // If it's in seconds, multiply by 1000 to convert to milliseconds (used by JS Date)
        const timestamp = value < 1e11 ? value * 1000 : value

        // Create a JavaScript Date object from the timestamp
        const date = new Date(timestamp)

        // Helper function to pad single digits with a leading zero (e.g. "7" → "07")
        const pad = n => (n < 10 ? "0" + n : n)

        // Extract and format date/time components in UTC
        const day = pad(date.getUTCDate())
        const month = pad(date.getUTCMonth() + 1) // Months are 0-based (0 = January)
        const year = date.getUTCFullYear()
        const hours = pad(date.getUTCHours())
        const minutes = pad(date.getUTCMinutes())

        // Return formatted string in Italian style but UTC timezone: "DD/MM/YYYY HH:mm UTC"
        return `${day}/${month}/${year} ${hours}:${minutes} UTC`
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


                    Repeater {
                        model: [
                            // { label: "Entity", value: track.entity },
                            // { label: "Source Name", value: track.sourceName },
                            // { label: "Name", value: track.code },
                            { label: "Name", value: track.name },
                            { label: "Latitude", value: track.pos },
                            { label: "Longitude", value: track.pos },
                            { label: "Timestamp", value: track.time },
                            { label: "Heading", value: track.cog },
                            { label: "Speed", value: track.vel },
                            { label: "State", value: track.state }
                        ]

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacing.s1

                            Label {
                                text: modelData.label.toUpperCase()
                                font.bold: true
                            }

                            Label {
                                text: {
                                    return formatValue(modelData.label, modelData.value)
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
                anchors.leftMargin: Theme.spacing.s16
                anchors.rightMargin: Theme.spacing.s16
                spacing: 0

                // Center View Functionality
                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    UI.Button {
                        id: centerTrackIcon
                        variant: UI.ButtonStyles.Ghost
                        icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                        icon.width: 14
                        icon.height: 14
                        text: "Center View"

                        onClicked: function () {
                            let trackPosition = QtPositioning.coordinate(track.pos.latitude, track.pos.longitude)
                            MapController.setMapCenter(trackPosition)
                        }
                    }

                    // Text {
                    //     id: centerTrackText
                    //     text: "Center View"
                    //     color: Theme.colors.text
                    //     font.family: Theme.typography.familySans
                    //     font.pixelSize: Theme.typography.fontSize150
                    //     font.weight: Theme.typography.weightRegular
                    // }
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
                        font.pixelSize: 13
                        font.weight: Theme.typography.weightSemibold
                    }
                }
            }
        }
    }
}
