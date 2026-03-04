import QtQuick 6.8
import QtQuick.Controls 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.TrackPanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

MapItemGroup {
    id: root

    required property string code
    required property geoCoordinate pos
    required property double cog
    required property string state
    required property int trackNumber

    // Index Data
    required property int index
    required property TrackModel trackModel
    required property var history

    MapQuickItem {
        id: track

        coordinate: root.pos
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height / 2

        sourceItem: TrackIcon {
            domain: TrackIcon.Cruise
            severity: TrackIcon.Neutral
            motion: TrackIcon.Moving
            ui: TrackIcon.Default
            heading: root.cog
            labelText: "T" + root.trackNumber.toString()

            onTapped: {
                SidePanelController.openOrRefresh(Routes.TrackPanel)
                SelectedTrackState.select(root.trackModel.getEditableTrack(root.index))
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
