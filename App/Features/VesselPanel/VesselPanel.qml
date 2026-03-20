import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0
import App.Features.TrackPanel 1.0

PanelTemplate {
    property QtObject vessel: SelectedTrackState.selectedItem

    function formatNavStatus(code) {
        switch (parseInt(code)) {
        case 0:  return qsTr("Under way using engine")
        case 1:  return qsTr("At anchor")
        case 2:  return qsTr("Not under command")
        case 3:  return qsTr("Restricted maneuverability")
        case 4:  return qsTr("Constrained by draught")
        case 5:  return qsTr("Moored")
        case 6:  return qsTr("Aground")
        case 7:  return qsTr("Engaged in fishing")
        case 8:  return qsTr("Under way sailing")
        case 14: return qsTr("AIS-SART active")
        default: return "-"
        }
    }

    function formatTimestamp(value) {
        if (!value) return "-"
        const timestamp = value < 1e11 ? value * 1000 : value
        const date = new Date(timestamp)
        const pad = n => (n < 10 ? "0" + n : n)
        return `${pad(date.getUTCDate())}/${pad(date.getUTCMonth() + 1)}/${date.getUTCFullYear()} ${pad(date.getUTCHours())}:${pad(date.getUTCMinutes())} UTC`
    }

    title.text: `${TranslationManager.revision}` && qsTr("Vessel Details")

    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s6
        clip: true

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.spacing.s4

            // --- General Info ---
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
                    id: generalColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4
                    spacing: Theme.spacing.s2

                    Repeater {
                        model: [
                            { label: `${TranslationManager.revision}` && qsTr("Name"),       value: vessel ? vessel.name : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("MMSI"),       value: vessel ? vessel.mmsi : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Latitude"),   value: vessel && vessel.pos ? vessel.pos.latitude.toFixed(6)  : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Longitude"),  value: vessel && vessel.pos ? vessel.pos.longitude.toFixed(6) : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Speed"),      value: vessel ? vessel.speed.toFixed(1) + " kn" : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Heading"),    value: vessel ? (vessel.heading === 511 ? "-" : vessel.heading + "°") : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("COG"),        value: vessel ? vessel.cog.toFixed(1) + "°" : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Timestamp"),  value: vessel ? formatTimestamp(vessel.time) : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Nav Status"), value: vessel ? formatNavStatus(vessel.state) : "-" },
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
                                text: modelData.value
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize150
                                font.weight: Theme.typography.weightMedium
                            }
                        }
                    }
                }
                height: generalColumn.implicitHeight + Theme.spacing.s8 * 2
            }

            // --- Dimensions (only when hasDimensions) ---
            Label {
                visible: vessel && vessel.hasDimensions
                text: `${TranslationManager.revision}` && qsTr("Dimensions").toUpperCase()
                font.family: Theme.typography.familySans
                font.bold: true
                font.pixelSize: Theme.typography.fontSize200
                Layout.leftMargin: Theme.spacing.s2
            }

            Rectangle {
                visible: vessel && vessel.hasDimensions
                Layout.topMargin: Theme.spacing.s1
                Layout.leftMargin: Theme.spacing.s2
                width: 400
                color: Theme.colors.glass
                border.width: 2
                border.color: Theme.colors.glassBorder
                radius: 4

                ColumnLayout {
                    id: dimensionsColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4
                    spacing: Theme.spacing.s2

                    Repeater {
                        model: [
                            { label: `${TranslationManager.revision}` && qsTr("Length"), value: vessel ? vessel.shipLength + " m" : "-" },
                            { label: `${TranslationManager.revision}` && qsTr("Width"),  value: vessel ? vessel.shipWidth  + " m" : "-" },
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
                                text: modelData.value
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize150
                                font.weight: Theme.typography.weightMedium
                            }
                        }
                    }
                }
                height: dimensionsColumn.implicitHeight + Theme.spacing.s8 * 2
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
                    variant: UI.ButtonStyles.Ghost
                    icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
                    icon.width: 16
                    icon.height: 16
                    text: `${TranslationManager.revision}` && qsTr("Center View")

                    onClicked: {
                        if (vessel && vessel.pos)
                            MapController.setMapCenter(QtPositioning.coordinate(vessel.pos.latitude, vessel.pos.longitude))
                    }
                }

                UI.HorizontalSpacer {}

                RowLayout {
                    Layout.preferredWidth: 1
                    Layout.rightMargin: Theme.spacing.s4

                    UI.Toggle {
                        id: toggle
                        property string topic: "vesselfinder"
                        property string uid:   vessel ? vessel.uidForHistory : ""

                        property int  _state:  TrackManager.historyState(topic, uid)
                        property bool _active: TrackManager.isHistoryActive(topic, uid)

                        checked: _active
                        enabled: _state !== TrackManager.Loading

                        onCheckedChanged: {
                            if (_state === TrackManager.Loading) return
                            if (checked === _active) return
                            TrackManager.setHistoryActive(topic, uid, checked)
                        }

                        Connections {
                            target: TrackManager
                            function onHistoryStateChanged(tp, u, state) {
                                if (tp === toggle.topic && u === toggle.uid) {
                                    toggle._state  = state
                                    toggle._active = (state === TrackManager.Active)
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
