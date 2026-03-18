import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import QtQuick.Controls 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.TrackPanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapItemGroup {
    id: root

    // Model properties
    required property string operationCode
    required property geoCoordinate pos
    required property double cog
    required property string state

    // Index Data
    required property int index
    required property TirModel tirModel
    required property var history

    // QML properties
    readonly property bool isSelected: SelectedTrackState.selectedItem && SelectedTrackState.selectedItem.operationCode === root.operationCode

    MapQuickItem {
        id: tir

        coordinate: root.pos
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2

        sourceItem: TrackIcon {
            heading: cog
            labelText: root.operationCode
            domain: TrackIcon.Land
            severity: TrackIcon.Neutral
            motion: TrackIcon.Moving
            ui: {
                if (isSelected) return TrackIcon.Selected
                if (hovered) return TrackIcon.Hover
                if (root.state === 'STALE') return TrackIcon.Disabled
                return TrackIcon.Default
            }

            onTapped: {
                SidePanelController.openOrRefresh(Routes.TirPanel)
                SelectedTrackState.select(root.tirModel.getEditableTir(root.index))
            }
        }
    }

    HistoryPath {
        id: historyLine
        history: root.history
        pos: root.pos
        state: root.state
    }

    HistoryStartPoint {
        line: historyLine
        state: root.state
    }
}
