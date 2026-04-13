import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Components 1.0
import App.Features.Map 1.0

MapQuickItem {
    id: root

    required property geoCoordinate pos
    required property int count

    coordinate: root.pos
    anchorPoint.x: sourceItem.width / 2
    anchorPoint.y: sourceItem.height / 2

    sourceItem: Cluster {
        isDark: MapController._currentPlugin.isDark
        clusterNumber: root.count
    }
}
