import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Map 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Map Tilesets"))

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s4

        spacing: Theme.spacing.s4

        MapTilesetsItem {
            Layout.fillWidth: true
            text: (TranslationManager.revision, qsTr("Online OSM"))
            source: "qrc:/App/assets/images/street-map.png"
            active: MapController._currentPlugin === MapPlugins.osm

            onClicked: MapController.setPlugin(MapPlugins.osm)
        }

        MapTilesetsItem {
            Layout.fillWidth: true
            text: (TranslationManager.revision, qsTr("Default OSM"))
            source: "qrc:/App/assets/images/street-map.png"
            active: MapController._currentPlugin === MapPlugins.osmDefault

            onClicked: MapController.setPlugin(MapPlugins.osmDefault)
        }
    }
}
