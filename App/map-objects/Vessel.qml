import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0

MapItemGroup {
    id: root

    required property VesselModel vesselModel

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

    MapQuickItem {
        id: vessel

        coordinate:    root.pos
        anchorPoint.x: sourceItem.width  / 2
        anchorPoint.y: sourceItem.height / 2

        sourceItem: VesselIcon {
            domain:         TrackIcon.Cruise
            severity:       TrackIcon.Neutral
            motion:         root.speed > 0.5 ? TrackIcon.Moving : TrackIcon.Stationary
            ui:             root.state === "STALE" ? TrackIcon.Disabled : TrackIcon.Default
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
