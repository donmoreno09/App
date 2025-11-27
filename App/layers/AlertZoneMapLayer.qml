import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0

BaseMapLayer {
    id: root
    _mapLayer: alertZoneMapLayer

    property alias alertZoneMapLayer: alertZoneMapLayer

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
            required property bool isRectangle
            required property geoCoordinate coordinate
            required property geoCoordinate topLeft
            required property geoCoordinate bottomRight
            required property real radiusA
            required property real radiusB
            required property var coordinates
            required property bool active
            required property string severity

            Component.onCompleted: {
                let source = ""
                switch (shapeTypeId) {
                case MapModeController.EllipseType:
                    source = "qrc:/App/map-objects/AlertZoneEllipse.qml"
                    break;
                case MapModeController.PolygonType:
                    if (isRectangle) source = "qrc:/App/map-objects/AlertZoneRectangle.qml"
                    else source = "qrc:/App/map-objects/AlertZonePolygon.qml"
                    break;
                }

                const component = Qt.createComponent(source, Qt.Asynchronous)
                component.createObject(loader)
            }
        }

    // This is for the selection of the alert zones on the map, to deepen

        AlertZoneMapLayerController {
            id: alertZoneMapLayer
            layerName: Layers.alertZoneMapLayer()

            Component.onCompleted: {
                LayerManager.registerLayer(alertZoneMapLayer)
                alertZoneMapLayer.map = MapController.map
                alertZoneMapLayer.initialize()
            }
        }
    }
}
