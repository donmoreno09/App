import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

BaseMapLayer {
    id: root
    // _mapLayer: alertZoneMapLayer

    // property alias alertZoneMapLayer: alertZoneMapLayer

    Component.onCompleted: {
        console.log("[STEP 7] AlertZoneMapLayer initialized")
    }

    Connections {
        target: AlertZoneModel
        function onRowsInserted() {
            console.log("[STEP 7a] AlertZoneMapLayer: New alert zone(s) inserted. Total count:", AlertZoneModel.rowCount())
        }
    }

    MapItemView {
        model: AlertZoneModel

        delegate: MapItemGroup {
            id: loader
            // If alert zone is selected, put it on top
            z: MapModeController.alertZone && MapModeController.alertZone.id === id ? Theme.elevation.z100 + 100 : 0

            required property int index
            required property int modelIndex
            required property var model
            required property string id
            required property string label
            required property int shapeTypeId
            required property var coordinates

            Component.onCompleted: {
                console.log("[STEP 7b] Creating AlertZonePolygon - ID:", id, "| Label:", label, "| Coordinates count:", coordinates.length)
                const component = Qt.createComponent("qrc:/App/map-objects/AlertZonePolygon.qml", Qt.Asynchronous)
                component.createObject(loader)
            }
        }
    }

    // This is for the selection of the alert zones on the map, to deepen

    // AlertZoneMapLayerController {
    //     id: alertZoneMapLayer
    //     layerName: Layers.alertZoneMapLayer()

    //     Component.onCompleted: {
    //         LayerManager.registerLayer(alertZoneMapLayer)
    //         alertZoneMapLayer.map = MapController.map
    //         alertZoneMapLayer.initialize()
    //     }
    // }
}
