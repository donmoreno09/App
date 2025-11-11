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
        if (value === '-') {
            return value
        }

        switch (label) {
        case `${TranslationManager.revision}` && qsTr("Latitude"):
            return value ? value.latitude.toFixed(6) : "-"
        case `${TranslationManager.revision}` && qsTr("Longitude"):
            return value ? value.longitude.toFixed(6) : "-"
        case `${TranslationManager.revision}` && qsTr("Speed"):
            if (!value || !track)
                return "-"

            const isTir = track.sourceName && track.sourceName.toLowerCase() === "tir"
            const speed = isTir ? value : value.speedKnots
            const unit = isTir ? "km/h" : "kn"

            return `${speed.toFixed(1)} ${unit}`
        case `${TranslationManager.revision}` && qsTr("Heading"):
            return value ? value + "°" : "0°"
        case `${TranslationManager.revision}` && qsTr("Timestamp"):
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


    title.text: `${TranslationManager.revision}` && qsTr("Track Details")

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
                text: `${TranslationManager.revision}` && qsTr("General Info").toUpperCase()
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
                            { label: `${TranslationManager.revision}` && qsTr("Name"), value: track ? track.name : '-' },
                            { label: `${TranslationManager.revision}` && qsTr("Latitude"), value: track ? track.pos : '-' },
                            { label: `${TranslationManager.revision}` && qsTr("Longitude"), value: track ? track.pos : '-' },
                            { label: `${TranslationManager.revision}` && qsTr("Timestamp"), value: track ? track.time : '-' },
                            { label: `${TranslationManager.revision}` && qsTr("Heading"), value: track ? track.cog : '-' },
                            { label: `${TranslationManager.revision}` && qsTr("Speed"), value: track ? track.vel : '-' },
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

                UI.HorizontalSpacer {}

                UI.Button {
                    id: centerTrackIcon
                    variant: UI.ButtonStyles.Ghost
                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                    icon.width: 16
                    icon.height: 16
                    text: `${TranslationManager.revision}` && qsTr("Center View")

                    onClicked: function () {
                        let trackPosition = QtPositioning.coordinate(track.pos.latitude, track.pos.longitude)
                        MapController.setMapCenter(trackPosition)
                    }
                }

                UI.HorizontalSpacer {}

                // Track History Functionality
                RowLayout {
                    Layout.preferredWidth: 1
                    Layout.rightMargin: Theme.spacing.s4    // TODO: Investigate to solve this ugly fix.

                    UI.Toggle {
                        id: toggle
                        property string topic: track? track.sourceName : ""
                        property string uid: track? track.uidForHistory : ""

                        // Local cached state, initialized from the manager (functions are not reactive by themselves)
                        property int  _state:  TrackManager.historyState(topic, uid)      // 0=Inactive, 1=Loading, 2=Active
                        property bool _active: TrackManager.isHistoryActive(topic, uid)   // convenience: true if Active

                        // Bind UI to local cached state
                        checked: _active
                        enabled: _state !== TrackManager.Loading   // disable while waiting for first payload

                        // Prevent spurious requests on programmatic updates or while in Loading
                        onCheckedChanged: {
                            if (_state === TrackManager.Loading) return;        // ignore while awaiting backend data
                            if (checked === _active) return;                    // ignore no-op changes
                            TrackManager.setHistoryActive(topic, uid, checked); // ON→Loading, OFF→Inactive (+clear)
                        }

                        // Keep local state in sync with manager changes (makes the binding reactive)
                        Connections {
                            target: TrackManager
                            function onHistoryStateChanged(tp, u, state) {
                                if (tp === toggle.topic && u === toggle.uid) {
                                    toggle._state  = state;                              // update cached state
                                    toggle._active = (state === TrackManager.Active);    // update cached boolean
                                    // 'checked' follows _active via binding; no re-entrant calls
                                }
                            }
                        }
                    }

                    Text {
                        Layout.leftMargin: Theme.spacing.s2
                        text: `${TranslationManager.revision}` && qsTr("Track History")
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                    }
                }

                UI.HorizontalSpacer {}

            }
        }
    }
}
