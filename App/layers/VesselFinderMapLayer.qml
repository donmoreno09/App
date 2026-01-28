import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0

BaseMapLayer {
    id: root
    _mapLayer: trackMapLayer
    z: Theme.elevation.layerTracks

    property alias trackMapLayer: trackMapLayer

    visible: true

    MapItemView {
        model: trackMapLayer.trackModel

        delegate: Track {
            trackModel: trackMapLayer.trackModel
        }
    }

    TrackMapLayer {
        id: trackMapLayer
        layerName: Layers.vesselFinderMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(trackMapLayer)
            TrackManager.registerLayer("vesselfinder", trackMapLayer)
            VesselFinderHttpService.registerLayer(Layers.vesselFinderMapLayer(), trackMapLayer)
            trackMapLayer.map = MapController.map
        }
    }
}
