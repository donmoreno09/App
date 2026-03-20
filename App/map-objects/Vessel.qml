import QtQuick 6.8
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

    required property VesselModel vesselModel
    required property int index
    readonly property bool isSelected: SelectedTrackState.selectedItem && SelectedTrackState.selectedItem.mmsi === root.mmsi

    required property geoCoordinate pos
    required property double        displayHeading
    required property double        speed
    required property string        state
    required property string        name
    required property int           a
    required property int           b
    required property int           c
    required property int           d
    required property int           shipLength
    required property int           shipWidth
    required property bool          hasDimensions
    required property var           history
    required property string        mmsi

    MapQuickItem {
        id: vessel

        coordinate:    root.pos
        anchorPoint.x: sourceItem.width  / 2
        anchorPoint.y: sourceItem.height / 2

        sourceItem: VesselIcon {
            domain:         TrackIcon.Cruise
            severity:       TrackIcon.Neutral
            motion:         TrackIcon.Moving
            ui: {
                if (isSelected) return TrackIcon.Selected
                if (hovered) return TrackIcon.Hover
                if (root.state === 'STALE') return TrackIcon.Disabled
                return TrackIcon.Default
            }
            heading:        root.displayHeading
            labelText:      root.name
            displayHeading: root.displayHeading
            a:              root.a
            b:              root.b
            c:              root.c
            d:              root.d
            shipLength:     root.shipLength
            shipWidth:      root.shipWidth
            hasDimensions:  root.hasDimensions

            onTapped: {
                SidePanelController.openOrRefresh(Routes.VesselPanel)
                SelectedTrackState.select(root.vesselModel.getEditableVessel(root.index))
            }
        }
    }

    HistoryPath {
        id: historyLine
        history: root.history
        pos:     root.pos
        state:   root.state
    }

    HistoryStartPoint {
        line:  historyLine
        state: root.state
    }
}
