import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

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
                Layout.bottomMargin: Theme.spacing.s4
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8

                TilesetGridItem {
                    text: `${TranslationManager.revision}` && qsTr("Map")
                    source: "qrc:/App/assets/images/osm-default.png"
                    selected: MapController._currentPlugin === MapPlugins.osmDefault

                    onClicked: MapController.setPlugin(MapPlugins.osmDefault)
                }

                TilesetGridItem {
                    text: `${TranslationManager.revision}` && qsTr("Satellite")
                    source: "qrc:/App/assets/images/maplibre-satellite.png"
                    selected: MapController._currentPlugin === MapPlugins.maplibreSatellite

                    onClicked: MapController.setPlugin(MapPlugins.maplibreSatellite)
                }

                TilesetGridItem { opacity: 0; enabled: false }
                TilesetGridItem { opacity: 0; enabled: false }
            }

            UI.HorizontalDivider { }

            SectionHeader {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.s8
                Layout.rightMargin: Theme.spacing.s8
                Layout.preferredHeight: Theme.layout.panelTitleHeight
                text: `${TranslationManager.revision}` && qsTr("Layer Management")
            }
        }
    }
}
