import QtQuick 6.8
import QtQuick.Controls 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
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

        sourceItem: CircleMarker {
            color: Theme.colors.accent
            iconColor: Theme.colors.white
            iconSource: "qrc:/App/assets/icons/fa/ship.svg"
            labelText: "T" + root.trackNumber.toString()
            heading: root.cog
            onTapped: function () {
                SidePanelController.openOrRefresh(Routes.TrackPanel)
                SelectedTrackState.select(root.trackModel.getEditableTrack(root.index))
            }
        }
    }

    MapPolyline {
        id: historyLine

        // reactive: recomputed whenever root.history changes
        property var _path: (root.history && root.history.length)
                            ? root.history.map(t => QtPositioning.coordinate(t[0], t[1], t[2]))
                            : []

        path: _path
        line.width: 2
        line.color: "black"
        opacity: root.state === "STALE" ? 0.3 : 0.7
        antialiasing: true
        visible: _path.length > 1
        z: -1
    }

    // start point marker
    MapQuickItem {
        id: startMarker
        coordinate: historyLine._path.length ? historyLine._path[0] : QtPositioning.coordinate()
        visible: historyLine._path.length > 0
        anchorPoint.x: 6; anchorPoint.y: 6
        z: historyLine.z + 0.01
        sourceItem: Rectangle {
            width: 12; height: 12; radius: 6
            color: "#2ecc71"
            border.color: "black"; border.width: 1
            opacity: root.state === "STALE" ? 0.5 : 1.0
        }
    }
}

