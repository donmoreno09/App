import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import QtQuick.Controls 6.8

import App 1.0
import App.Themes 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.TrackPanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapItemGroup {
    id: root

    required property string operationCode
    required property geoCoordinate pos
    required property double cog
    required property string state

    // Index Data
    required property int index
    required property TirModel tirModel
    required property var history

    MapQuickItem {
        id: tir

        coordinate: root.pos
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2

        sourceItem: CircleMarker {
            color: Theme.colors.accent
            iconColor: Theme.colors.white
            iconSource: "qrc:/App/assets/icons/fa/truck.svg"
            labelText: root.operationCode
            heading: root.cog
            onTapped: {
                SidePanelController.openOrRefresh(Routes.TirPanel)
                SelectedTrackState.select(root.tirModel.getEditableTir(root.index))
            }
        }
    }

    HistoryOverlay {
        history: root.history
        pos: root.pos
        state: root.state
    }
}
