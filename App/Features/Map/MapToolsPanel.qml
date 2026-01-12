import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Map Tools")

    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width

            SectionHeader {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8
                Layout.preferredHeight: Theme.layout.panelTitleHeight
                text: `${TranslationManager.revision}` && qsTr("Tilesets")
            }

            TilesetGrid {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8

                TilesetGridItem {
                    text: `${TranslationManager.revision}` && qsTr("Map")
                    source: "qrc:/App/assets/images/tileset-map.png"
                    selected: MapController._currentPlugin === MapPlugins.osmDefault

                    onClicked: MapController.setPlugin(MapPlugins.osmDefault)
                }

                TilesetGridItem {
                    text: `${TranslationManager.revision}` && qsTr("Satellite")
                    source: "qrc:/App/assets/images/tileset-satellite.png"
                    selected: MapController._currentPlugin === MapPlugins.maplibreSatellite

                    onClicked: MapController.setPlugin(MapPlugins.maplibreSatellite)
                }

                TilesetGridItem { opacity: 0; enabled: false }
                TilesetGridItem { opacity: 0; enabled: false }
            }

            UI.HorizontalDivider {
                Layout.topMargin: Theme.spacing.s8
            }

            SectionHeader {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8
                Layout.preferredHeight: Theme.layout.panelTitleHeight
                text: `${TranslationManager.revision}` && qsTr("Layer Management")
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Theme.spacing.s8
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8
                spacing: Theme.spacing.s3

                LayerToggle {
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("AIS")
                    toggle.checked: TrackManager.getLayer("ais").active
                    toggle.onCheckedChanged: {
                        if (toggle.checked) TrackManager.activate("ais")
                        else TrackManager.deactivate("ais")
                    }
                }

                LayerToggle {
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("DOC - SPACE")
                    toggle.checked: TrackManager.getLayer("doc-space").active
                    toggle.onCheckedChanged: {
                        if (toggle.checked) TrackManager.activate("doc-space")
                        else TrackManager.deactivate("doc-space")
                    }
                }

                LayerToggle {
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("TRUCK")
                    toggle.checked: TrackManager.getLayer("tir").active
                    toggle.enabled: VesselFinderHttpService !== null
                    toggle.onCheckedChanged: {
                        if (toggle.checked) TrackManager.activate("tir")
                        else TrackManager.deactivate("tir")
                    }
                }

                LayerToggle {
                    Layout.fillWidth: true
                    text: `${TranslationManager.revision}` && qsTr("VESSELFINDER")
                    toggle.checked: VesselFinderHttpService.running
                    toggle.onCheckedChanged: {
                        if (toggle.checked) {
                            VesselFinderHttpService.start()
                        } else {
                            VesselFinderHttpService.stop()
                        }
                    }
                }
            }
        }
    }
}
