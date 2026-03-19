import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0

BaseMapLayer {
    id: root
    _mapLayer: vesselMapLayer
    z: Theme.elevation.layerTracks

    property alias vesselMapLayer: vesselMapLayer

    visible: true

    MapItemView {
        model: vesselMapLayer.vesselModel

        delegate: Vessel {
            vesselModel: vesselMapLayer.vesselModel
        }
    }

    VesselMapLayer {
        id: vesselMapLayer
        layerName: Layers.vesselFinderMapLayer()

        Component.onCompleted: {
            LayerManager.registerLayer(vesselMapLayer)
            TrackManager.registerLayer("vesselfinder", vesselMapLayer)
            VesselFinderHttpService.registerLayer(Layers.vesselFinderMapLayer(), vesselMapLayer)
            vesselMapLayer.map = MapController.map
        }
    }
}
